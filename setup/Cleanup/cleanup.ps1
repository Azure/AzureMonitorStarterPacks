param (
    [Parameter(Mandatory=$true)]
    [string]$RG,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveAll,
    [Parameter(Mandatory=$false)]
    [string]$removeTag,
    [Parameter(Mandatory=$false)]
    [switch]$RemovePacks,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveAMAPolicySet,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveMainSolution
)
# Check login
# import module(s)
# Resource graph
Write-Output "Installing/Loading Azure Resource Graph module."
if ($null -eq (get-module Az.ResourceGraph)) {
    try {
        install-module az.resourcegraph -AllowPrerelease -Force
        import-module az.ResourceGraph #-Force
    }
    catch {
        Write-Error "Unable to install az.resourcegraph module. Please make sure you have the proper permissions to install modules."
        return
    }
}
# Add deployment cleanup. Deployments may conflict if previous deployment to the same resource group failed or done to another region.

# AMA policy set removal
# Remove policy sets
if ($RemoveAMAPolicySet -or $RemoveAll) {
    $inits=Get-AzPolicySetDefinition | where-object {$_.properties.Metadata.MonitorStarterPacks -ne $null}
    foreach ($init in $inits) {
        "Removing policy set $($init.PolicySetDefinitionId)"
        $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId
        if ($assignments.count -ne 0)
        {
            "Removing assignments for $($init.PolicySetDefinitionId)"
            $assignments | Remove-AzPolicyAssignment 
        }
        Remove-AzPolicySetDefinition -Id $init.PolicySetDefinitionId
    }
}
else {
    "Skipping AMA policy set removal. Use -RemoveAMAPolicySet to remove them."
}

#region Packs
# Remove policy assignments and policies
if ($RemovePacks  -or $RemoveAll) {
    $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.MonitorStarterPacks -ne $null} 
    if ($RemoveTag) {
        "Removing packs with tag $RemoveTag."
        $pols=$pols | where-object {$_.properties.Metadata.MonitorStarterPacks -eq $RemoveTag}
    }
    foreach ($pol in $pols) {
        $remove=$true
        if ($confirmEachPack) {
            $confirm=Read-Host "Do you want to remove pack $($pol.Name)? (Y/N)"
            if ($confirm -eq 'N') {
                $remove=$false
            }
            else {
                $Remove=$true
            }
        }
        if ($remove) {
            "Removing policy $($pol.PolicyDefinitionId) and assignments for pack $($pol.properties.Metadata.MonitorStarterPacks)"
            $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
            
            if ($assignments.count -ne 0)
            {
                "Removing assignments for $($pol.PolicyDefinitionId)"
                foreach ($assignment in $assignments) {
                    $assignmentObjectId= Get-AzADServicePrincipal -Id $assignment.Identity.PrincipalId -ErrorAction SilentlyContinue
                    Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id} | Remove-AzRoleAssignment
                    #$ras=Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id}
                    # -and $_. -eq $assignments.Identity.PrincipalId} | Remove-AzRoleAssignment
                    "Removing assignment for $($assignment.Identity.PrincipalId)"
                    Remove-AzPolicyAssignment -Id $assignment.PolicyAssignmentId
                }
                "Removing policy definition for $($pol.PolicyDefinitionId)"
                Remove-AzPolicyDefinition -Id $pol.PolicyDefinitionId -Force
            }
        }
        else {
            "Skipping pack $($pol.Name)"
        }
    }
    # If something remains, clear all dead assignments in the current subscription
    Get-AzRoleAssignment -scope "/subscriptions/$((Get-AzContext).Subscription)" | where-object {$_.ObjectType -eq 'unknown'}  | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | Remove-AzRoleAssignment
    # remove DCR associations
$query=@'
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]
| where isnotnull(properties.dataCollectionRuleId)
| project rulename=split(properties.dataCollectionRuleId,"/")[8],resourceName=split(resourceId,"/")[8],resourceId, ruleId=properties.dataCollectionRuleId, name
| where ruleId =~
'@
    $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG
    if ($RemoveTag) {
        $DCRs=$DCRs | where-object {$_.Tags.MonitorStarterPacks -eq $RemoveTag}
    }
    foreach ($DCR in $DCRs)
    {
        $searchQuery=$query + "'$($DCR.Id)'"
        $dcras=Search-AzGraph -Query $searchQuery
        foreach ($dcra in $dcras) {
            "Removing DCR association $($dcra.rulename) for $($dcra.resourceId)"
            Remove-AzDataCollectionRuleAssociation -TargetResourceId $dcra.resourceId -AssociationName $dcra.name
        }
        Remove-AzDataCollectionRule -ResourceGroupName $DCR.Id.Split('/')[4] -Name $DCR.Name
    }
    # remove DCRs
    #Get-AzDataCollectionRule -ResourceGroupName $RG | Remove-AzDataCollectionRule
    # remove Tags from VMs.
    # remove monitor extensions (optional)
    # remove alert rules
    $Alerts=Get-AzResource -ResourceType "microsoft.insights/scheduledqueryrules" -ResourceGroupName $RG 
    if ($RemoveTag) {
        $Alerts=$Alerts | where-object {$_.Tags.MonitorStarterPacks -eq $RemoveTag}
    }
    $Alerts | Remove-AzResource -Force
    # remove main solution (workbook, logic app, function app)
}
else {
    "Skipping packs removal. Use -RemovePacks to remove packs. Use -RemoveTag to remove packs with a specific tag."
}
#endregion

#region Main Solution
if ($RemoveMainSolution  -or $RemoveAll) {
    Get-AzResource -ResourceType 'Microsoft.Insights/workbooks' -ResourceGroupName $RG | Remove-AzResource -Force
    Get-AzResource -ResourceType 'Microsoft.Logic/workflows' -ResourceGroupName $RG | Remove-AzResource -Force
    # remove function app roles and functiona app itself
    $PrincipalId=(Get-AzWebApp -ResourceGroupName $RG).Identity.PrincipalId
    Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $PrincipalId} | Remove-AzRoleAssignment
    Get-AzResource -ResourceType 'Microsoft.Web/sites' -ResourceGroupName $RG | Remove-AzResource -Force

    # Remove web server (farm)
    Get-AzResource -ResourceType 'Microsoft.Web/serverfarms' -ResourceGroupName $RG | Remove-AzResource -Force
    #remove deployment scripts
    Get-azresource -ResourceType 'Microsoft.Resources/deploymentScripts' -ResourceGroupName $RG | Remove-AzResource -Force
    #delete data collection endpoints
    get-azresource -ResourceType 'Microsoft.Insights/dataCollectionEndpoints' -ResourceGroupName $RG | Remove-AzResource -Force
    #remove app insights
    Get-AzApplicationInsights -ResourceGroupName $RG | Remove-AzApplicationInsights
    #remove app insights default alerts
    get-azresource -ResourceType 'microsoft.alertsmanagement/smartDetectorAlertRules' -ResourceGroupName $RG | Remove-AzResource -Force
    # Remove custom remediation role 
    #Remove-AzRoleDefinition -Name 'Custom Role - Remediation Contributor' -Force
    # remove storage account
}
else {
    "Skipping main solution removal. Use -RemoveMainSolution to remove it"
}


# # remove log analytics - optional
# # Remove resource Group

# ARG Query to check
# # resources
# # | where isnotempty(tags.MonitorStarterPacks)
# # | project ['id'], type
# # | union (policyresources
# # | where isnotempty(properties.metadata.MonitorStarterPacks)|
# # project id,type=tostring(split(id,"/")[4]))


# # remove policy assignments and policies
# # remove DCR associations
# # remove DCRs
# $DCRs=Get-AzDataCollectionRule | ?{$_.Tags.MonitorStarterPacks -ne $null}
# foreach ($DCR in $DCRs) {
    
#     $dcras=Get-AzDataCollectionRuleAssociation -RuleName $DCR.Name -ResourceGroupName $DCR.Id.split('/')[4]
#     foreach ($dcra in $dcras) {
#         $dcra.ObjectId
#         Remove-AzDataCollectionRuleAssociation -
#     }
#     "Removing DCR $($DCR.Name)"
#     #Remove-AzDataCollectionRule -Name $DCR.Name -ResourceGroupName $DCR.ResourceGroupName
# }

# $allDCRa=Search-AzGraph -Query @'
# insightsresources
# | where type == "microsoft.insights/datacollectionruleassociations"
# | extend dcrId=tostring(properties.dataCollectionRuleId)
# | project dcrId, name,TargetResource=split(id,'/providers/Microsoft.Insights/')[0],resourceGroup
# | where name has 'MonStar'
# '@
# foreach ($dcra in $allDCRa) {
#     "Removing $($dcra.name) for $($dcra.TargetResource)"
#     Remove-AzDataCollectionRuleAssociation -TargetResourceId $dcra.TargetResource -AssociationName $dcra.name
#     #$dcr=Get-AzDataCollectionRule -Name $dcra.Name -ResourceGroupName $dcra.ResourceGroup
#     # if ($dcr.Tags.MonitorStarterPacks -ne $null) {
#     #     "Removing DCR $($dcr.Name)"
#     #     #Remove-AzDataCollectionRule -Name $dcr.Name -ResourceGroupName $dcr.ResourceGroupName
#     # }
# }
# # remove dead role assignments - if not removed it will fail to install again.
# # Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | where-object {$_.ObjectType -eq 'unknown'}  | Remove-AzRoleAssignment
# # remove action group(s)?
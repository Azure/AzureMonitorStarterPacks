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
    [switch]$RemoveMainSolution,
    [Parameter(Mandatory=$false)]
    [switch]$confirmEachPack
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
    "Removing AMA policy set."
    $inits=Get-AzPolicySetDefinition | where-object {$_.properties.Metadata.MonitorStarterPacks -ne $null}
    foreach ($init in $inits) {
        "Removing policy set $($init.PolicySetDefinitionId)"
        #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId
        $query=@"
        policyresources
        | where type == "microsoft.authorization/policyassignments"
        | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
        | where PolicyId == '$($init.PolicySetDefinitionId)'
"@
        $assignments=Search-AzGraph -Query $query
        if ($assignments.count -ne 0)
        {
            "Removing assignments for $($pol.PolicyDefinitionId)"
            foreach ($assignment in $assignments) {
                "Removing assignment for $($assignment.name)"
                Remove-AzPolicyAssignment -Id $assignment.id
            }
        }
        Remove-AzPolicySetDefinition -Id $init.PolicySetDefinitionId -Force
    }
}
else {
    "Skipping AMA policy set removal. Use -RemoveAMAPolicySet to remove them."
}

#region Packs
# Remove policy assignments and policies
if ($RemovePacks  -or $RemoveAll) {
    "Removing packs."
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
            #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId # Only works for the current subscription. Need to use resource graph.
            $query=@"
            policyresources
            | where type == "microsoft.authorization/policyassignments"
            | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
            | where PolicyId == '$($pol.PolicyDefinitionId)'
"@
            $assignments=Search-AzGraph -Query $query
            
            if ($assignments.count -ne 0)
            {
                "Removing assignments for $($pol.PolicyDefinitionId)"
                foreach ($assignment in $assignments) {
                    # No need to remove role assignments with user defined managed identities.
                    # $assignmentObjectId= Get-AzADServicePrincipal -Id $assignment.Identity.PrincipalId -ErrorAction SilentlyContinue
                    # Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id} | Remove-AzRoleAssignment
                    # #$ras=Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id}
                    # -and $_. -eq $assignments.Identity.PrincipalId} | Remove-AzRoleAssignment
                    "Removing assignment for $($assignment.name)"
                    Remove-AzPolicyAssignment -Id $assignment.id
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
    $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG | where-object {$_.Tags.MonitorStarterPacks -ne $null}
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
    $Alerts | Remove-AzResource -Force -AsJob


}
else {
    "Skipping packs removal. Use -RemovePacks to remove packs. Use -RemoveTag to remove packs with a specific tag."
}
#endregion

#region Main Solution
if ($RemoveMainSolution  -or $RemoveAll) {
    "Removing main solution."
    "Removing workbook(s)."
    Get-AzResource -ResourceType 'Microsoft.Insights/workbooks' -ResourceGroupName $RG | Remove-AzResource -Force
    "Removing Logic app."
    Get-AzResource -ResourceType 'Microsoft.Logic/workflows' -ResourceGroupName $RG | Remove-AzResource -Force
    # remove function app roles and functiona app itself
    "Removing function app."
    $PrincipalId=(Get-AzWebApp -ResourceGroupName $RG).Identity.PrincipalId
    Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $PrincipalId} | Remove-AzRoleAssignment
    Get-AzResource -ResourceType 'Microsoft.Web/sites' -ResourceGroupName $RG | Remove-AzResource -Force

    # Remove web server (farm)
    "Removing web server."
    Get-AzResource -ResourceType 'Microsoft.Web/serverfarms' -ResourceGroupName $RG | Remove-AzResource -Force
    #remove deployment scripts
    "Removing deployment scripts."
    Get-azresource -ResourceType 'Microsoft.Resources/deploymentScripts' -ResourceGroupName $RG | Remove-AzResource -Force
    #remove app insights
    "Removing app insights."
    Get-AzApplicationInsights -ResourceGroupName $RG | Remove-AzApplicationInsights
    #remove app insights default alerts
    "Removing app insights default alerts."
    get-azresource -ResourceType 'microsoft.alertsmanagement/smartDetectorAlertRules' -ResourceGroupName $RG | Remove-AzResource -Force
    # Remove grafana
    "Removing grafana. This removes the grafana dashboard and the grafana resource. It takes a while to complete. Make sure it has been removed before running the script again."
    Get-AzResource -ResourceType 'Microsoft.Dashboard/grafana' -ResourceGroupName $RG | Remove-AzResource -Force -asJob
    #delete data collection endpoints
    "Removing data collection endpoints."
    get-azresource -ResourceType 'Microsoft.Insights/dataCollectionEndpoints' -ResourceGroupName $RG | Remove-AzResource -Force
    # Remove custom remediation role 
    #Remove-AzRoleDefinition -Name 'Custom Role - Remediation Contributor' -Force
    # remove storage account

    # remove managed identities
    
    # Fetch existing managed identities. Name should be:
    $managedIdentityNames=@( 'packsUserManagedIdentity', 'AMAUserManagedIdentity','functionUserManagedIdentity')
    foreach ($MIName in $managedIdentityNames) {
        $MIResourceName=(get-azresource -ResourceGroupName $RG -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name $MIName).Name
        $MIObjectId=(Get-AzADServicePrincipal -DisplayName $MIName).Id
        Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $MIObjectId} | Remove-AzRoleAssignment
        get-azresource -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name $MIResourceName -ResourceGroupName $RG | Remove-AzResource -Force
    }
    # Remove Role assignments - tough one if more than one sub is used

    #remove resource
    #do the same for the function MI.

    # remove log analytics workspace
    
}
else {
    "Skipping main solution removal. Use -RemoveMainSolution to remove it"
}

if ($RemoveTag) {
    " Removing tag $RemoveTag from resources."
    " Not implemented yet."
}


param (
    [Parameter(Mandatory=$true)]
    [string]$RG,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveAll,
    [Parameter(Mandatory=$false)]
    [switch]$RemovePacks,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveAMAPolicySet,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveMainSolution,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveDiscovery,
    [Parameter(Mandatory=$false)]
    [switch]$confirmEachPack
)
# Check login
# import module(s)
# Resource graph
Write-Output "Installing/Loading Azure Resource Graph module."
if ($null -eq (get-module Az.ResourceGraph)) {
    try {
        install-module az.resourcegraph
        import-module az.ResourceGraph #-Force
    }
    catch {
        Write-Error "Unable to install az.resourcegraph module. Please make sure you have the proper permissions to install modules."
        return
    }
}
# Test if resource group exists
Write-Output "Checking if resource group $RG exists."
if ($null -eq (Get-AzResourceGroup -Name $RG -ErrorAction SilentlyContinue)) {
    Write-Error "Resource group $RG does not exist."
    return
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

if ($RemoveDiscovery -or $RemoveAll) {
    # Remove DCR associations
    # Remove DCRs
    
    "Removing discovery components."
    "Removing DCRs and associations."
    $query=@'
    insightsresources
    | where type == "microsoft.insights/datacollectionruleassociations"
    | extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]
    | where isnotnull(properties.dataCollectionRuleId)
    | project rulename=split(properties.dataCollectionRuleId,"/")[8],resourceName=split(resourceId,"/")[8],resourceId, ruleId=properties.dataCollectionRuleId, name
    | where ruleId =~
'@
    # Remove DCRs and associations
    $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG | where-object {$_.Tags.MonitoringPackType -eq "Discovery"} -ErrorAction SilentlyContinue
    foreach ($DCR in $DCRs)
    {
        $searchQuery=$query + "'$($DCR.Id)'"
        $dcras=Search-AzGraph -Query $searchQuery -UseTenantScope
        foreach ($dcra in $dcras) {
            "Removing DCR association $($dcra.rulename) for $($dcra.resourceId)"
            Remove-AzDataCollectionRuleAssociation -TargetResourceId $dcra.resourceId -AssociationName $dcra.name
        }
        Remove-AzDataCollectionRule -ResourceGroupName $DCR.Id.Split('/')[4] -Name $DCR.Name
    }
    $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.MonitoringPackType -eq "Discovery"}
    # retrive unique list of packs installed
    $packs=$pols.properties.Metadata.MonitorStarterPacks | Select-Object -Unique # should be just discovery anyways in this case.
    "Found $($packs.count) packs with DCRs: $packs"
    # if ($RemoveTag) {
    #     "Removing packs with tag $RemoveTag."
    #     $pols=$pols | where-object {$_.properties.Metadata.MonitorStarterPacks -eq $RemoveTag}
    # }
    foreach ($pack in $packs) {
        "Removing pack $pack."
        foreach ($pol in ($pols | Where-Object {$_.properties.Metadata.MonitorStarterPacks -eq $pack}) ) {
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
                $assignments=Search-AzGraph -Query $query -UseTenantScope
                
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
                 }
                "Removing policy definition for $($pol.PolicyDefinitionId)"
                Remove-AzPolicyDefinition -Id $pol.PolicyDefinitionId -Force
            }
            else {
                "Skipping pack $($pol.Name)"
            }
        }
    }
    # Uninstall vm applications from VMs.
    # Remove Applications from Gallery
    
    # uninstall VM Apps
    # find the gallery
    Get-AzGallery -ResourceGroupName $RG | Where-Object {$_.Tags.MonitorStarterPacksComponents -ne $null} | ForEach-Object {
        $galleryApps=Get-AzGalleryApplication -GalleryName $_.Name -ResourceGroupName $RG
        foreach ($ga in $galleryApps) {
            $gavs=Get-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -ResourceGroupName $RG
            foreach ($gav in $gavs) {
                # Find vms with that app
                $vms=Get-AzVM | where {$_.ApplicationProfile -ne $null} | where {$_.ApplicationProfile.Applications -ne $null} | where {$_.ApplicationProfile.Applications.Name -eq $ga.Name}
                foreach ($vm in $vms) {
                    # Remove Application from VM - Remove-AzVMGalleryApplication
                    Remove-AzVMGalleryApplication -VM $vm -Name $ga.Name -Version $gav.Name -ResourceGroupName $RG
                }
                # Remove Application Version - Remove-AzGalleryApplicationVersion
                Remove-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -Name $gav.Name -ResourceGroupName $RG
            }
            # Find VMs with that app
            #$vms=get-azVM | where {$_.ApplicationProfile -ne $null} | where {$_.ApplicationProfile.Applications -ne $null} | where {$_.ApplicationProfile.Applications.Name -eq $ga.Name}
            # Remove Application from VM - Remove-AzVMGalleryApplication
            # Remove Application Version - Remove-AzGalleryApplicationVersion
            #Get-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -ResourceGroupName $RG | Remove-AzGalleryApplicationVersion
            # Remove Application - Remove-AzGalleryApplication
            #remove-AzGalleryApplication -GalleryName $_.Name -Name $ga.Name -ResourceGroupName $RG  
        }
    }
}
#region Packs
# Remove policy assignments and policies
if ($RemovePacks -or $RemoveAll) {
    "Removing packs."
    # Gets all policies with the tag MonitorStarterPacks
    $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.MonitorStarterPacks -ne $null} 
    # retrive unique list of packs installed
    $packs=$pols.properties.Metadata.MonitorStarterPacks | Select-Object -Unique
    "Found $($packs.count) packs with DCRs: $packs"
    # if ($RemoveTag) {
    #     "Removing packs with tag $RemoveTag."
    #     $pols=$pols | where-object {$_.properties.Metadata.MonitorStarterPacks -eq $RemoveTag}
    # }
    foreach ($pack in $packs) {
        "Removing pack $pack."
        foreach ($pol in ($pols | Where-Object {$_.properties.Metadata.MonitorStarterPacks -eq $pack}) ) {
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
                $assignments=Search-AzGraph -Query $query -UseTenantScope
                
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
                 }
                "Removing policy definition for $($pol.PolicyDefinitionId)"
                Remove-AzPolicyDefinition -Id $pol.PolicyDefinitionId -Force
            }
            else {
                "Skipping pack $($pol.Name)"
            }
        }
    }
        # If something remains, clear all dead assignments in the current subscription
        #Get-AzRoleAssignment -scope "/subscriptions/$((Get-AzContext).Subscription)" | where-object {$_.ObjectType -eq 'unknown'}  | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | Remove-AzRoleAssignment
        # remove DCR associations
        $dcrs=Get-AzDataCollectionRule -ResourceGroupName $RG | Where-Object {$_.tags.MonitorStarterPacks -ne $null} 
        # retrive unique list of packs installed
        $packs=$dcrs.tags.MonitorStarterPacks | Select-Object -Unique
    foreach ($pack in $packs) {
        $query=@'
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]
| where isnotnull(properties.dataCollectionRuleId)
| project rulename=split(properties.dataCollectionRuleId,"/")[8],resourceName=split(resourceId,"/")[8],resourceId, ruleId=properties.dataCollectionRuleId, name
| where ruleId =~
'@
        $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG | where-object {$_.Tags.MonitorStarterPacks -eq $pack}
        # if ($RemoveTag) {
        #     $DCRs=$DCRs | where-object {$_.Tags.MonitorStarterPacks -eq $RemoveTag}
        # }
        foreach ($DCR in $DCRs)
        {
            $searchQuery=$query + "'$($DCR.Id)'"
            $dcras=Search-AzGraph -Query $searchQuery -UseTenantScope
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
        $Alerts=Get-AzResource -ResourceType "microsoft.insights/scheduledqueryrules" -ResourceGroupName $RG | Where-Object {$_.Tags.MonitorStarterPacks -eq $pack}
        # if ($RemoveTag) {
        #     $Alerts=$Alerts | where-object {$_.Tags.MonitorStarterPacks -eq $RemoveTag}
        # }
        $Alerts | Remove-AzResource -Force -AsJob
    }
}
else {
    "Skipping packs removal. Use -RemovePacks to remove packs."
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
    $appinsights=Get-AzApplicationInsights -ResourceGroupName $RG -ErrorAction SilentlyContinue
    if ($appinsights) {
        $appinsights | Remove-AzApplicationInsights -Confirm:$false
    }
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
    $query=@"
    resources
| where type =~ 'Microsoft.ManagedIdentity/userAssignedIdentities'
| where tolower(resourceGroup) == '$($RG.toLower())'
| project name
"@
$managedIdentityNames=(Search-AzGraph -Query $query).name
    foreach ($MIName in $managedIdentityNames) {
        $MIResourceName=(get-azresource -ResourceGroupName $RG -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name $MIName -ErrorAction SilentlyContinue).Name
        $MIObjectId=(Get-AzADServicePrincipal -DisplayName $MIName -ErrorAction SilentlyContinue).Id
        if ($MIObjectId) {
            Get-AzRoleAssignment | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $MIObjectId} | Remove-AzRoleAssignment
        }
        if ($MIResourceName) {
            get-azresource -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name $MIResourceName -ResourceGroupName $RG | Remove-AzResource -Force
        }
    }
    # Remove Key Vault
    "Removing key vault."
    Get-AzResource -ResourceType 'Microsoft.KeyVault/vaults' -ResourceGroupName $RG | Remove-AzResource -Force
    # Remove api connection for logic app
    "Removing api connection for logic app."
    Get-AzResource -ResourceType 'Microsoft.Web/connections' -ResourceGroupName $RG | Remove-AzResource -Force
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


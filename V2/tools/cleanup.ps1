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
    [switch]$RemoveDiscoveryVMApps,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveStorage,
    [Parameter(Mandatory=$false)]
    [switch]$RemoveLAW,
    [Parameter(Mandatory=$false)]
    [switch]$confirmEachPack
)
#region functions
function remove-appversions {
    param (
        [object]$vm,
        [array]$appstoremove
    )
    #$vmswithApps=Get-AzVM | Where-Object { $_.ApplicationProfile -ne $null}
    #$appstoremove=@("/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/rg-MonstarPacks/providers/Microsoft.Compute/galleries/AMPprodGallery/applications/ADDS-collection/versions/1.0.0","/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/rg-MonstarPacks/providers/Microsoft.Compute/galleries/AMPprodGallery/applications/prod-windiscovery/versions/1.0.0")
    # foreach ($VM in $vmswithApps)
    # {

    # if app name is the one to remove
    foreach ($apptoremove in $appstoremove)
    {
        "Checking for app: $apptoremove"
        "VM has " + $VM.ApplicationProfile.GalleryApplications.Count + " apps."
        $app = $VM.ApplicationProfile.GalleryApplications | Where-Object { $_.PackageReferenceId -eq $apptoremove}
        if ($app)
        {
            # remove app from vm
            "Removing $($app.PackageReferenceId.Split("/applications/")[1]) from VM: $($VM.Name)" 
            # Then and only then find the VM. Need to switch to the VM subscription if different.
            if ((Get-AzContext).Subscription.Id -ne $VM.id.Split('/')[2]) {
                Set-AzContext -Subscription $VM.Id.Split('/')[2]
            }
            $VMT=get-azVM -ResourceGroupName $VM.ResourceGroup -Name $VM.name
            $VMT.ApplicationProfile.GalleryApplications.Remove($app)
            Write-Output "Removed app from VM: $($VMT.Name)"
        }
    }
    #$vm.ApplicationProfile
    Write-Output "Updating VM: $($VM.Name)"
    Update-AzVM -VM $VMT -ResourceGroupName $VMT.ResourceGroupName -asjob
}
#endregion
# Check login
# import module(s)
# Resource graph
#region initialization
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
#endregion
#region AMAPolicySet
# AMA policy set removal
# Remove policy sets
if ($RemoveAMAPolicySet -or $RemoveAll) {
    "Removing AMA policy set."
    $inits=Get-AzPolicySetDefinition | where-object {$_.Metadata.MonitorStarterPacks -ne $null}
    foreach ($init in $inits) {
        "Removing policy set $($init.Id)"
        #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.Id
        $query=@"
        policyresources
        | where type == "microsoft.authorization/policyassignments"
        | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
        | where PolicyId == '$($init.Id)'
"@
        $assignments=Search-AzGraph -Query $query -UseTenantScope
        if ($assignments.count -ne 0)
        {
            "Removing assignments for $($init.Id) initiative."
            foreach ($assignment in $assignments) {
                "Removing assignment for $($assignment.name)"
                Remove-AzPolicyAssignment -Id $assignment.id
            }
        }
        Remove-AzPolicySetDefinition -Id $init.Id -Force
    }
}
else {
    "Skipping AMA policy set removal. Use -RemoveAMAPolicySet to remove them."
}
#endregion
#region Discovery
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
    $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG | where-object {$_.Tag.AdditionalProperties.MonitoringPackType -eq "Discovery"} -ErrorAction SilentlyContinue
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
    $pols=Get-AzPolicyDefinition | Where-Object {$_.Metadata.MonitoringPackType -eq "Discovery"}
    # retrive unique list of packs installed
    $packs=$pols.Metadata.MonitorStarterPacks | Select-Object -Unique # should be just discovery anyways in this case.
    "Found $($packs.count) packs with DCRs: $packs"
    # if ($RemoveTag) {
    #     "Removing packs with tag $RemoveTag."
    #     $pols=$pols | where-object {$_.Metadata.MonitorStarterPacks -eq $RemoveTag}
    # }
    foreach ($pack in $packs) {
        "Removing pack $pack."
        foreach ($pol in ($pols | Where-Object {$_.Metadata.MonitorStarterPacks -eq $pack}) ) {
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
                "Removing policy $($pol.Id) and assignments for pack $($pol.Metadata.MonitorStarterPacks)"
                #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.Id # Only works for the current subscription. Need to use resource graph.
                $query=@"
            policyresources
            | where type == "microsoft.authorization/policyassignments"
            | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
            | where PolicyId == '$($pol.Id)'
"@
                $assignments=Search-AzGraph -Query $query -UseTenantScope
                
                if ($assignments.count -ne 0)
                {
                    "Removing assignments for $($pol.Id)"
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
                "Removing policy definition for $($pol.Id)"
                Remove-AzPolicyDefinition -Id $pol.Id -Force
            }
            else {
                "Skipping pack $($pol.Name)"
            }
        }
    }
    $originalSub=(Get-AzContext).Subscription.Id
    Get-AzGallery -ResourceGroupName $RG | Where-Object {$_.Tags.MonitorStarterPacksComponents -ne $null} | ForEach-Object {
        "Finding apps..."
        $galleryApps=Get-AzGalleryApplication -GalleryName $_.Name -ResourceGroupName $RG
        "Found $($galleryApps.Count) apps."
        $gas=@()
        $gavs=@()
        foreach ($ga in $galleryApps) {
            $gas+=$ga.Id
            $gtemps=Get-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -ResourceGroupName $RG
            if ($gtemps) {$gavs+=$gtemps.Id}
        }
        if ($gavs.Count -gt 0 -and $RemoveDiscoveryVMApps) {
            #need an Azure Resource Graph query to get all VMs with apps.
            $query=@"
resources
| where type == "microsoft.compute/virtualmachines"
| where isnotempty(properties.applicationProfile.galleryApplications)
| project id, name, resourceGroup, applicationProfile=properties.applicationProfile    
"@
            $vmswithApps=Search-AzGraph -Query $query

            #$vmswithApps=Get-AzVM | Where-Object { $_.ApplicationProfile -ne $null}
            foreach ($VM in $vmswithApps) { 
                remove-appversions -vm $vm -appstoremove $gavs
            }
            # switch back to the original subscription
            Set-AzContext -Subscription $originalSub
        }
        elseif (!($RemoveDiscoveryVMApps) -and $gavs.Count -gt 0) {
            "There may applicattions installed in the VMs. Manual removal may be required."
        }
        # then go ahead and remove applications and gallery once all VMs are clear.
        foreach ($gav in $gavs) {
            $gaName=$gav.Split("/")[10]
            $gavName=$gav.Split("/")[12]
            "Removing $gav from $gaName"
            Remove-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $gaName -Name $gavName -ResourceGroupName $RG
        }
        foreach ($ga in $gas) {
            $gaName=$ga.Split("/")[10]
            "Removing $($ga)"
            Remove-AzGalleryApplication -GalleryName $_.Name -Name $gaName -ResourceGroupName $RG
        }
        "Removing gallery: $($_.Name)"
        Remove-AzGallery -Name $_.Name -ResourceGroupName $RG -Force
    } 
}
#endregion
#region Packs
# Remove policy assignments and policies
if ($RemovePacks -or $RemoveAll) {
    "Removing packs."
    # Gets all policies with the tag MonitorStarterPacks
    $pols=Get-AzPolicyDefinition | Where-Object {$_.Metadata.MonitorStarterPacks -ne $null -and $_.Metadata.MonitoringPackType -ne "Discovery"} 
    # retrive unique list of packs installed
    $packs=$pols.Metadata.MonitorStarterPacks | Select-Object -Unique
    "Found $($packs.count) packs from policies: $packs"
    # if ($RemoveTag) {
    #     "Removing packs with tag $RemoveTag."
    #     $pols=$pols | where-object {$_.Metadata.MonitorStarterPacks -eq $RemoveTag}
    # }
    # Remove policy sets and assignments
    "Removing policy sets."
    $inits=Get-AzPolicySetDefinition | where-object {$_.Metadata.MonitorStarterPacks -ne $null -and $_.Metadata.MonitoringPackType -ne "Discovery"}
    foreach ($init in $inits) {
        "Removing policy set $($init.Id)"
        #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.Id
        $query=@"
        policyresources
        | where type == "microsoft.authorization/policyassignments"
        | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
        | where PolicyId == '$($init.Id)'
"@
        $assignments=Search-AzGraph -Query $query -UseTenantScope
        if ($assignments.count -ne 0)
        {
            "Removing assignments for $($pol.Id)"
            foreach ($assignment in $assignments) {
                "Removing assignment for $($assignment.name)"
                Remove-AzPolicyAssignment -Id $assignment.id
            }
        }
        Remove-AzPolicySetDefinition -Id $init.Id -Force
    }
    foreach ($pol in ($pols | Where-Object {$_.Metadata.MonitorStarterPacks -ne $null}) ) {
        $remove=$true
        $pack=$pol.Metadata.MonitorStarterPacks
        "Removing $pack pack."
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
            "Removing policy $($pol.Id) and assignments for pack $pack"
            #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.Id # Only works for the current subscription. Need to use resource graph.
            $query=@"
        policyresources
        | where type == "microsoft.authorization/policyassignments"
        | extend AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId)
        | where PolicyId == '$($pol.Id)'
"@
            $assignments=Search-AzGraph -Query $query -UseTenantScope
            
            if ($assignments.count -ne 0)
            {
                "Removing assignments for $($pol.Id)"
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
            "Removing policy definition for $($pol.Id)"
            Remove-AzPolicyDefinition -Id $pol.Id -Force
        }
        else {
            "Skipping pack $($pol.Name)"
        }
    }
    # If something remains, clear all dead assignments in the current subscription
    #Get-AzRoleAssignment -scope "/subscriptions/$((Get-AzContext).Subscription)" | where-object {$_.ObjectType -eq 'unknown'}  | where-object {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | Remove-AzRoleAssignment
    # remove DCR associations
    $dcrs=Get-AzDataCollectionRule -ResourceGroupName $RG | Where-Object {($_.tag | convertfrom-json).MonitorStarterPacks -ne $null} 
    # retrive unique list of packs installed
    if ($dcrs) {
        $packs=($dcrs.tag | convertfrom-json).MonitorStarterPacks | select -Unique
        foreach ($pack in $packs) {
            "Removing pack $pack from DCRs."
            $query=@'
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]
| where isnotnull(properties.dataCollectionRuleId)
| project rulename=split(properties.dataCollectionRuleId,"/")[8],resourceName=split(resourceId,"/")[8],resourceId, ruleId=properties.dataCollectionRuleId, name
| where ruleId =~
'@
            $DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG | where-object {($_.Tag | convertfrom-json).MonitorStarterPacks -eq $pack}
            "Found $($DCRs.count) for $pack pack."
            foreach ($DCR in $DCRs)
            {
                "Working on $($DCR.name)"
                $searchQuery=$query + "'$($DCR.Id)'"
                "Looking for associations."
                ##$dcras=Search-AzGraph -Query $searchQuery -UseTenantScope
                $dcras=Get-AzDataCollectionRuleAssociation -DataCollectionRuleName $DCR.Name -ResourceGroupName $DCR.ResourceGroupName
                "Found $($dcras.count) associationsfor $($DCR.Name)."
                foreach ($dcra in $dcras) {
                    #"Removing DCR association $($dcra.rulename) for $($dcra.resourceId)"
                    "Removing DCR association $($dcra.Name) for $($dcra.Id)"
                    $resourceId=$dcra.Id.toLower().Split('/providers/microsoft.insights/')[0]   
                    Remove-AzDataCollectionRuleAssociation -TargetResourceId $resourceId -AssociationName $dcra.name
                }
                "Removing DCR $($DCR.Name)"
                Remove-AzDataCollectionRule -ResourceGroupName $DCR.Id.Split('/')[4] -Name $DCR.Name
            }
            # remove DCRs
            #Get-AzDataCollectionRule -ResourceGroupName $RG | Remove-AzDataCollectionRule
            # remove Tags from VMs.
            # remove monitor extensions (optional)
            # remove alert rules
        }
    }
    else {
        "No DCRs found in $RG resource group."
    }
    "Removing alerts."
    $Alerts=Get-AzResource -ResourceType "microsoft.insights/scheduledqueryrules" -ResourceGroupName $RG | Where-Object {$_.Tags.MonitorStarterPacks -ne $null}
    # if ($RemoveTag) {
    #     $Alerts=$Alerts | where-object {$_.Tags.MonitorStarterPacks -eq $RemoveTag}
    # }
    "Found $($Alerts.count) alerts for pack $pack"
    $Alerts | Remove-AzResource -Force -AsJob
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
if ($RemoveStorage) {
    "Removing storage account."
    Get-AzResource -ResourceType 'Microsoft.Storage/storageAccounts' -ResourceGroupName $RG | Remove-AzResource -Confirm
    }
    else {
        "Skipping storage account removal. Use -RemoveStorage to remove it."
}
if ($RemoveLAW) {
    "Removing log analytics workspace."
    $LAWS=Get-AzResource -ResourceType 'Microsoft.OperationalInsights/workspaces' -ResourceGroupName $RG
    foreach ($LAW in $LAWS) {
        Remove-AzOperationalInsightsWorkspace -ResourceGroupName $RG -Name $LAW.Name -ForceDelete -Confirm
    }
}
else {
    "Skipping log analytics workspace removal. Use -RemoveLAW to remove it."
}
if ($RemoveTag) {
    " Removing tag $RemoveTag from resources."
    " Not implemented yet."
}


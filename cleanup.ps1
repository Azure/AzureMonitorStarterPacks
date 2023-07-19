# remove log analytics - optional
# remove associations from rules
# remove resource group or remove each component by Tag.
# remove policies
# remove AzureMonitorStarterPacks from all resources

ARG Query:
# resources
# | where isnotempty(tags.MonitorStarterPacks)
# | project ['id'], type
# | union (policyresources
# | where isnotempty(properties.metadata.MonitorStarterPacks)|
# project id,type=tostring(split(id,"/")[4]))


# remove policy assignments and policies
$pols=Get-AzPolicyDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null} 
foreach ($pol in $pols) {
    "Removing policy $($pol.PolicyDefinitionId)"
    $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
    
    if ($assignments.count -ne 0)
    {
        "Removing assignments for $($pol.PolicyDefinitionId)"
        foreach ($assignment in $assignments) {
            $assignmentObjectId= Get-AzADServicePrincipal -Id $assignment.Identity.PrincipalId -ErrorAction SilentlyContinue
            Get-AzRoleAssignment | ? {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id} | Remove-AzRoleAssignment
            #$ras=Get-AzRoleAssignment | ? {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)" -and $_.ObjectId -eq $assignmentObjectId.Id}
            # -and $_. -eq $assignments.Identity.PrincipalId} | Remove-AzRoleAssignment
            "Removing assignment for $($assignment.Identity.PrincipalId)"
            Remove-AzPolicyAssignment -Id $assignment.PolicyAssignmentId
        }
        "Removing policy definition for $($pol.PolicyDefinitionId)"
        Remove-AzPolicyDefinition -Id $pol.PolicyDefinitionId -Force
    }
}
# Remove policy sets
$inits=Get-AzPolicySetDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null}
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
# remove DCR associations
# remove DCRs
$DCRs=Get-AzDataCollectionRule | ?{$_.Tags.MonitorStarterPacks -ne $null}
foreach ($DCR in $DCRs) {
    
    $dcras=Get-AzDataCollectionRuleAssociation -RuleName $DCR.Name -ResourceGroupName $DCR.Id.split('/')[4]
    foreach ($dcra in $dcras) {
        $dcra.ObjectId
        Remove-AzDataCollectionRuleAssociation -
    }
    "Removing DCR $($DCR.Name)"
    #Remove-AzDataCollectionRule -Name $DCR.Name -ResourceGroupName $DCR.ResourceGroupName
}

$allDCRa=Search-AzGraph -Query @'
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend dcrId=tostring(properties.dataCollectionRuleId)
| project dcrId, name,TargetResource=split(id,'/providers/Microsoft.Insights/')[0],resourceGroup
| where name has 'MonStar'
'@
foreach ($dcra in $allDCRa) {
    "Removing $($dcra.name) for $($dcra.TargetResource)"
    Remove-AzDataCollectionRuleAssociation -TargetResourceId $dcra.TargetResource -AssociationName $dcra.name
    #$dcr=Get-AzDataCollectionRule -Name $dcra.Name -ResourceGroupName $dcra.ResourceGroup
    # if ($dcr.Tags.MonitorStarterPacks -ne $null) {
    #     "Removing DCR $($dcr.Name)"
    #     #Remove-AzDataCollectionRule -Name $dcr.Name -ResourceGroupName $dcr.ResourceGroupName
    # }
}
# remove role assignments - if not removed it will fail to install again.
# Get-AzRoleAssignment | ? {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | where {$_.ObjectType -eq 'unknown'}  | Remove-AzRoleAssignment
# remove alert rules
# Get-AzResource -ResourceType "microsoft.insights/scheduledqueryrules" -ResourceGroupName AMonStarterPacks3 | Remove-AzResource -Force
# remove function app
# remove logic app
# remove workbook
# remove log analytics - optional
# remove resource group - optional
# remove action group(s)?
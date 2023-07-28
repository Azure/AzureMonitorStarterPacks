$RG="amonstarterpacks3"
#Order:
# Remove role associations from policy assignments
# Remove policy assignments and policies
# Remove policy sets and assignments
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
# If something remains, clear all dead assignments in the current subscription
Get-AzRoleAssignment -scope "/subscriptions/$((Get-AzContext).Subscription)" | where {$_.ObjectType -eq 'unknown'}  | where {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | Remove-AzRoleAssignment
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
$query=@'
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]
| where isnotnull(properties.dataCollectionRuleId)
| project rulename=split(properties.dataCollectionRuleId,"/")[8],resourceName=split(resourceId,"/")[8],resourceId, ruleId=properties.dataCollectionRuleId, name
| where ruleId =~
'@
$DCRs=Get-AzDataCollectionRule -ResourceGroupName $RG
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
Get-AzDataCollectionRule -ResourceGroupName $RG | Remove-AzDataCollectionRule
# remove Tags from VMs.
# remove monitor extensions (optional)
# remove alert rules
Get-AzResource -ResourceType "microsoft.insights/scheduledqueryrules" -ResourceGroupName $RG | Remove-AzResource -Force
# remove main solution (workbook, logic app, function app)
# remove function role assignments
# remove log analytics - optional
# Remove resource Group

ARG Query to check
# resources
# | where isnotempty(tags.MonitorStarterPacks)
# | project ['id'], type
# | union (policyresources
# | where isnotempty(properties.metadata.MonitorStarterPacks)|
# project id,type=tostring(split(id,"/")[4]))


# remove policy assignments and policies
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
# remove dead role assignments - if not removed it will fail to install again.
# Get-AzRoleAssignment | ? {$_.Scope -eq "/subscriptions/$((Get-AzContext).Subscription)"} | where {$_.ObjectType -eq 'unknown'}  | Remove-AzRoleAssignment
# remove action group(s)?
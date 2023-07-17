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
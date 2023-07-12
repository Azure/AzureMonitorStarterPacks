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
    $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
    if ($assignments.count -ne 0)
    {
        "Removing assignments for $($pol.PolicyDefinitionId)"
        $assignments | Remove-AzPolicyAssignment 
    }
    Remove-AzPolicyDefinition -Id $pol.PolicyDefinitionId
}
# Remove policy sets
$inits=Get-AzPolicySetDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null}
foreach ($init in $inits) {
    $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId
    if ($assignments.count -ne 0)
    {
        "Removing assignments for $($init.PolicySetDefinitionId)"
        $assignments | Remove-AzPolicyAssignment 
    }
    Remove-AzPolicySetDefinition -Id $init.PolicySetDefinitionId
}
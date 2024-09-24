# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# Write an information log with the current time.
Write-Host "PolicyManagement timer trigger function ran! TIME: $currentUTCtime"
$SolutionTag=$env:SolutionTag
$polStateQuery=@"
policyresources
| where ['type'] == 'microsoft.policyinsights/policystates'
| extend ComplianceState=tostring(properties.complianceState), PolicySetDefinitionName=tostring(properties.policySetDefinitionName)
| where isnotempty(PolicySetDefinitionName)
| where ComplianceState =~ "NonCompliant"
| summarize by PolicySetDefinitionName
| join kind= innerunique   (policyresources
| where ['type'] =~ "microsoft.authorization/policysetdefinitions" and isnotnull(properties.metadata.MonitorStarterPacks)
| project PolicySetDefinitionName=name, PolicySetDefinitionId=id, policyDefinitions=properties.policyDefinitions) on PolicySetDefinitionName
| project-away PolicySetDefinitionName1
"@
$inits=Search-AzGraph -Query $polStateQuery -UseTenantScope
#$inits=Get-AzPolicySetDefinition | Where-Object {$_.Metadata.$SolutionTag -ne $null} | Where-Object {$_.Name -in $polState.PolicySetDefinitionName}
$polStateQuery=@"
policyresources
| where ['type'] == 'microsoft.policyinsights/policystates'
| extend ComplianceState=tostring(properties.complianceState), PolicySetDefinitionName=tostring(properties.policySetDefinitionName), PolicyDefinitionName=tostring(properties.policyDefinitionName)
| where ComplianceState =~ "NonCompliant"
| summarize by PolicyDefinitionName
| join kind= innerunique   (policyresources
| where ['type'] =~ "microsoft.authorization/policydefinitions" and isnotnull(properties.metadata.MonitorStarterPacks) 
 and properties.metadata.initiativeMember != true
| project  PolicyDefinitionName=name, PolicyDefinitionId=id) on PolicyDefinitionName
| project-away PolicyDefinitionName1
"@
$pols=Search-AzGraph -Query $polStateQuery -UseTenantScope
#$pols=Get-AzPolicyDefinition | Where-Object {($_.Metadata.$SolutionTag -ne $null -or $_.Metadata.MonitorStarterPacksComponents -ne $null) -and $_.Metadata.initiativeMember -ne $true} | Where-Object {$_.Name -in $polState.PolicyDefinitionName}
"Found $($pols.Count) policies and $($inits.Count) policy sets to remediate"
# $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.$SolutionTag -ne $null -or $_.properties.Metadata.MonitorStarterPacksComponents -ne $null}
# $inits=Get-AzPolicySetDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null}

foreach ($pol in $pols) {
    "Policy $($pol.PolicyDefinitionId) is non-compliant"
    $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
    foreach ($assignment in $assignments) {
        "Starting remediation for $($assignment.DisplayName)"
        Start-AzPolicyRemediation -Name "$($pol.PolicyDefinitionName) remediation" -PolicyAssignmentId $assignment.id -ResourceDiscoveryMode ExistingNonCompliant -Scope $assignment.Scope
    }
}
foreach ($init in $inits) {
    "Policy set $($init.PolicySetDefinitionId) is non-compliant"
    #$assignment=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId -Scope "IntermediateRoot"
    $assignmentsQuery=@"
    policyresources
    | where type == 'microsoft.authorization/policyassignments'
    | extend policyDefinitionId=properties.policyDefinitionId, Scope=properties.scope
    | where policyDefinitionId == '$($init.PolicySetDefinitionId)'
"@
    $assignments=Search-AzGraph -Query $assignmentsQuery -UseTenantScope
    if ($assignments.Count -gt 0) {
        "Found $($assignments.Count) assignments for $($init.PolicySetDefinitionId)"
        $policiesInSet=$init.PolicyDefinitions | Select-Object -ExpandProperty policyDefinitionReferenceId
        #$policiesInSet
        foreach ($pol in $policiesInSet) {
            "Starting remediation for $($assignment.Id) policy $pol"
            foreach ($assignment in $assignments) {
                Start-AzPolicyRemediation -Name "$($pol) remediation" -PolicyAssignmentId $assignment.Id -PolicyDefinitionReferenceId $pol -Scope $assignment.Scope
            }
        }
    }
    else {
        "No assignment found for $($init.PolicySetDefinitionId)"
    }
}
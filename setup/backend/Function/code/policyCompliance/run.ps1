# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"
$SolutionTag=$env:SolutionTag

$polState=get-azpolicyState | Where-Object {$_.ComplianceState -eq 'NonCompliant'}

$pols=Get-AzPolicyDefinition | Where-Object {($_.properties.Metadata.$SolutionTag -ne $null -or $_.properties.Metadata.MonitorStarterPacksComponents -ne $null) -and $_.properties.Metadata.initiativeMember -ne $true} | Where-Object {$_.Name -in $polState.PolicyDefinitionName}
$inits=Get-AzPolicySetDefinition | Where-Object {$_.properties.Metadata.$SolutionTag -ne $null} | Where-Object {$_.Name -in $polState.PolicySetDefinitionName}
"Found $($pols.Count) policies and $($inits.Count) policy sets to remediate"

foreach ($pol in $pols ) {
    "Policy $($pol.PolicyDefinitionId) is non-compliant"
    $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
    foreach ($assignment in $assignments) {
        "Starting remediation for $($assignment.PolicyAssignmentId)"
        Start-AzPolicyRemediation -Name "$($pol.name) remediation" -PolicyAssignmentId $assignment.PolicyAssignmentId -ResourceDiscoveryMode ExistingNonCompliant
    }
}

foreach ($init in $inits) {
    "Remediating policy set $($init.PolicySetDefinitionId)."
    "Policy set $($init.PolicySetDefinitionId) is non-compliant"
    $assignment=Get-AzPolicyAssignment -PolicyDefinitionId $init.ResourceId
    if ($assignment) {
        $policiesInSet=$init.Properties.PolicyDefinitions | Select-Object -ExpandProperty policyDefinitionReferenceId
        #$policiesInSet
        foreach ($pol in $policiesInSet) {
            "Starting remediation for $($assignment.PolicyAssignmentId)"
            #Start-AzPolicyRemediation -Name "$($pol) remediation" -PolicyAssignmentId $assignment.PolicyAssignmentId -PolicyDefinitionReferenceId $pol # -ResourceDiscoveryMode ExistingNonCompliant
        }
    }
}


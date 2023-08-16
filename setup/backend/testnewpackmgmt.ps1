Write-Host "PowerShell HTTP trigger function processed a request."
$SolutionTag=$Request.Body.SolutionTag
$Action=$Request.Body.Action
# Interact with query parameters or the body of the request.
switch ($action) {
    'Remediate' {
        $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.$SolutionTag -ne $null} 
        foreach ($pol in $pols) {
            $compliance=(get-AzPolicystate -PolicyDefinitionName $pol.Name).ComplianceState
            if ($compliance -eq "NonCompliant") {
                "Policy $($pol.PolicyDefinitionId) is non-compliant"
                $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
                foreach ($assignment in $assignments) {
                    "Starting remediation for $($assignment.PolicyAssignmentId)"
                    Start-AzPolicyRemediation -Name "$($pol.name) remediation" -PolicyAssignmentId $assignment.PolicyAssignmentId -ResourceDiscoveryMode ExistingNonCompliant
                }
            }
            else {
                "Policy $($pol.PolicyDefinitionId) is compliant"
            }

        }
                    # $inits=Get-AzPolicySetDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null}
            # foreach ($init in $inits) {
            #     "Retrieving policy set $($init.PolicySetDefinitionId) compliance:"
            #     $compliance=(get-AzPolicystate -PolicySetDefinitionName $init.Name).ComplianceState
            #     $assignments=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId
            #     if ($assignments.count -ne 0)
            #     {
            #         "Removing assignments for $($init.PolicySetDefinitionId)"
            #         $assignments | Remove-AzPolicyAssignment 
            #     }
            #     Remove-AzPolicySetDefinition -Id $init.PolicySetDefinitionId
            # }
    }
    'Scan' {
        Start-AzPolicyComplianceScan -AsJob
    }
    'Default' {
        "No action specified. Bye."
    }
}

using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$userIdentityId=$ENV:PacksUserManagedId # Comes from the Function App settings (Configuration)
$SolutionTag=$Request.Body.SolutionTag
$action=$Request.Body.Action
"Action Selected: $action"
# Interact with query parameters or the body of the request.
switch ($action) {
    'Remediate' {
        $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.$SolutionTag -ne $null} 
        foreach ($pol in $pols) {
            $compliance=(get-AzPolicystate | where-object {$_.PolicyDefinitionName -eq $pol.Name}).ComplianceState
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
    'Assign' {
        "Into selected Assign action."
        $policies=$Request.Body.policies | ConvertFrom-Json
        $scopes=$Request.Body.Scopes | ConvertFrom-Json
        $policies
        $scopes
        foreach ($policy in $policies) {
            $policyName=$policy.Name
            $policyDefinition=Get-AzPolicyDefinition -Id $policy.PolicyId
            foreach ($scope in $scopes) {
                $assignment=New-AzPolicyAssignment -Name "Assign-$policyName" -DisplayName "Assignment-$policyName" -Scope $scope.id `
                -PolicyDefinition $policyDefinition -IdentityType UserAssigned -IdentityId $userIdentityId -Location eastus
                "Created assignment:"
                $assignment
            }
        }
    }
    'Unassign' {
        "Into selected Assign action."
        $policies=$Request.Body.policies | ConvertFrom-Json
        #$scopes=$Request.Body.Scopes | ConvertFrom-Json
        $policies
        #$scopes
        foreach ($policy in $policies) {
            $policyName=$policy.Name
            "Scope: $($policy.scope)"
            "Assignment Name: $($policy.AssignmentName)"
            "Assignment Level: $($policy.ScopeLevel)"
            if ($policy.ScopeLevel -eq 'Sub') {
                $subId=$policy.Scope.split('/')[2]
                "Sub Id: $subId"
                if ($subId -ne (get-azcontext).Subscription.Id) {
                    "Changing subscription to $($policy.Scope)."
                    Select-AzSubscription -subscriptionId $subId
                }
            }
            else {
                "Keeping current context. "
            }
            Get-AzPolicyAssignment -Name $policy.AssignmentName -Scope $policy.scope | Remove-AzPolicyAssignment
        }
    }
    'Default' {
        "No action specified. Bye."
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

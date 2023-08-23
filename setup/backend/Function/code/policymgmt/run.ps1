using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$SolutionTag=$Request.Body.SolutionTag
$action=$Request.Body.Action
"Action Selected: $action"
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
    'Assign' {
        "Into selected Assign action."
        $policies=$Request.Body.policies
        $scopes=$Request.Body.Scopes
        $policies
        $scopes
        foreach ($policy in $policies) {
            $policyName=($policy.id).split("/")[-1]
            $policyDefinition=Get-AzPolicyDefinition -Id $policy.id
            $roleDefinitions=($policyDefinition.Properties.PolicyRule.then.details.roleDefinitionIds).split("/")[4]
            #$assignment=New-AzPolicyAssignment -Name "Deploy_activitylog_NSG_Delete" -DisplayName "Deploy_activitylog_NSG_Delete" -Scope $listOfScopes[0] -PolicyDefinition $policyDefinition `
                #-IdentityType SystemAssigned -Location eastus
            foreach ($scope in $scopes) {
                $assignment=New-AzPolicyAssignment -Name "Assignment-$policyName" -DisplayName "Assignment-$policyName" -Scope $scope.id -PolicyDefinition $policyDefinition -IdentityType SystemAssigned -Location eastus
                "Created assignment:"
                $assignment
                #Add loop to try and get principal Id.
                $foundObject=$false
                $attempts=10
                for ($i=$attempts;$i -ne 0; $i--) {
                    if (get-azadserviceprincipal -ObjectId $assignment.Identity.PrincipalId) {
                        $i=0
                        $foundObject=$true
                    }
                    else {
                        start-sleep 2
                    }
                }
                if ($foundObject) {
                    foreach ($rd in $roleDefinitions) {
                        New-AzRoleAssignment -ObjectId $assignment.Identity.PrincipalId -RoleDefinitionId $rd -Scope $scope.id -Description "Role assignment for policy assignment $policyName"
                    }
                }

            }
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

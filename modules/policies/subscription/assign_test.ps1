
# $listOfScopes=@('/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca')
# $policyDefinitionId="/providers/Microsoft.Management/managementGroups/FehseCorpRoot/providers/Microsoft.Authorization/policyDefinitions/Deploy_activitylog_NSG_Delete"
$policies=@"
[{"id":"/providers/Microsoft.Management/managementGroups/FehseCorpRoot/providers/Microsoft.Authorization/policyDefinitions/Deploy_activitylog_KeyVault_Delete","Name":"Deploy_activitylog_KeyVault_Delete","Display Name":"[DINE] Deploy Activity Log Key Vault Delete Alert"},{"id":"/providers/Microsoft.Management/managementGroups/FehseCorpRoot/providers/Microsoft.Authorization/policyDefinitions/Deploy_activitylog_LAWorkspace_KeyRegen","Name":"Deploy_activitylog_LAWorkspace_KeyRegen","Display Name":"[DINE] Deploy Activity Log LA Workspace Regenerate Key Alert"}]
"@ | ConvertFrom-Json
$scopes=@"
[{"name":"JF-AIRS-Internal","id":"/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca","subscriptionId":"6c64f9ed-88d2-4598-8de6-7a9527dc16ca","type":"subscriptions"}]
"@ | ConvertFrom-Json
foreach ($policy in $policies) {
    $policyName=($policy.id).split("/")[-1]
    $policyDefinition=Get-AzPolicyDefinition -Id $policy.id
    $roleDefinitions=($policyDefinition.Properties.PolicyRule.then.details.roleDefinitionIds).split("/")[4]
    #$assignment=New-AzPolicyAssignment -Name "Deploy_activitylog_NSG_Delete" -DisplayName "Deploy_activitylog_NSG_Delete" -Scope $listOfScopes[0] -PolicyDefinition $policyDefinition `
        #-IdentityType SystemAssigned -Location eastus
    foreach ($scope in $scopes) {
        $assignment=New-AzPolicyAssignment -Name "Assignment-$policyName" -DisplayName "Assignment-$policyName" -Scope $scope.id -PolicyDefinition $policyDefinition -IdentityType SystemAssigned -Location eastus
        foreach ($rd in $roleDefinitions) {
            New-AzRoleAssignment -ObjectId $assignment.Identity.PrincipalId -RoleDefinitionId $rd -Scope $scope.id -Description "Role assignment for policy assignment $policyName"
        }
    }
}


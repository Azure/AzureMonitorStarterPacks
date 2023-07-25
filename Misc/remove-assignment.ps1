param (
    [Parameter(Mandatory=$true)]
    [string]$policyAssignmentId,
    [Parameter(Mandatory=$true)]
    [string]$scope
)
$PAs=Get-AzPolicyAssignment -Id $policyAssignmentId | Where-Object {$_.Properties.scope -eq $scope}
foreach ($PA in $PAs) {
    Get-AzRoleAssignment | ? {$_.properties.Scope -eq $scope -and $_.RoleAssignmentId -eq $assignmentObjectId} #| Remove-AzRoleAssignment
}
#Remove-AzPolicyAssignment -Id $assignment.PolicyAssignmentId -WhatIf

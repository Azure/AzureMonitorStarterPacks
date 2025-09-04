# Description: This script will remove any Azure RBAC Role Assignments that have an 'Unknown' Type.
$OBJTYPE = "Unknown"

#Find and Export-to-CSV Azure RBAC Role Assignments of 'Unknown' Type
Get-AzRoleAssignment | Where-Object {$_.ObjectType.Equals($OBJTYPE)}| foreach {
    $object = $_.ObjectId
    $roledef = $_.RoleDefinitionName
    $rolescope = $_.Scope
    Remove-AzRoleAssignment -ObjectId $object -RoleDefinitionName $roledef -Scope $rolescope   
}

# Description: This script will remove any Azure RBAC Role Assignments that have an 'Unknown' Type.
$OBJTYPE = "Unknown"
$ura= Get-AzRoleAssignment | Where-Object {$_.ObjectType.Equals($OBJTYPE)}
Write-host "Found $($ura.Count) Role Assignments of type $OBJTYPE"
if ($ura.Count -eq 0) {
    Write-Host "No Role Assignments of type $OBJTYPE found."
    exit
}
else {
    #ask for confirmation to remove the role assignments
    $confirmation = Read-Host "Are you sure you want to remove these role assignments? (Y/N)"
    if ($confirmation -ne "Y") {
        Write-Host "Exiting without removing role assignments."
        exit
    }
    else {
        #Find and Export-to-CSV Azure RBAC Role Assignments of 'Unknown' Type
        $ura | foreach {
            $object = $_.ObjectId
            $roledef = $_.RoleDefinitionName
            $rolescope = $_.Scope
            Remove-AzRoleAssignment -ObjectId $object -RoleDefinitionName $roledef -Scope $rolescope   
        }
    }
}

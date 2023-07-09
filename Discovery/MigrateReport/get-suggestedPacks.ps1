$recommendedPacks=@()
"Reading packs."
$packs=get-content ./Packs/packs.json | ConvertFrom-Json | Where-Object {$_.RoleName -ne $null}
"Reading server roles (migrate report)"
$serverRoles=import-csv ./Discovery/MigrateReport/roles.csv
foreach ($pack in $packs)
{   
    "Pack: $($pack.PackName)"
    $rolename=$pack.RoleName
    "RoleName: $rolename"
    "Servers:"
    $servers=$serverRoles | Where-Object {$_.Feature -eq $rolename} | Select-Object MachineName
    if ($servers.count -gt 0)
    {
        $servers | Select-Object MachineName
        $recommendedPacks+=$pack
    }
}
"`n"
"Reading software application inventory."
$software=import-csv ./Discovery/MigrateReport/applications.csv
$packs=get-content ./Packs/packs.json | ConvertFrom-Json | Where-Object {$_.PackageName -ne $null}
"`n"
foreach ($pack in $packs)
{   
    "Pack: $($pack.PackName)"
    $appname=$pack.PackageName
    "Application: $appname"
    "Servers:"
    $servers=$software | Where-Object {$_.Application -eq $appname} | Select-Object MachineName
    if ($servers.count -gt 0)
    {
        $servers | Select-Object MachineName
        $recommendedPacks+=$pack
    }
}
Write-Output "Recommended packs:" #-ForegroundColor Green
$recommendedPacks.PackName

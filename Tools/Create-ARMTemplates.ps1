# Get all the subfolders recursively
# First update main solution files
<#
{
            "Folder":"",
            "File":""
        }
#>
$currentFolder= Get-Location
$mainMonstarPacksFiles = @"
    [
        {
            "Folder":"./setup/CustomSetup",
            "File":"monstar.bicep"
        },
        {
            "Folder":"./Packs/IaaS",
            "File":"AllIaaSPacks.bicep"
        },
        {
            "Folder":"./Packs/IaaS/WinOS",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/LxOS",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/IIS",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/IIS2016",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/DNS2016",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/PS2016",
            "File":"monitoring.bicep"
        },
        {
            "Folder":"./Packs/IaaS/Nginx",
            "File":"monitoring.bicep"
        }
]
"@ | ConvertFrom-Json
foreach ($file in $mainMonstarPacksFiles) {
    Set-Location -Path $file.Folder
    bicep build $file.File
    Set-Location $currentFolder  
}

Set-Location 'Packs/IaaS'
$DestinationPath='./Grafana.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
Compress-Archive -Path './WinOS/Azure Monitor Start Pack - Windows Operating System-1692086853589.json' -DestinationPath $DestinationPath -Update
Compress-Archive -Path './LxOS/Azure Monitor Start Pack _ Linux Operating System-1692092035812.json' -DestinationPath $DestinationPath -Update
Compress-Archive -Path './IIS/Azure Monitor Starter Pack _ IIS-1692341727216.json' -DestinationPath $DestinationPath -Update
Compress-Archive -Path './DNS2016/Azure Monitor Starter Pack _ DNS2016.json' -DestinationPath $DestinationPath -Update
Compress-Archive -Path './Nginx/Azure Monitor Starter Pack _ NGINX-1692341707202.json' -DestinationPath $DestinationPath -Update

Set-Location $currentFolder  
Set-Location 'setup/backend/Function/code'
$DestinationPath='./backend.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
compress-archive * $DestinationPath -Force

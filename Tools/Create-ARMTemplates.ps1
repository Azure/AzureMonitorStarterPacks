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

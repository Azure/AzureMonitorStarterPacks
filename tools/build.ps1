# Get all the subfolders recursively
# First update main solution files
<#
{
            "Folder":"",
            "File":""
        }
#>
$currentFolder= Get-Location
$mainMonstarPacksFiles = Get-Content -Path './tools/build.json' | ConvertFrom-Json

foreach ($file in $mainMonstarPacksFiles) {
    Set-Location -Path $file.Folder
    bicep build $file.File
    Set-Location $currentFolder  
}
# Grafana Dashaboards
Set-Location "./Packs"
$DestinationPath='./Grafana.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
$grafanaFiles = Get-ChildItem -Path './' -Recurse -Include 'grafana*.json'
foreach ($file in $grafanaFiles) {
    Compress-Archive -Path $file.FullName -DestinationPath $DestinationPath -Update
}
# Compress-Archive -Path './WinOS/Azure Monitor Start Pack - Windows Operating System-1692086853589.json' -DestinationPath $DestinationPath -Update
# Compress-Archive -Path './LxOS/Azure Monitor Start Pack _ Linux Operating System-1692092035812.json' -DestinationPath $DestinationPath -Update
# Compress-Archive -Path './IIS2016/Azure Monitor Starter Pack _ IIS-1692341727216.json' -DestinationPath $DestinationPath -Update
# Compress-Archive -Path './IIS/Azure Monitor Starter Pack _ IIS-1692341727216.json' -DestinationPath $DestinationPath -Update
# Compress-Archive -Path './DNS2016/Azure Monitor Starter Pack _ DNS2016.json' -DestinationPath $DestinationPath -Update
# Compress-Archive -Path './Nginx/Azure Monitor Starter Pack _ NGINX-1692341707202.json' -DestinationPath $DestinationPath -Update
# Function App code.
Set-Location $currentFolder
Set-Location 'setup/backend/Function/code'
$DestinationPath='../../backend.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
compress-archive * $DestinationPath -Force 
# Discovery code
Set-Location $currentFolder
Set-Location ./setup/discovery/Linux/client
tar -cvf ../discover.tar *
Set-Location ../../Windows/client
Compress-Archive -Path ./* -DestinationPath ../discover.zip -Update
# ADDS Code
Set-Location $currentFolder
Set-Location ./Packs/IaaS/ADDS/client
Compress-Archive -Path ./* -DestinationPath ../addscollection.zip -Update
Set-Location $currentFolder


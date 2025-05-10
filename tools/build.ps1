# Get all the subfolders recursively
# First update main solution files
<#
{
            "Folder":"",
            "File":""
        }
#>
# before building the bicep files, we need to zip the json files in the ./Packs folder
$currentFolder= Get-Location
Set-Location ".\Packs"
# get all files in the current directory only
$packsFiles = Get-ChildItem -Path './' -Name '*.json'
foreach ($file in $packsFiles) {
    #compress each file individually into a zip file
    $DestinationPath = $file.Replace('.json', '.zip')
    Compress-Archive -Path $file -DestinationPath $DestinationPath -Update
}
Set-Location $currentFolder

# Grafana Dashaboards
Set-Location "./Packs"
$DestinationPath='./Grafana.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
$grafanaFiles = Get-ChildItem -Path './' -Recurse -Include 'grafana*.json'
foreach ($file in $grafanaFiles) {
    Compress-Archive -Path $file.FullName -DestinationPath $DestinationPath -Update
}
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
# Cliente applications for existing packs
# 
Set-Location $currentFolder
# Fetch all folders in ./Packs
$folders = Get-ChildItem -Path './Packs' -Directory
# Loop through each folder and check for a 'client' subfolder
foreach ($folder in $folders) {
    $clientFolder = Join-Path -Path $folder.FullName -ChildPath 'client'
    if (Test-Path -Path $clientFolder) {
        Set-Location -Path $clientFolder
        $DestinationPath = "../../applications/$($folder.Name).zip"
        Remove-Item $DestinationPath -ErrorAction SilentlyContinue
        Compress-Archive -Path ./* -DestinationPath $DestinationPath -Update
    }
}
# Create a modules zip to be uploaded. For now, only alerts and DCRs are included.
Set-Location $currentFolder
Set-Location ./modules
$DestinationPath = './modules.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
Compress-Archive -Path ./alerts/*.bicep -DestinationPath $DestinationPath -Update
Compress-Archive -Path ./DCRs/*.bicep -DestinationPath $DestinationPath -Update
Set-Location $currentFolder
#All pack applications are zipped and ready to be uploaded to the storage account.
Set-Location ./Packs/applications
# get all zip files and zip into a single applications.zip file
$DestinationPath = './applications.zip'
Remove-Item $DestinationPath -ErrorAction SilentlyContinue
Compress-Archive -Path ./*.zip -DestinationPath $DestinationPath -Update
# Compress-Archive -Path ./* -DestinationPath ../../applications/addscollection.zip -Update
Set-Location $currentFolder

$mainMonstarPacksFiles = Get-Content -Path './tools/build.json' | ConvertFrom-Json

foreach ($file in $mainMonstarPacksFiles) {
    Set-Location -Path $file.Folder
    bicep build $file.File
    Set-Location $currentFolder  
}
# Get all the subfolders recursively
# First update main solution files
$mainMonstarPacksFiles = @(
    [
        {
            "Folder"="./setup/CustomSetup",
            "File":"monstar.bicep"
        },

    "./setup/CustomSetup/monstar.bicep"
    "./Packs/IaaS/AllIaaSPacks.bicep"
) 
foreach ($file in $mainMonstarPacksFiles) {
    Set-Location -Path $file.DirectoryName
    bicep build monitoring.bicep   
}
# Then update packs.
Set-Location -Path ./Packs
$subfolders = Get-ChildItem -Path . -Recurse -Directory
$filelist= Get-ChildItem -Path . -Include "monitoring.bicep" -Recurse
# Loop through each subfolder

foreach ($file in $filelist) {
    Set-Location -Path $file.DirectoryName
    bicep build monitoring.bicep   
}

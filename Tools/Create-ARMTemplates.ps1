# Get all the subfolders recursively
$subfolders = Get-ChildItem -Path . -Recurse -Directory
$filelist= Get-ChildItem -Path . -Include "monitoring.bicep" -Recurse
# Loop through each subfolder

foreach ($file in $filelist) {
    Set-Location -Path $file.DirectoryName
    bicep build monitoring.bicep   
}

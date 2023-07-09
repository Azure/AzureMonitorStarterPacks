# Parameter help description
param
(
[Parameter(Mandatory=$true,HelpMessage="Datetime stamp for the discovery run")]
[string]
$runTime)

$discoveryFolder="c:\WindowsAzure\Discovery"
#$runTime=(get-date).tostring("yyyyMMddHH")
if ((get-item $discoveryFolder -ErrorAction SilentlyContinue)) { 
    "Ok.Folder already exists" 
} 
else {
    "Creating folder $discoveryFolder and subfolders." 
    mkdir $discoveryFolder 
    #mkdir "$discoveryFolder\logs"
    #mkdir "$discoveryFolder\old"
}

$features=Get-WindowsFeature | Where-Object {$_.InstallState -eq 'Installed'} | Select-Object Name, DisplayName, FeatureType, Depth
$features | foreach { "$runTime $($_.Name),$($_.DisplayName),$($_.FeatureType),$($_.Depth)" } | Out-File "$discoveryFolder\installedFeatures.csv" -Append -Encoding utf8
#$features | Add-Member -NotePropertyName 'RunTime' -NotePropertyValue $runTime -PassThru | Export-csv -Path "$discoveryFolder\installedFeatures.csv" -Append -Encoding ASCII -
#$features | ConvertTo-Json | Out-File "$discoveryFolder\installedFeatures.json"
$apps=Get-WmiObject -Class Win32_Product | Select-Object Name, Vendor, Caption 
$apps | foreach {"$runTime $($_.Name),$($_.Vendor),$($_.Caption)"} | Out-File "$discoveryFolder\installedAppsWMI.csv" -Append -Encoding utf8
#$apps | Add-Member -NotePropertyName 'RunTime' -NotePropertyValue $runTime -PassThru | Export-csv -Path "$discoveryFolder\installedAppsWMI.csv" -Append -Encoding ASCII
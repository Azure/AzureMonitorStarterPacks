# Parameter help description
$runTime=get-date -Format "o"
#(get-date).tostring("yyyy-MM-dd HH:mm:ss")

$discoveryFolder="c:\WindowsAzure\Discovery"
#$runTime=(get-date).tostring("yyyyMMddHH")
if ((get-item $discoveryFolder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file DiscoverLog.txt -Append
} 
else {
    "$runTime : Creating folder $discoveryFolder and subfolders."  | out-file DiscoverLog.txt -Append
    mkdir $discoveryFolder 
    #mkdir "$discoveryFolder\logs"
    #mkdir "$discoveryFolder\old"
}

$features=Get-WindowsFeature| Where-Object {$_.InstallState -eq 'Installed'} | Select-Object Name, DisplayName, FeatureType, Depth #| foreach { "$runTime $($_.Name),$($_.DisplayName),$($_.FeatureType),$($_.Depth)" }
if ($features.count -gt 0) {
    # Runtime,Name, Caption, Vendor, Type, Platform
    $features | ForEach-Object { "$runTime,$($_.Name),$($_.Caption),Microsoft,$($_.FeatureType),Windows" } | Out-File "$discoveryFolder\installedFeatures.csv" -Append -Encoding utf8
}
else {
    "$runTime : No featues found." | out-file DiscoverLog.txt -Append
}
#$features | Add-Member -NotePropertyName 'RunTime' -NotePropertyValue $runTime -PassThru | Export-csv -Path "$discoveryFolder\installedFeatures.csv" -Append -Encoding ASCII -
#$features | ConvertTo-Json | Out-File "$discoveryFolder\installedFeatures.json"
$apps=Get-WmiObject -Class Win32_Product | Select-Object Name, Vendor, Caption 
if ($apps.count -gt 0) {
    $apps | ForEach-Object {"$runTime,$($_.Name),$($_.Caption),$($_.Vendor),Application,Linux"} | Out-File "$discoveryFolder\installedAppsWMI.csv" -Append -Encoding utf8
}
else {
    "$runTime : No apps found." | out-file DiscoverLog.txt -Append
}
#$apps | Add-Member -NotePropertyName 'RunTime' -NotePropertyValue $runTime -PassThru | Export-csv -Path "$discoveryFolder\installedAppsWMI.csv" -Append -Encoding ASCII
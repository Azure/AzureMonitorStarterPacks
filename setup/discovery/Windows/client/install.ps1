# Create discovery folder
$DiscoveryFolder="c:\windowsAzure\Discovery"
if ((get-item $discoveryFolder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file DiscoverLog.txt -Append
}
else {
    mkdir $DiscoveryFolder
}
#Expand-Archive .\discover.zip
copy discover.ps1 $DiscoveryFolder
Register-ScheduledTask -Xml (get-content ./DiscoveryTask.xml | out-string) -TaskName "Monstar Packs Discovery" -Force -User System -TaskPath "\"
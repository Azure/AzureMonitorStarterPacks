# Create discovery folder
$Folder="c:\windowsAzure\ADDS"
if ((get-item $discoveryFolderFolder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file DiscoverLog.txt -Append
}
else {
    mkdir $Folder
}
#Expand-Archive .\discover.zip
copy adcollect.ps1 $Folder
Register-ScheduledTask -Xml (get-content ./addscollectiontask.xml | out-string) -TaskName "AD DS Collection Task" -Force -User System -TaskPath "\"
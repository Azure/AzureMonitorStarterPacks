$Folder="c:\windowsAzure\ADDS"
$TaskName="AD DS Collection Task"
$TaskFileName="addscollectiontask.xml"
if ((get-item $Folder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file DiscoverLog.txt -Append
}
else {
    mkdir $Folder
}
#Expand-Archive .\discover.zip
Copy-Item adcollect.ps1 $Folder
Register-ScheduledTask -Xml (get-content ./$TaskFileName | out-string) -TaskName "$TaskName" -Force -User System -TaskPath "\"
$Folder="c:\windowsAzure\CertsW"
if ((get-item $Folder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file Certificates.txt -Append
}
else {
    mkdir $Folder
}
#Expand-Archive .\discover.zip
copy certcollect.ps1 $Folder
Register-ScheduledTask -Xml (get-content ./certcollectiontask.xml | out-string) -TaskName "Certificates Win Collection Task" -Force -User System -TaskPath "\"
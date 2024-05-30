# Parameter help description
$runTime=get-date -Format "o"
#(get-date).tostring("yyyy-MM-dd HH:mm:ss")

$monitoringfolder="c:\WindowsAzure\certw"
#$runTime=(get-date).tostring("yyyyMMddHH")
if ((get-item $monitoringfolder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file certw.txt -Append
} 
else {
    "$runTime : Creating folder $monitoringfolder and subfolders."  | out-file DiscoverLog.txt -Append
    mkdir $monitoringfolder 
}


$now=get-date
$soon=$now.AddDays(-30) # two wekks
$expiredcerts=Get-ChildItem Cert:\LocalMachine\My  -Recurse | Where-Object {$_.NotAfter -lt $now }  # | ? {$_.location -eq 'LocalMachine'}
$soontoexpire=Get-ChildItem Cert:\LocalMachine\My  -Recurse | Where-Object {$_.NotAfter -lt $soon }  # | ? {$_.location -eq 'LocalMachine'}
$soontoexpire | Select-Object NotBefore, Subject, Issue, @{
    Name="RunTime"
    Expression={$runTime}
} | Export-Csv 'soontoexpire.csv' -Append

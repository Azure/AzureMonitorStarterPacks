# adcollect.ps1
# This script collects ADDS metrics and writes them to a file
# The file is then collected by the Azure Monitor agent and sent to Azure Monitor

# Parameter help description
$runTime=get-date -Format "o"
#(get-date).tostring("yyyy-MM-dd HH:mm:ss")

$monitoringfolder="c:\WindowsAzure\ADDS"
#$runTime=(get-date).tostring("yyyyMMddHH")
if ((get-item $monitoringfolder -ErrorAction SilentlyContinue)) { 
    "$runTime : Ok.Folder already exists" | out-file DiscoverLog.txt -Append
} 
else {
    "$runTime : Creating folder $monitoringfolder and subfolders."  | out-file DiscoverLog.txt -Append
    mkdir $monitoringfolder 
}
$ADMetricLogfile="AdMetricLog.csv"
# Gets the current free space on the disk drive that holds the AD log file
$LogFileRegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\"
$sPathLog=(Get-ItemProperty -Path $LogFileRegKey -Name "Database log files path")."Database log files path"
$volinfo=get-volume -DriveLetter $sPathLog[0]
# Runtime, MetricName, Val, Tags
$tags=@"
{"vm.azm.ms/mountId":"$($volinfo.driveletter):","vm.azm.ms/volSize":"$($volinfo.Size)","vm.azm.ms/logFilePath":"$sPathLog"}
"@
"$runTime,ADLogFileDriveDiskSpacePctUsed,$([math]::round($volinfo.SizeRemaining/$volinfo.Size*100,2)),$tags" | Out-File "$monitoringfolder\$ADMetricLogfile" -Append -Encoding utf8

# Gets the current free space on the disk drive that holds the AD database file
# "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\DSA Database File"
$LogFileRegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\"
$sPathLog=(Get-ItemProperty -Path $LogFileRegKey -Name "DSA Database File")."DSA Database File"
$volinfo=get-volume -DriveLetter $sPathLog[0]
$tags=@"
{"vm.azm.ms/mountId":"$($volinfo.driveletter):","vm.azm.ms/volSize":"$($volinfo.Size)","vm.azm.ms/logFilePath":"$sPathLog"}
"@
"$runTime,ADDSADDBDrivePctFree,$([math]::round($volinfo.SizeRemaining/$volinfo.Size*100,2)),$tags" | Out-File "$monitoringfolder\$ADMetricLogfile" -Append -Encoding utf8

# Gets the current size of the ntds.dit file
$LogFileRegKey = "HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\Parameters\"
$sPathLog=(Get-ItemProperty -Path $LogFileRegKey -Name "DSA Database File")."DSA Database File"
$fileSize=(get-Item $sPathLog).Length
$volinfo=get-volume -DriveLetter $sPathLog[0]
$tags=@"
{"vm.azm.ms/mountId":"$($volinfo.driveletter):","vm.azm.ms/logFilePath":"$sPathLog"}
"@
"$runTime,ADDitFileSize,$fileSize,$tags" | Out-File "$monitoringfolder\$ADMetricLogfile" -Append -Encoding utf8
# Gets L&F items
$oRoot = [adsi]"LDAP://rootdse"
$strDNSDomain=$oRoot.defaultNamingContext
$Provider = "ADsDSOObject"
$oCmdText = "Select Name From 'LDAP://CN=LostAndFound,$strDNSDomain'"

$oConnection = New-Object -comobject "ADODB.Connection"
$oConnection.Provider=$Provider
$oConnection.Open("Active Directory Provider")
$oCommand = New-Object -comobject "ADODB.Command"
$oCommand.CommandText=$oCmdText
$oCommand.ActiveConnection=$oConnection
$RecordCount=($oCommand.Execute()).RecordCount

$tags=@"
{"vm.azm.ms/ADLFDomain":"$strDNSDomain"}
"@
"$runTime,ADDSLFObjCount,$RecordCount,$tags" | Out-File "$monitoringfolder\$ADMetricLogfile" -Append -Encoding utf8

# get, for exmaple, 2016 MP from https://systemcenter.wiki/?ShowManagementPack=Microsoft.Windows.Server.2016.Monitoring&Version=10.1.0.6
# Save to a .xml file
[xml]$mp=get-content ./Misc/SCOMMPs/IIS-2012.xml
# Enabled Rules (not monitors...)
$enabled_Rules=$mp.ManagementPack.Monitoring.Rules.Rule | ? {$_.Enabled -eq $true}
# List performance Rules details:
$enabled_Rules.Datasources.Datasource | ? {$_.ID -eq 'PerformanceDS'} | ft ObjectName, CounterName, Frequency
# Create bicep compatible array
$enabled_Rules.Datasources.Datasource | ? {$_.ID -eq 'PerformanceDS'} | Select-Object ObjectName, CounterName, Frequency | foreach {"'\\{0}\\{1}'"-f $_.ObjectName, $_.CounterName}
$frequencies=$enabled_Rules.Datasources.Datasource | ? {$_.ID -eq 'PerformanceDS'} | Select-Object  Frequency -Unique
$counters=@()
foreach ($frequency in $frequencies)
{
    #$frequency
    $counters=@($enabled_Rules.Datasources.Datasource | ? {$_.ID -eq 'PerformanceDS' -and $_.Frequency -eq $frequency.Frequency} | Select-Object ObjectName, CounterName, Frequency | foreach {"'\\{0}\\{1}'"-f $_.ObjectName, $_.CounterName}) | Out-String
$rule=@"
    {
        streams: [
            'Microsoft-Perf'
        ]
        samplingFrequencyInSeconds: $($frequency.Frequency)
        scheduledTransferPeriod: 'PT5M'
        counterSpecifiers: [
            $counters
        ]
        name: 'PerfCountersDataSource'
    }
"@
$rule
}

break
# read event based rules
$enabled_Rules.Datasources.Datasource | ? {$_.ID -eq 'EventDS'}

#



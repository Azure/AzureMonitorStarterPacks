#$iisevents=get-content ./iisevents.txt
$filename="./IIS-2012.xml"
$rulePrefix="IIS-2012"
$iisevents=import-csv -Path ./IIS-2012.xml-AlertRules.csv | Where-Object {$_.Calculated -ne ""}
$basestring="Event | where "
$eventstring1="EventID in ("
#$iisevents
    # for each line, find the Source and the event ids
$i=0
$alertslist="var alertlist = [`n"
foreach ($fullline in $iisevents)
{
    #"$line"

    $line=$fullline.FinalExpression
    if ($i -ne 0) {
        $RuleName="AlertRule-$rulePrefix-$i"
        $EventSource=$line.Split('[')[1]
        #$searchstring="Name=\'"
        # $regex = ".*?$searchstring.+?\'"
        # $line -match $regex
        #$Provider='TBD'
        $Provider=($line | select-string -Pattern "(?<=Name=\\')(.*)(?=\\')").Matches.Value
        $mats=$line | Select-String -Pattern 'EventID=\d+' -AllMatches 
        $s=''
        foreach ($m in $mats.Matches ) { $s+="$($m.Value.split('=')[1])," }
        #$s
    
        $finalstring="{0} {1}$($s.Trim(','))) and EventLog == \'{2}\' and Source == \'{3}\'" -f $basestring,$Eventstring1, $EventSource, $Provider
        #$Eventstring="EventId == $eventsource and $Eventstring and Source == $EventSource"
        #$finalstring
        $alertslist+=@"
        {
            alertRuleDescription: '$($fullline.Description)'
            alertRuleDisplayName:'$($fullline.Description)'
            alertRuleName:'$RuleName'
            alertRuleSeverity:$($fullline.Severity)
            autoMitigate: true
            evaluationFrequency: 'PT15M'
            windowSize: 'PT15M'
            query: '$($finalstring)'
          }`n
"@
      
    }
    $i++    
}
$alertslist+="`n]"
$alertslist | Out-File -FilePath ./IIS-2012.xml-AlertRules.json




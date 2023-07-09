# Parameter help description
param (
[Parameter(Mandatory=$true)]
[string]
$mpfilename,
[Parameter(Mandatory=$false)]
[string]
$alerts=$true,
[Parameter(Mandatory=$false)]
[string]
$performance=$true,
[Parameter(Mandatory=$false)]
[string]
$events=$true,
[Parameter(Mandatory=$false)]
[string]
$monitors=$true)
[xml]$mp=get-content $mpfilename
$alertfilename="$($mpfilename)-AlertRules.csv"
$rules=$mp.ManagementPack.Monitoring.Rules.Rule | ? {$_.Enabled -eq $true}
$messages=$mp.ManagementPack.LanguagePacks 
#Alert Rules
if (($rules | ? {$_.Category -eq 'Alert'}).count -ne 0 -and $alerts -eq $true) {
    "Category,LogName,Expression,ExpressionXML,WA,Priority,Severity,ID,Description" | Out-File $alertfilename
    foreach ($rule in $rules | ? {$_.Category -eq 'Alert'})
    {
        $displayMessage=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.ID} | Select-Object ElementID, Description
        $WADisplay=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.WriteActions.WriteAction.TypeID} | Select-Object Description
        #$expression
        if ([string]::IsNullOrEmpty($rule.DataSources.DataSource.Expression))
        {
            $expression=$rule.ConditionDetection.Expression.InnerText
            $expressionXML=$rule.ConditionDetection.Expression.InnerXML
        }
        else {
            $expression=$rule.DataSources.DataSource.Expression.InnerText
            $expressionXML=$rule.DataSources.DataSource.Expression.InnerXML
        }
        "$($rule.Category),$($rule.DataSources.DataSource.LogName),$expression,$expressionXML,WA:$($WADisplay.Description),$($rule.WriteActions.WriteAction.Priority),$($rule.WriteActions.WriteAction.Severity),$($rule.ID),$($displayMessage.Description)" | Out-File $alertfilename -Append
    }
}
#Performance Colletion Rules
if (($rules | ? {$_.Category -eq 'PerformanceCollection'}).count -ne 0 -and $performance -eq $true) {
    $perfFilename="$($mpfilename)-PerfRules.csv"
    "Category,Datasource,Frequency,WA,ID,Description" | Out-File $perfFilename
    foreach ($rule in $rules | ? {$_.Category -eq 'PerformanceCollection'})
    {
        $displayMessage=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.ID} | Select-Object ElementID, Description
        $WADisplay=($messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.WriteActions.WriteAction[0].TypeID} | Select-Object Description).Description
        if ([string]::IsNullOrEmpty($WADisplay))
        {
            $WADisplay=$rule.WriteActions.WriteAction[0].TypeID
        }
        $datasource="'\\{0}({1})\\{2}'" -f $rule.Datasources.Datasource.ObjectName,$rule.Datasources.Datasource.InstanceName, $rule.Datasources.Datasource.CounterName
        "$($rule.Category),$datasource,$($rule.Datasources.Datasource.Frequency),WA:$($WADisplay),$($rule.ID),$($displayMessage.Description)" | Out-File $perfFilename -Append
    }
}
#Event Colleciton Rules
if (($rules | ? {$_.Category -eq 'EventCollection'}).count -ne 0 -and $events -eq $true) {
    $eventColfilename="$($mpfilename)-EventColRules.csv"


    "Category,LogName,Expression,ExpressionXML,WA,Priority,Severity,ID,Description" | Out-File $eventColfilename
    foreach ($rule in $rules | ? {$_.Category -eq 'EventCollection'})
    {
        $displayMessage=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.ID} | Select-Object ElementID, Description
        $WADisplay=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.WriteActions.WriteAction.TypeID} | Select-Object Description
        #$expression
        if ([string]::IsNullOrEmpty($rule.DataSources.DataSource.Expression))
        {
            $expression=$rule.ConditionDetection.Expression.InnerText
            $expressionXML=$rule.ConditionDetection.Expression.InnerXML
        }
        else {
            $expression=$rule.DataSources.DataSource.Expression.InnerText
            $expressionXML=$rule.DataSources.DataSource.Expression.InnerXML
        }
        "$($rule.Category),$($rule.DataSources.DataSource.LogName),$expression,$expressionXML,WA:$($WADisplay.Description),$($rule.WriteActions.WriteAction.Priority),$($rule.WriteActions.WriteAction.Severity),$($rule.ID),$($displayMessage.Description)" | Out-File $eventColfilename -Append
    }
}
# Unit monitors
$ms=$mp.ManagementPack.Monitoring.Monitors
if ($ms.UnitMonitor.Count -ne 0 ) {
    $unitMonfilename="$($mpfilename)-UnitMonitors.csv"
    "Category,LogName,Expression,ExpressionXML,Priority,Severity,ID,Description" | Out-File $unitMonfilename
    foreach ($m in $ms.UnitMonitor )#| ? {$_.Category -eq 'Alert'})
    {
        $displayMessage=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $m.ID} | Select-Object ElementID, Description
        #$WADisplay=$messages.LanguagePack.DisplayStrings.DisplayString | ? {$_.ElementID -eq $rule.WriteActions.WriteAction.TypeID} | Select-Object Description
        #$expression
        if ([string]::IsNullOrEmpty($m.Configuration))
        {
            "Empty expression"
            #$expression=$.ConditionDetection.Expression.InnerText
        }
        else {
            $expression=$m.Configuration.InnerText
            $expressionXML=$m.Configuration.InnerXML
        }
        "$($m.Category),$($m.Configuration.LogName),$expression,$expressionXML,$($m.alertsettings.AlertPriority),$($m.AlertSettings.AlertSeverity),$($m.ID),$($displayMessage.Description)" | Out-File $unitMonfilename -Append
    }
}




function new-markdown {
    param (
        [string]$packfolder
    )
    $packname=$packfolder.Split("/")[-1]
    $alertfile="$packfolder/alerts.bicep"
    $monitorsfile="$packfolder/monitoring.bicep"
    bicep build $alertfile --outfile /tmp/alerts.json
    $alerts=(Get-Content /tmp/alerts.json | ConvertFrom-Json).variables.alertlist
    bicep build $monitorsfile --outfile /tmp/monitoring.json
    $monitoring=Get-Content /tmp/monitoring.json | ConvertFrom-Json
    $xpathQueries=$monitoring.variables.xPathQueries
    $performanceCounters=$monitoring.variables.performanceCounters
    $filePatterns=$monitoring.variables.filePatterns
    @"
---
title: $packname
geekdocCollapseSection: true
weight: 50
---
"@
    # "# $packname Pack"
    # ""
    if ($alerts) {
        "[Alerts](#alerts)"
        ""
    }
    if ($performanceCounters) {
        "[Performance Counters](#performance-counters)"
        ""
    }
    if ($filePatterns) {
        "[File Patterns](#file-patterns)"
        ""
    }
    if ($alerts) {
        "## Alerts"
        "|DisplayName||Type|Description|"
        "|---|---|---|---|"
        foreach ($alert in $alerts) {
            "|[$($alert.alertRuleName)](#$($alert.alertRuleDisplayName.Replace(' ','-').tolower().replace('.','')))|Log| $($alert.alertRuleDescription)|"
            }

        $i=0
        foreach ($alert in $alerts) {
            "### $($alert.alertRuleDisplayName)"
            ""
            "|Property | Value |"
            "|---|---|"
            "|Severity|$($alert.alertRuleSeverity)|"
            "|Enabled|True|"
            "|AutoMitigate|$($alert.autoMitigate)|"
            "|EvaluationFrequency|$($alert.evaluationFrequency)|"
            "|WindowSize|$($alert.windowSize)|"
            "|Type|$($alert.alertType)|"
            "|Query|$($alert.query.Replace('|','\|'))|"
            "|Threshold|$(if ($alert.threshold) {$alert.threshold} else {"N/A"})|"
            if (!([string]::IsNullOrEmpty($xpathQueries))) {
                "|xPathQuery|$($xpathQueries[$i++])|"
            }
        }
    }
    if ($performanceCounters) {
        "## Performance Counters"
        ""
        "|Performance Counter|"
        "|---|"
        foreach ($counter in $performanceCounters) {
            "|$counter|"
        }
    }
    if ($filePatterns) {
        "## File Patterns"
        ""
        "|File Pattern|"
        "|---|"
        foreach ($pattern in $filePatterns) {
            "|$pattern|"
        }
    }
    # Add custom client monitoring documentation
    # TBD.
    # test if there is a client folder
    # $clientfile="$packfolder/client.bicep"
    # if (get-item $clientfile -ErrorAction SilentlyContinue) {
    #     # Compile the bicep for the client and find the name of the script to run
    #     bicep build $clientfile /tmp/client.json
    #     $client=Get-Content /tmp/client.json | ConvertFrom-Json 
    #     # look for speficic comments in the script to document what it does
    # }
}
$packFolderList=Get-ChildItem * -Directory

foreach ($pack in $packFolderList.Name) {
    new-markdown -packfolder $pack | Out-File -FilePath "../../Docs/Packs/$pack.md" -Encoding "UTF8"
}


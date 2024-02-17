


param (
    #mandatory parameters
    [Parameter(Mandatory=$true)]
    [string]$packType
)
function clean-link {
    param (
        [string]$linkName
    )
    $linkName=$linkName.Replace(' ','-').ToLower().Replace('.','').Replace('/','')
    return $linkName
}
function new-markdown {
    param (
        [string]$alertfile,
        [string]$packType,
        [string]$indexfilename
    )
    #$packfolder="./Packs/IaaS/IIS"
    $packname=$alertfile.Split("/")[-2]
    #$alertfile="$packfolder/alerts.bicep"
    
    bicep build $alertfile --outfile /tmp/alerts.json
    $content=Get-Content /tmp/alerts.json | ConvertFrom-Json
    $packfolder=(get-item $alertfile).DirectoryName
    $monitorsfile="$packfolder/monitoring.bicep"
    $alerts=$content.resources.properties | ? {$_.parameters.alertname -ne $null}
    if (Get-Item $monitorsfile -ErrorAction SilentlyContinue) {
        bicep build $monitorsfile --outfile /tmp/monitoring.json
        $monitoring=Get-Content /tmp/monitoring.json | ConvertFrom-Json
        $policies=$monitoring.resources.properties.template.resources | ? {$_.type -match 'policy'}
        $diags=$policies.properties.policyRule.then.details | ? {$_.type -match 'diagnosticSettings'}
    }
    # bicep build $monitorsfile --outfile /tmp/monitoring.json
    # $monitoring=Get-Content /tmp/monitoring.json | ConvertFrom-Json
    # $xpathQueries=$monitoring.variables.xPathQueries
    # $performanceCounters=$monitoring.variables.performanceCounters
    # $filePatterns=$monitoring.variables.filePatterns
    @"
---
title: $packname Monitoring Pack
geekdocCollapseSection: true
weight: 50
---
"@

# Creating Index file

    # "# $packname Pack"
    # ""
    if ($alerts) {
        "[Alerts](#alerts)"
        ""    
    }

    # if ($performanceCounters) {
    #     "[Performance Counters](#performance-counters)"
    #     ""
    # }
    # if ($filePatterns) {
    #     "[File Patterns](#file-patterns)"
    #     ""
    # }
    if ($alerts) {
        "## Alerts"
        "|DisplayName|Type|Description|"
        "|---|---|---|"
        foreach ($alert in $alerts) {
            $alerttype=$alert.template.resources.properties.parameters.policyRule.value.then.details.type
            "|[$($alert.parameters.alertDisplayName.value)](#$(clean-link $alert.parameters.alertDisplayName.value))|$alerttype|$($alert.parameters.alertname.value)|"
        }
        foreach ($alert in $alerts) {
        $i=0
        $alerttype=$alert.template.resources.properties.parameters.policyRule.value.then.details.type   
        "### $($alert.parameters.alertDisplayName.value)"
        ""
        "|Property | Value |"
        "|---|---|"
        "|Alert Type                    | $alerttype |"
        "|Alert Name                    |$($alert.parameters.alertname.value)|"
        "|Alert DisplayName             |$($alert.parameters.alertDisplayName.value)| |"
        "|Alert Description             |$($alert.parameters.alertDescription.value)| |"
        "|Metric Namespace             |$($alert.parameters.metricNamespace.value)| |"
        "|Severity                    |$($alert.parameters.parAlertSeverity.value)| |"
        "|Metric Name                  |$($alert.parameters.metricName.value)| |"
        "|Operator                     |$($alert.parameters.operator.value)| |"
        "|Evaluation Frequency       |$($alert.parameters.parEvaluationFrequency.value)| |"
        "|Windows Size                |$($alert.parameters.parWindowSize.value)| |"
        "|Threshold                 |$($alert.parameters.parThreshold.value)| |"
        "|Auto Mitigate              |$($alert.parameters.parAutoMitigate.value)| |"
        "|Initiative Member             |$($alert.parameters.initiativeMember.value)| |"
        "|Pack Type                     |$($alert.parameters.packtype.value)| |"
        "|Time Aggregation              |$($alert.parameters.timeAggregation.value)| |"
        }
        $i++
    }
    # Diagnostic Settings policies
    if ($diags) {
        "## Diagnostic Settings"
        "|Diagnostics Log|"
        "|---|"
        foreach ($diag in $diags) {
            "|$($diag.deployment.properties.template.resources.properties.logs)|"
        }
    }
}

$indexfilename="../../Docs/Packs/$packtype/_index.md"
#$packFolderList=Get-ChildItem * -Directory
$alertfiles=Get-ChildItem alerts.bicep -Recurse
"Found $($alertfiles.Count) alert files."
"Generating Index file ($indexfilename)"
@"
---
title: $packType Monitoring Packs
geekdocCollapseSection: true
weight: 50
---


"@ | Out-File -FilePath $indexfilename -Encoding "UTF8"

foreach ($alertfile in $alertfiles) {
    if (!(get-item "../../Docs/Packs/$packtype")) {
        New-Item -ItemType Directory -Path "../../Docs/Packs/$packtype"
    }
    new-markdown -indexfilename $indexfilename -alertfile $alertfile.FullName | Out-File -FilePath "../../Docs/Packs/$packtype/$($alertfile.Directory.Name).md" -Encoding "UTF8"
    "Pack: [$($alertfile.Directory.Name)](./$($alertfile.Directory.Name))" | Out-File -FilePath $indexfilename -Append
    "" | Out-File -FilePath $indexfilename -Append
}


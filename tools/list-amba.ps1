$aaa=Invoke-WebRequest -uri 'https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json' | convertfrom-json
$Categories=$aaa.psobject.properties.Name
#$Categories
foreach ($cat in $Categories) {
    $svcs=$aaa.$($cat).psobject.properties.Name
    foreach ($svc in $svcs) {
        if ($aaa.$cat.$svc.name -ne $null) {   
            if ($aaa.$cat.$svc[0].properties.metricNamespace -ne $null) {
                Write-Host "$cat.$svc - $($aaa.$cat.$svc[0].properties.metricNamespace)"
                $mns=$aaa.$cat.$svc[0].properties.metricNamespace.tolower()
                if (!([string]::IsNullOrEmpty($mns))) {
                    "'$mns'," | out-file "/temp/ambametrics.log" -Append
                }
            }
            else {
                Write-Host "$cat.$svc - N/A (activity log only, probably)"
                "No metricNamespace for $cat.$svc" | out-file "/temp/amba.log"
            }
        }
    }
}
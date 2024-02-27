$aaa=Invoke-WebRequest -uri 'https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json' | convertfrom-json
$Categories=$aaa.psobject.properties.Name
#$Categories
foreach ($cat in $Categories) {
    $svcs=$aaa.$($cat).psobject.properties.Name
    foreach ($svc in $svcs) {
        if ($aaa.$cat.$svc.name -ne $null) {
            
            Write-Host "$cat.$svc - $($aaa.$cat.$svc[0].properties.metricNamespace)"
        }
    }
}
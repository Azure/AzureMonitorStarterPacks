$aaa=Invoke-WebRequest -uri 'https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json' | convertfrom-json
$Categories=$aaa.psobject.properties.Name
#$Categories
$body=@"
{
    "Categories": [
"@
$i=0
      foreach ($cat in $Categories) {
          $svcs=$aaa.$($cat).psobject.properties.Name
          foreach ($svc in $svcs) {
             $namespace="microsoft.$($cat.tolower())/$($svc.tolower())"
              if ($aaa.$cat.$svc.name -ne $null) {                  
                  if ($aaa.$cat.$svc[0].properties.metricNamespace -ne $null) {
                      $bodyt=@"
  {
    "category" : "$cat",
    "service" : "$svc",
    "metricnamespace": "$($aaa.$cat.$svc[0].properties.metricNamespace.tolower())",
    "namespace2": "$namespace"
  }
"@
                    

                  }
                  else {
                      $bodyt=@"
    {
        "category" : "$cat",
      "service" : "$svc",
      "metricnamespace": "N/A",
        "namespace2": "$namespace"
    }
"@  
                  }
                  if ($i -eq 0) {
                      $body+=@"
                      $bodyt
"@

                      $i++
                  }
                  else {
                      $body+=@"
,
                      $bodyt
"@
                  }
              }
          }
      }
    $body+=@"
    ]
    }
"@
$body

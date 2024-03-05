using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$Request

$Action = $Request.Query.Action
"Action: $Action"
"Body"
$Request.Body
"EoB"
$PaaSQuery=@"
| where tolower(type) in (
            'microsoft.storage/storageaccounts',
            'microsoft.desktopvirtualization/hostpools',
            'microsoft.logic/workflows',
            'microsoft.sql/managedinstances',
            'microsoft.sql/servers/databases',
            'microsoft.containerservice/managedclusters',
            'microsoft.documentdb/databaseaccounts',
            'microsoft.apimanagement/service',
            'microsoft.web/sites',
            'microsoft.containerregistry/registries',
            'microsoft.cache/redis'
      )
      or (
          tolower(type) ==  'microsoft.cognitiveservices/accounts' and tolower(['kind']) == 'openai'
      )
"@

$PlatformQuery=@"
| where tolower(type) in (
            'microsoft.network/virtualnetworks',
            'microsoft.network/expressroutecircuits',
            'microsoft.network/expressrouteports',
            'microsoft.datafactory/factories',
            'microsoft.cdn/profiles',
            'microsoft.eventhub/clusters',
            'microsoft.eventhub/namespaces',
            'microsoft.network/vpngateways',
            'microsoft.network/virtualnetworkgateways',
            'microsoft.keyvault/vaults',
            'microsoft.network/networksecuritygroups',
            'microsoft.network/publicipaddresses',
            'microsoft.network/privatednszones',
            'microsoft.network/frontdoors',
            'microsoft.network/azurefirewalls',
            'microsoft.network/applicationgateways'
      ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')
"@
$tagMapping=@"
{
    tags: 
    [
    {
      "tag": "LogicApps",
      "nameSpace": "Microsoft.Logic/workflows",
      "type": "PaaS"
    }
    ,
    {
      "tag": "SQLSrv",
      "nameSpace": "Microsoft.Sql/servers/databases",
      "type": "PaaS"
    }
    ,
    {
      "tag": "SQLMI",
      "nameSpace": "Microsoft.Sql/managedInstances",
      "type": "PaaS"
    }
    ,
    {
      "tag": "WebApp",
      "nameSpace": "Microsoft.Web/sites",
      "type": "PaaS"
    }
    ,
    {
      "tag": "Storage",
      "nameSpace": "Microsoft.Storage/storageaccounts",
      "type": "PaaS"
    }
    ,
    {
      "tag": "VPNG",
      "nameSpace": "Microsoft.Network/vpngateways",
      "type": "Platform"
    }
    ,
    {
      "tag": "ERgw",
      "nameSpace": "Microsoft.Network/expressRouteGateways",
      "type": "Platform"
    },
    {
      "tag": "ALB",
      "nameSpace": "Microsoft.Network/loadBalancers",
      "type": "Platform",
      "sku": "Standard"
    },
    {
      "tag": "AA",
      "nameSpace": "Microsoft.Automation/automationAccounts",
      "type": "PaaS"
    },
    {
      "tag": "AppGw",
      "nameSpace": "Microsoft.Network/applicationGateways",
      "type": "Platform"
    },
    {
      "tag": "AzFW",
      "nameSpace": "Microsoft.Network/azureFirewalls",
      "type": "Platform"
    },
    {
      "tag": "AzFD",
      "nameSpace": "Microsoft.Network/frontdoors",
      "type": "Platform"
    },
    {
      "tag": "PrivZones",
      "nameSpace": "Microsoft.Network/privateDnsZones",
      "type": "Platform"
    },
    {
      "tag": "PIP",
      "nameSpace": "Microsoft.Network/publicIPAddresses",
      "type": "Platform"
    },
    {
      "tag": "NSG",
      "nameSpace": "Microsoft.Network/networkSecurityGroups",
      "type": "Platform"
    },
    {
      "tag": "KeyVault",
      "nameSpace": "microsoft.keyvault/vaults",
      "type": "Platform"
    },
    {
      "tag": "VnetGW",
      "nameSpace": "Microsoft.Network/virtualnetworkgateways",
      "type": "Platform"
    },
    {
      "tag": "AVD",
      "nameSpace": "Microsoft.DesktopVirtualization/hostpools",
      "type": "PaaS"
    },
    
    ]
}
"@ | ConvertFrom-Json

$discoveringMappings=@{
   "ADDS"="AD-Domain-Services"
   "DNS"="DNS"
   "FS"="FS-FileServer"
   "IIS"="Web-Server"
   "STSVC"="Storage-Services"
   "Nginx"="nginx-core"
}
switch ($Action) {
    # Returns the tag based on the nameSpace provided
    'getTagbyService' {
        $svc=$Request.body.metricNamespace
        if ($svc) {
            $tag=$tagMapping.tags | ? { $_.nameSpace -eq $svc } 
        }
        else {
            $tag='Undetermined'
        }
        $body=@"
        {
            "tag":"$($tag.tag)",
            "nameSpace":"$($tag.nameSpace)",
            "type":"$($tag.type)"
        }
"@ | convertfrom-json
    }
    # Gets a list of tags (all) or for a specific type (PaaS or Platform)
    'getAllServiceTags' {
        $type=$Request.Query.Type
        if ([string]::IsNullOrEmpty($type)) {
            $body=$tagMapping.tags  | Select-Object tag, @{Label="nameSpace";Expression={$_.nameSpace.ToLower()}},type | convertto-json # | Select @{l='metricNamespace';e={$_}},@{l='tag';e={$tagMapping.$_}}
        }
        else {
            "Type"
            $body=$tagMapping.tags  | where-object {$_.type -eq $type} | Select-Object tag, @{Label="nameSpace";Expression={$_.nameSpace.ToLower()}},type | convertto-json
            
        }
    }
    # returns a list of discovery mapping directions.
    'getDiscoveryMappings' {
        $body=$discoveringMappings.Keys | Select-Object @{l='tag';e={$_}},@{l='application';e={$discoveringMappings.$_}}
    }
    'getPaaSquery' {
        $body=@"
        {
            "Query": "
$PaaSQuery"
      }
"@
    }
    'getPlatformquery' {
        $body=@"
        {
            "Query":"
        $PlatformQuery"
    }
"@
    }
    'listAmbaAlerts' {
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
                  if ($aaa.$cat.$svc.name -ne $null) {                  
                      if ($aaa.$cat.$svc[0].properties.metricNamespace -ne $null) {
                          $bodyt=@"
      {
        "category" : "$cat",
        "service" : "$svc",
        "namespace": "$($aaa.$cat.$svc[0].properties.metricNamespace.tolower())"
      }
"@
                      }
                      else {
                          $bodyt=@"
        {
            "category" : "$cat",
          "service" : "$svc",
          "namespace": "microsoft.$($cat.tolower())/$($svc.tolower())"
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
    
    }
    "getNonMonitoredPaaS" {
        $resourceQuery=@"
        resources
        $PaaSQuery
        | where isnotempty(tags.MonitorStarterPacks)
        | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId
"@
        $alertsQuery=@"
        resources
        | where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
        | where isnotempty(tags.MonitorStarterPacks)
        | project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, Resource=tostring(properties.scopes[0])
"@
        $resources=Search-AzGraph -Query $resourceQuery
        $alerts=Search-AzGraph -Query $alertsQuery

        # determine if the resources have alerts and shows total
        $results="{""Monitored Resources"" : ["

        $results+=foreach ($res in $resources) {
            if ($res.Resource -in $alerts.Resource) {
                $totalAlerts=($alerts|where Resource -eq $res.Resource).count
                "{""Resource"" : ""$($res.Resource)"","
                """type"" : ""$($res.""type"")"","
                """tag"" : ""$($res.""tag"")"","
                """resourceGroup"" : ""$($res.""resourceGroup"")"","
                """location"" : ""$($res.""location"")"","
                """subscriptionId"" : ""$($res.""subscriptionId"")"","
                """Total"" : $totalAlerts},"
            } else {
                "{""Resource"" : ""$($res.Resource)"","
                """type"" : ""$($res.""type"")"","
                """tag"" : ""$($res.""tag"")"","
                """resourceGroup"" : ""$($res.""resourceGroup"")"","
                """location"" : ""$($res.""location"")"","
                """subscriptionId"" : ""$($res.""subscriptionId"")"","
                """Total"" : 0 },"
            }   
        }
    $resultsString=$results -join ""
    $body=$resultsString.TrimEnd(",")+"]}" | convertfrom-json | convertto-json

    }
    "getNonMonitoredPlatform" {
        $resourceQuery=@"
        resources
        $PlatformQuery
        | where isnotempty(tags.MonitorStarterPacks)
        | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId
"@
        $alertsQuery=@"
        resources
        | where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
        | where isnotempty(tags.MonitorStarterPacks)
        | project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, Resource=tostring(properties.scopes[0])
"@
        $resources=Search-AzGraph -Query $resourceQuery
        $alerts=Search-AzGraph -Query $alertsQuery

        # determine if the resources have alerts and shows total
        $results="{""Monitored Resources"" : ["

        $results+=foreach ($res in $resources) {
            if ($res.Resource -in $alerts.Resource) {
                $totalAlerts=($alerts|where Resource -eq $res.Resource).count
                "{""Resource"" : ""$($res.Resource)"","
                """type"" : ""$($res.""type"")"","
                """tag"" : ""$($res.""tag"")"","
                """resourceGroup"" : ""$($res.""resourceGroup"")"","
                """location"" : ""$($res.""location"")"","
                """subscriptionId"" : ""$($res.""subscriptionId"")"","
                """Total"" : $totalAlerts},"
            } else {
                "{""Resource"" : ""$($res.Resource)"","
                """type"" : ""$($res.""type"")"","
                """tag"" : ""$($res.""tag"")"","
                """resourceGroup"" : ""$($res.""resourceGroup"")"","
                """location"" : ""$($res.""location"")"","
                """subscriptionId"" : ""$($res.""subscriptionId"")"","
                """Total"" : 0 },"
            }   
        }
    $resultsString=$results -join ""
    $body=$resultsString.TrimEnd(",")+"]}" | convertfrom-json | convertto-json

    }
    default {$body=''}
}

# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})


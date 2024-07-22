using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$Request

$Action = $Request.Query.Action
"Action: $Action"
"Headers:"
#$Request.Headers.resourceFilter
# "Body"
# $Request.Body
# "EoB"

$tagMapping = @"
{
  "tags": [
    {
      "tag": "KeyVault",
      "nameSpace": "Microsoft.KeyVault/vaults",
      "type": "PaaS"
    },
    {
      "tag": "LogicApps",
      "nameSpace": "Microsoft.Logic/workflows",
      "type": "PaaS"
    },
    {
      "tag": "ServiceBus",
      "nameSpace": "Microsoft.ServiceBus/namespaces",
      "type": "PaaS"
    },
    {
      "tag": "Storage",
      "nameSpace": "Microsoft.Storage/storageaccounts",
      "type": "PaaS"
    },
    {
      "tag": "WebApps",
      "nameSpace": "Microsoft.Web/sites",
      "type": "PaaS"
    },
    {
      "tag": "SQLSrv",
      "nameSpace": "Microsoft.Sql/servers",
      "type": "PaaS"
    },
    {
      "tag": "SQLMI",
      "nameSpace": "Microsoft.Sql/managedinstances",
      "type": "PaaS"
    },
    {
      "tag": "WebServer",
      "nameSpace": "Microsoft.Web/serverfarms",
      "type": "PaaS"
    },
    {
      "tag": "AppGW",
      "nameSpace": "Microsoft.Network/applicationgateways",
      "type": "PaaS"
    },
    {
      "tag": "AzFW",
      "nameSpace": "Microsoft.Network/azurefirewalls",
      "type": "PaaS"
    },
    {
      "tag": "PrivZones",
      "nameSpace": "Microsoft.Network/privatednszones",
      "type": "PaaS"
    },
    {
      "tag": "PIP",
      "nameSpace": "Microsoft.Network/publicipaddresses",
      "type": "PaaS"
    },
    {
      "tag": "UDR",
      "nameSpace": "Microsoft.Network/routetables",
      "type": "PaaS"
    },
    {
      "tag": "AA",
      "nameSpace": "Microsoft.Automation/automationaccounts",
      "type": "PaaS"
    },
    {
      "tag": "NSG",
      "nameSpace": "Microsoft.Network/networksecuritygroups",
      "type": "PaaS"
    },
    {
      "tag": "AzFD",
      "nameSpace": "Microsoft.Network/frontdoors",
      "type": "PaaS"
    },
    {
      "tag": "ALB",
      "nameSpace": "Microsoft.Network/loadbalancers",
      "type": "PaaS"
    },
    {
      "tag": "Bastion",
      "nameSpace": "Microsoft.Network/bastionhosts",
      "type": "PaaS"
    },
    {
      "tag": "VPNG",
      "nameSpace": "Microsoft.Network/vpngateways",
      "type": "PaaS"
    },
    {
      "tag": "VnetGW",
      "nameSpace": "Microsoft.Network/virtualNetworkgateways",
      "type": "PaaS"
    },
    {
      "tag": "VNET",
      "nameSpace": "Microsoft.Network/virtualnetworks",
      "type": "PaaS"
    },
    {
      "tag": "MLWS",
      "nameSpace": "Microsoft.MachineLearningServices/workspaces",
      "type": "PaaS"
    },
    {
      "tag": "EVNS",
      "nameSpace": "Microsoft.EventHub/namespaces",
      "type": "PaaS"
    },
    {
      "tag": "EVCL",
      "nameSpace": "Microsoft.EventHub/clusters",
      "type": "PaaS"
    },
    {
      "tag": "MDB",
      "nameSpace": "Microsoft.DBforMariaDB/servers",
      "type": "PaaS"
    },
    {
      "tag": "CDN",
      "nameSpace": "Microsoft.Cdn/profiles",
      "type": "PaaS"
    },
    {
      "tag": "APIM",
      "nameSpace": "Microsoft.ApiManagement/service",
      "type": "PaaS"
    }
  ]
}
"@ | ConvertFrom-Json

$discoveringMappings = @{
  "ADDS"  = "AD-Domain-Services"
  "DNS"   = "DNS"
  "FS"    = "FS-FileServer"
  "IIS"   = "Web-Server"
  "STSVC" = "Storage-Services"
  "Nginx" = "nginx-core"
  "Avd"   = "Avd-hostpool"
}
switch ($Action) {
  # Returns the tag based on the nameSpace provided
  'getTagbyService' {
    $svc = $Request.body.metricNamespace
    if ($svc) {
      $tag = $tagMapping.tags | ? { $_.nameSpace -eq $svc } 
    }
    else {
      $tag = 'Undetermined'
    }
    $body = @"
        {
            "tag":"$($tag.tag)",
            "nameSpace":"$($tag.nameSpace)",
            "type":"$($tag.type)"
        }
"@ | convertfrom-json
  }
  # Gets a list of tags (all) or for a specific type (PaaS)
  'getAllServiceTags' {
    $type = $Request.Query.Type
    if ([string]::IsNullOrEmpty($type)) {
      $body = $tagMapping.tags  | Select-Object tag, @{Label = "nameSpace"; Expression = { $_.nameSpace.ToLower() } }, type | convertto-json # | Select @{l='metricNamespace';e={$_}},@{l='tag';e={$tagMapping.$_}}
    }
    else {
      "Type"
      $body = $tagMapping.tags  | where-object { $_.type -eq $type } | Select-Object tag, @{Label = "nameSpace"; Expression = { $_.nameSpace.ToLower() } }, type | convertto-json
            
    }
  }
  # returns a list of discovery mapping directions.
  'getDiscoveryMappings' {
    $body = $discoveringMappings.Keys | Select-Object @{l = 'tag'; e = { $_ } }, @{l = 'application'; e = { $discoveringMappings.$_ } }
  }
  'getPaaSquery' {
    $body = get-paasquery
#     @"
#         {
#             "Query": "
#         | where tolower(type) in (
#           'microsoft.storage/storageaccounts',
#           'microsoft.desktopvirtualization/hostpools',
#           'microsoft.logic/workflows',
#           'microsoft.sql/managedinstances',
#           'microsoft.sql/servers/databases',
#           'microsoft.network/vpngateways',
#           'microsoft.network/virtualnetworkgateways',
#           'microsoft.keyvault/vaults',
#           'microsoft.network/networksecuritygroups',
#           'microsoft.network/publicipaddresses',
#           'microsoft.network/privatednszones',
#           'microsoft.network/frontdoors',
#           'microsoft.network/azurefirewalls',
#           'microsoft.network/applicationgateways'
#       )
#       or (
#           tolower(type) ==  'microsoft.cognitiveservices/accounts' and tolower(['kind']) == 'openai'
#       ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')"
#       }
# "@
  }
  'getPlatformquery' {
    $body='{}'
#     $body = @'
#         {
#             "Query":"
#         | where tolower(type) in (
#           'microsoft.network/vpngateways',
#           'microsoft.network/virtualnetworkgateways',
#           'microsoft.keyvault/vaults',
#           'microsoft.network/networksecuritygroups',
#           'microsoft.network/publicipaddresses',
#           'microsoft.network/privatednszones',
#           'microsoft.network/frontdoors',
#           'microsoft.network/azurefirewalls',
#           'microsoft.network/applicationgateways'
#       ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')"
#     }
# '@
  }
  "getNonMonitoredPaaS" {
      $PaaSQuery=get-paasquery
      if ($Request.Query.resourceFilter) {
        $resourceFilter = @"
        | where tolower(type) in ($($Request.Query.resourceFilter))
"@        
      }
      #$PaaSQuery
      $resourceQuery=@"
      resources
      $PaaSQuery
      | where isempty(tags.MonitorStarterPacks)
      | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId, ['kind']
      $resourceFilter
"@
#       $alertsQuery=@"
#       resources
#       | where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
#       | where isnotempty(tags.MonitorStarterPacks)
#       | project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, Resource=tostring(properties.scopes[0])
# "@
      $resources=Search-AzGraph -Query $resourceQuery
      $resourceQuery
      # $alerts=Search-AzGraph -Query $alertsQuery

      # determine if the resources have alerts and shows total
      $results="{""Monitored Resources"" : ["

      $results+=foreach ($res in $resources) {
              "{""Resource"" : ""$($res.Resource)"","
              """type"" : ""$($res.""type"")"","
              """tag"" : ""$(get-serviceTag -namespace $res.type -tagMappings $tagMapping)"","
              """resourceGroup"" : ""$($res.""resourceGroup"")"","
              """location"" : ""$($res.""location"")"","
              """kind"" : ""$($res.""kind"")"","
              """subscriptionId"" : ""$($res.""subscriptionId"")""},"
      }
      $resultsString=$results -join ""
      $body=$resultsString.TrimEnd(",")+"]}" | convertfrom-json | convertto-json
  }
  "getMonitoredPaaS" {
      $PaaSQuery=get-paasquery
      if ($Request.Query.resourceFilter) {
        $resourceFilter = @"
        | where tolower(type) in ($($Request.Query.resourceFilter))
"@        
      }
      $resourceQuery=@"
      resources
      $PaaSQuery
      | where isnotempty(tags.MonitorStarterPacks)
      | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId, ['kind']
      $resourceFilter
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
      $results="{""MonitoredResources"" : ["

      $results+=foreach ($res in $resources) {
          if ($res.Resource -in $alerts.Resource) {
              $totalAlerts=($alerts|where {$_.Resource -eq $res.Resource}).count
              "{""Resource"" : ""$($res.Resource)"","
              """type"" : ""$($res.""type"")"","
              """tag"" : ""$($res.""tag"")"","
              """resourceGroup"" : ""$($res.""resourceGroup"")"","
              """location"" : ""$($res.""location"")"","
              """kind"" : ""$($res.""kind"")"","
              """subscriptionId"" : ""$($res.""subscriptionId"")"","
              """Total"" : $totalAlerts},"
          } else {
              "{""Resource"" : ""$($res.Resource)"","
              """type"" : ""$($res.""type"")"","
              """tag"" : ""$($res.""tag"")"","
              """resourceGroup"" : ""$($res.""resourceGroup"")"","
              """location"" : ""$($res.""location"")"","
              """kind"" : ""$($res.""kind"")"","
              """subscriptionId"" : ""$($res.""subscriptionId"")"","
              """Total"" : 0 },"
          }   
      }
      $resultsString=$results -join ""
      $body=$resultsString.TrimEnd(",")+"]}" | convertfrom-json | convertto-json
  }
  "getSupportedServices" {
    # uset $tagmapping to return only the namespace column in a json body
    $body = $tagMapping.tags | Select-Object @{Label = "nameSpace"; Expression = { $_.nameSpace.ToLower() }} | convertto-json
  }
  default { $body = '' }
}

# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
  })


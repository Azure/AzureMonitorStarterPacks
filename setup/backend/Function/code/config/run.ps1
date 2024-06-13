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

$tagMapping = @"
{
    tags: 
    [
      {
        "tag": "Avd",
        "nameSpace": "Microsoft.Compute/hostpools",
        "type": "PaaS"
      },
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
      "tag": "VPNgw",
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
  # Gets a list of tags (all) or for a specific type (PaaS or Platform)
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
    $body = @"
        {
            "Query": "
        | where tolower(type) in (
          'microsoft.storage/storageaccounts',
          'microsoft.desktopvirtualization/hostpools',
          'microsoft.logic/workflows',
          'microsoft.sql/managedinstances',
          'microsoft.sql/servers/databases',
          'microsoft.network/vpngateways',
          'microsoft.network/virtualnetworkgateways',
          'microsoft.keyvault/vaults',
          'microsoft.network/networksecuritygroups',
          'microsoft.network/publicipaddresses',
          'microsoft.network/privatednszones',
          'microsoft.network/frontdoors',
          'microsoft.network/azurefirewalls',
          'microsoft.network/applicationgateways'
      )
      or (
          tolower(type) ==  'microsoft.cognitiveservices/accounts' and tolower(['kind']) == 'openai'
      ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')"
      }
"@
  }
  'getPlatformquery' {
    $body = @'
        {
            "Query":"
        | where tolower(type) in (
          'microsoft.network/vpngateways',
          'microsoft.network/virtualnetworkgateways',
          'microsoft.keyvault/vaults',
          'microsoft.network/networksecuritygroups',
          'microsoft.network/publicipaddresses',
          'microsoft.network/privatednszones',
          'microsoft.network/frontdoors',
          'microsoft.network/azurefirewalls',
          'microsoft.network/applicationgateways'
      ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')"
    }
'@
  }
  default { $body = '' }
}

# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
  })


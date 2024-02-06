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
      "tag": "LB",
      "nameSpace": "Microsoft.Network/loadBalancers",
      "type": "Platform"
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
    }
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
    'getAllServiceTags' {
        if ([string]::IsNullOrEmpty($type)) {
            $body=$tagMapping.tags  | select tag, @{Label="nameSpace";Expression={$_.nameSpace.ToLower()}},type | convertto-json # | Select @{l='metricNamespace';e={$_}},@{l='tag';e={$tagMapping.$_}}
        }
        else {
            "Type"
            $type=$Request.Query.Type
            $body=$tagMapping.tags  | .where-object {$_.type -eq $type} | select tag, @{Label="nameSpace";Expression={$_.nameSpace.ToLower()}},type | convertto-json
            
        }
    }
    'getDiscoveryMappings' {
        $body=$discoveringMappings.Keys | Select @{l='tag';e={$_}},@{l='application';e={$discoveringMappings.$_}}
    }
    default {$body=''}
}

#$body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# # if ($name) {
# #     $body = "Hello, $name. This HTTP triggered function executed successfully."
# # }

# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

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
$tagMapping=@{
    'Microsoft.Logic/workflows'='LogicApps'
    'Microsoft.Sql/servers/databases'='SQLSrv'
    'Microsoft.Sql/managedInstances'='SQLMI'
    'Microsoft.Web/sites'='WebApp'
    'Microsoft.Storage/storageaccounts'='Storage'
    'Microsoft.Network/vpngateways'='VPNgw'
    'Microsoft.Network/expressRouteGateways'='ERgw'
    'Microsoft.Network/loadBalancers'='LB'
    'Microsoft.Automation/automationAccounts'='AA'
    'Microsoft.Network/applicationGateways'= 'AppGw'
    'Microsoft.Network/azureFirewalls'= 'AzFW'
    'Microsoft.Network/frontdoors'='AzFD'
    'Microsoft.Network/privateDnsZones'='PrivZones'
    'Microsoft.Network/publicIPAddresses'='PIP'
    'Microsoft.Network/networkSecurityGroups' = 'NSG'
}
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
            $tag=$tagMapping[$svc]
        }
        else {
            $tag='Undetermined'
        }
        $body=@"
            {
                "tag":"$tag"
            }
"@ | convertfrom-json
    }
    'getAllServiceTags' {
        $body=$tagMapping.Keys | Select @{l='metricNamespace';e={$_}},@{l='tag';e={$tagMapping.$_}}
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

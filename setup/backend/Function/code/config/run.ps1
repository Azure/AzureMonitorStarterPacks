using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$Request
$Action = $Request.Query.Action
"Action: $Action"
$ambaURL=$env:AMBAJsonURL
# "Headers:"
#$Request.Headers.resourceFilter
# "Body"
# $Request.Body
# "EoB"
switch ($Action) {
  # Gets a list of tags (all) or for a specific type (PaaS)
  'getInstanceName' {
    $instanceName=$env:InstanceName
    $body = @"
        {
            "InstanceName":"$($instanceName)"
        }
"@ | convertfrom-json
  }
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
  'getdiscoveryresults' {
    #$WSId= $Request.Query.instanceName
    $instanceName=$env:InstanceName
    if ($instanceName) {
      $body="{""Discovered"" : $(get-discoveryresults -instanceName $instanceName) }"
    }
    else {
      $body = '{}'
    }
  }
  "getNonMonitoredPaaS" {
      if ($Request.Query.resourceFilter) {
        $resourceFilter = @"
        | where tolower(type) in ($($Request.Query.resourceFilter))
"@        
      }
      $ambaURL=$env:AMBAJsonURL
      "Fetching AMBA Catalog from $ambaURL"
      if ($ambaURL -eq $null) {
        "Error fetching AMBA URL, stopping function"
        $body = "Error fetching AMBA URL, stopping function"
        Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
            StatusCode = [HttpStatusCode]::BadRequest
            Body       = $body
          })
      }
      "About to try and call get-AmbaCatalog..."
      $ambaCatalog=get-AmbaCatalog -ambaJsonURL $ambaURL | ConvertFrom-Json -Depth 10
      "After AmbaCatalog"
      if ($ambaCatalog) {
        $nameSpacesWithAlerts=($ambaCatalog.Categories).namespace | ? {$_ -ne 'N/A'}
        #create an array of namespaceSpacesWithAlerts to use in the query (between single quotes, separated by commas and surrounded by parentheses)
        $nameSpacesWithAlerts=($nameSpacesWithAlerts | % { "'$_'" }) -join ','
        # use a kql azure resource graph query to find all the namespaces with alerts
        $PassQuery="resources | where isempty(tags.MonitorStarterPacks)
        | where type in~ ($nameSpacesWithAlerts)
        | where not(type in~ ('microsoft.compute/virtualmachines','microsoft.hybridcompute/machines'))
        | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId, ['kind']
        $resourceFilter"
        $resourcesThatHavealertsAvailable= (Search-AzGraph $PassQuery) | convertto-json #| Where-Object {$_.type -in $nameSpacesWithAlerts}
        if ($resourcesThatHavealertsAvailable.Count -gt 0) {
            $body="{""Non-Monitored Resources"" : $resourcesThatHavealertsAvailable }"
        }
        else { $body = '{}'}

      }
      else {
        $body="{}"
      }
  }
  "getMonitoredPaaS" {
    if ($Request.Query.resourceFilter) {
      $resourceFilter = @"
      | where tolower(type) in ($($Request.Query.resourceFilter))
"@        
    }
    $ambaURL=$env:AMBAJsonURL
    $instanceName=$env:InstanceName
    "Fetching AMBA Catalog from $ambaURL"
    if ($ambaURL -eq $null) {
      Write-host "Error fetching AMBA URL, stopping function"
      $body = "Error fetching AMBA URL, stopping function"
      Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
          StatusCode = [HttpStatusCode]::BadRequest
          Body       = $body
          })
    }
    $ambaCatalog=get-AmbaCatalog | ConvertFrom-Json -Depth 10
    if ($ambaCatalog) {
      Write-host "Found $($ambaCatalog.categories.count) categories in AMBA catalog."
      $nameSpacesWithAlerts=($ambaCatalog.Categories).namespace | ? {$_ -ne 'N/A'}
      Write-host "Found $(($nameSpacesWithAlerts).count) namespaces with alerts."
      #create an array of namespaceSpacesWithAlerts to use in the query (between single quotes, separated by commas and surrounded by parentheses)
      $nameSpacesWithAlerts=($nameSpacesWithAlerts | ForEach-Object { "'$_'" }) -join ','
      # use a kql azure resource graph query to find all the namespaces with alerts
#       $PaaSQuery=@"
# resources | where isnotempty(tags.MonitorStarterPacks) and tags.instanceName =~ '$instanceName'
# | where type in~ ($nameSpacesWithAlerts)
# | where not(type in~ ('microsoft.compute/virtualmachines','microsoft.hybridcompute/machines'))
# | project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId, ['kind']
# | join (resources
#     | where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
#     | where isnotempty(tags.MonitorStarterPacks)
#     | project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, Resource=tostring(properties.scopes[0])) on Resource
# $resourceFilter
# | summarize AlertRules=count() by Resource, Type=['type'], tag=['type'],resourceGroup=resourceGroup, kind  
# "@
$PaaSQuery=@"
resources | where isnotempty(tags.MonitorStarterPacks) and tags.instanceName =~ '$instanceName'
| where type in~ ($nameSpacesWithAlerts) 
| where not(type in~ ('microsoft.compute/virtualmachines','microsoft.hybridcompute/machines',"microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts",'microsoft.insights/datacollectionrules'))
| project Resource=id, type,tag=tostring(tags.MonitorStarterPacks),resourceGroup, location, subscriptionId, ['kind']
| join kind=fullouter    (resources
    | where tolower(type) in ("microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
    | where isnotempty(tags.MonitorStarterPacks) and tags.instanceName =~ '$instanceName'
    | summarize AlertCount=count() by Resource=tostring(properties.scopes[0]), MP=tostring(tags.MonitorStarterPacks)) on Resource
$resourceFilter
| summarize by AlertCount=iff(isnull(AlertCount),0,AlertCount),Resource=iff(isnotempty(Resource),Resource,Resource1), Type=['type'], tag=['type'],resourceGroup=resourceGroup, kind 
"@
      Write-host "PaasQuery to be used: $PaaSQuery"
      $resourcesThatHavealertsAvailable= (Search-AzGraph $PaaSQuery) | convertto-json #| Where-Object {$_.type -in $nameSpacesWithAlerts}
      if ($resourcesThatHavealertsAvailable.Count -gt 0) {
          $body="{""Monitored Resources"" : $resourcesThatHavealertsAvailable }" 
      }
      else {
        Write-host :"Found no resources..."
        $body = '{}'
      }
    }
    else {
        Write-host "Error fetching catalog, stopping function."
        $body = "{}"
    }
  }
  "getSupportedServices" {
      # uset $tagmapping to return only the namespace column in a json body
      $body=(get-AmbaCatalog -ambaJsonURL $ambaURL | convertfrom-json).Categories.namespace| Select-Object @{Label = "nameSpace"; Expression = { $_.ToLower() }} | convertto-json
      #$body = $tagMapping.tags | Select-Object @{Label = "nameSpace"; Expression = { $_.nameSpace.ToLower() }} | convertto-json
  }
  "runDiscovery" {
    $instanceName=$env:InstanceName
    if ($instanceName) {
      get-discoveryresults -instanceName $instanceName # analyses results and stores results in log analytics workspace under the resultsdiscovery table.
    }
    else {
        $body = '{}'
    }
  }
  "getavailableIaaSPacks" {
    $body=get-availableIaaSPacks -packContentURL $env:PacksURL
  }
  "getPacksDefinition"  {
    $body = get-PacksDefinition
  }
  'getIaaSPacksDetails' {
    $body=get-IaaSPacksContent
    if ($body -eq $null) {
      $body = '{}'
    }
  }
  'getServicesPacksDetails' {
    $body=get-AmbaCatalog
    if ($body -eq $null) {
      $body = '{}'
    }
  }

  default { 
    $body = '{"No matching action."}' 
  }
}
# # Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
  })


function get-discoveryData {
# get packs from the blob storage
    $packsUrl=$env:PacksUrl
    Write-host "Reading current packs from $packsUrl"
    $PacksDef=get-blobcontentfromurl -url $packsUrl | convertfrom-json -Depth 20
    $currentPacks=$PacksDef.Packs | Where-Object{ $null -ne $_.Discovery }
    # Create a json output with Name, Tag, Description, OS and Query
    $discoveryData=@{Packs=$currentPacks}
#     $discoveryData=@"
# {
#     "Packs": [
#         {
#             "Name": "nginx",
#             "Tag": "nginx",
#             "Description": "Nginx is a high-performance HTTP server and reverse proxy.",
#             "OS": "Linux",
#             "Query": "let maxts=Discovery_CL\n| extend platform=split(RawData,',')[2]\n| where platform =~ 'linux'\n| project timestamp=todatetime(tostring(split(RawData,',')[0]))\n| where isnotempty(timestamp)\n| summarize maxts=max(timestamp);\nDiscovery_CL\n| extend Computer=_ResourceId\n| extend fields=split(RawData,\",\")\n| extend timestamp=todatetime(fields[0])\n| extend type=tostring(fields[1])\n| extend platform=tostring(fields[2])\n| extend package=iff (platform =~ 'linux', tostring(fields[4]),'')\n| extend name=iff (platform =~ 'linux', tostring(fields[3]), tostring(fields[3]))\n| extend othertype=tostring(fields[5])\n| extend vendor=tostring(fields[6])\n| extend OSVersion=iff(platform =~ 'linux', '',tostring(fields[3]))\n| where timestamp == toscalar(maxts)\n| project timestamp,Computer,type,name,platform,OSVersion,othertype,vendor\n| where platform =~ 'linux'\n| where name == \"nginx\""
#         },
#         {
#             "Name": "ADDS",
#             "Tag": "ADDS",
#             "Description": "Active Directory Domain Services",
#             "OS": "Windows",
#             "Query": "let maxts=Discovery_CL\n| extend platform=split(RawData,',')[2]\n| where platform =~ 'windows'\n| project timestamp=todatetime(tostring(split(RawData,',')[0]))\n| where isnotempty(timestamp)\n| summarize maxts=max(timestamp);\nDiscovery_CL\n| extend Computer=_ResourceId\n| extend fields=split(RawData,',')\n| extend timestamp=todatetime(fields[0])\n| extend type=tostring(fields[1])\n| extend platform=tostring(fields[2])\n| extend package=iff (platform =~ 'windows', tostring(fields[4]),'')\n| extend name=iff (platform =~ 'windows', tostring(fields[3]), tostring(fields[3]))\n| extend othertype=tostring(fields[5])\n| extend vendor=tostring(fields[6])\n| extend OSVersion=iff(platform =~ 'windows', '',tostring(fields[3]))\n| where timestamp == toscalar(maxts)\n| project timestamp,Computer,type,name,platform,OSVersion,othertype,vendor\n| where name =~ 'AD-Domain-Services'"
#         }
#     ]
# }
# "@ | ConvertFrom-Json -Depth 10
    return $discoveryData
}

# function get-discovermappings {
#     $discoveringMappings = @{
#         "ADDS"  = "AD-Domain-Services"
#         "DNS"   = "DNS"
#         "IIS"   = "Web-Server"
#         "Nginx" = "nginx-core"
#     }
#     return $discoveringMappings.Keys | Select-Object @{l = 'tag'; e = { $_ } }, @{l = 'application'; e = { $discoveringMappings.$_ } }
# }
function get-discoveryresults {
    param (
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )
    # Get the right log analytics workspace
    $discoveryData=get-discoveryData #only packs with discovery data are returned.
    # use resource graph to get the workspace id with the instance name as the tag
    $wsquery = @"
Resources
| where type =~ 'microsoft.operationalinsights/workspaces'
| where tags['instanceName'] =~ '$instanceName'
| project id, name, type, tags, properties
| limit 1
"@
    $ws = Search-azgraph -Query $wsquery 
    if ($null -eq $ws) {
        Write-Error "No workspace found for instance name $instanceName"
        return $null
    }
    Write-host "Running Discovery"
    $timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    Write-host "Current timestamp: $timestamp"
    $wsresourceGroupname=$ws.ResourceId.split('/')[4]    
    # Write-host "Getting WS"
    $subscriptionId = $ws.ResourceId.split('/')[2]
    # # change context to subscription
    Set-AzContext -Subscription $subscriptionId | out-null
    try {
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $wsresourceGroupname -Name $ws.name
    }
    catch {
        Write-Error "Error finding workspace."
        break
    }
    $results=@()
    if ($workspace) {
        Write-host "Found workspace $($workspace.Name) in resource group $($workspace.ResourceGroupName) with id $($workspace.ResourceId)"
        foreach ($pack in $discoveryData.Packs) {
            Write-host "Running discovery for $($pack.Name)"
            $DiscoveryQuery = $pack.Discovery.Query
            # replace the workspace id in the query with the workspace id from the resource graph query
            $queryResults=Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId.Guid `
                                                            -Query $DiscoveryQuery `
                                                            -Timespan (New-TimeSpan -Hours 24) | Select-Object -ExpandProperty Results
            if ($queryResults.Count -eq 0) {
                Write-host "No discovery data found for $($pack.Name)"
            }
            else {
                #Return resourceID and tag for the pack
                $queryResults | ForEach-Object {
                    # Get location for the resource
                    $location=Get-AzResource -ResourceId $_.Computer -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Location
                    $result = @{} # Initialize as a hashtable
                    $result['Tag'] = $pack.Tag
                    $result['ResourceId'] = $_.Computer
                    $result['OS'] = $pack.OS
                    $result['Location'] = $location
                    $result['TimeGenerated'] = $timestamp
                    $results += $result
                }
            }
        }
    }
    else {
        Write-Error "No workspace found for instance name $instanceName"
        return {}
    }
    Write-host "Found $($results.count) results for discovery."
    $results
    if ($results.Count -eq 0) {
        Write-Host "No discovery data found."
        return $null
    }
    
   # try {
        # Send the results to the DCR
        Write-host "Sending discovery data to DCR..."
        Write-host "DCR Immutable Id: $($env:discoveryDCRImmutableId)"
        Write-host "Table Name: $($env:DiscoveryResultsTableName)"
        new-discoveryData -instanceName $instanceName -data $results -DcrImmutableId $env:discoveryDCRImmutableId -tableName $env:DiscoveryResultsTableName
        return $true
    #}
    #catch {
    #    Write-Error "Error sending discovery data to DCR. $_"
    #    return $null
    #}
}

function new-discoveryData {
    param (
        [Parameter(Mandatory = $true)]
        [string]$instanceName,
        [Parameter(Mandatory = $true)]
        [object]$data,
        [Parameter(Mandatory = $true)]
        [string]$DcrImmutableId,
        [Parameter(Mandatory = $true)]
        [string]$tableName,
        [Parameter(Mandatory = $false)]
        [string]$streamname,
        [Parameter(Mandatory = $false)]
        [bool]$localtest,
        [Parameter(Mandatory = $false)]
        [string]$appId,
        [Parameter(Mandatory = $false)]
        [string]$appSecret
    )
    #$dceId="https://amp-mcp1-dce-canadacentral-6f18.canadacentral-1.ingest.monitor.azure.com"
    # get DCE URL from the DCE Id, using a tag.
    $DCE=Get-AzDataCollectionEndpoint | Where-Object {$_.Tag['instanceName'] -eq $instanceName}
    $tenantId=(Get-AzContext).Tenant.Id
    if ($null -eq $DCE) {
        Write-Error "No DCE found for instance name $instanceName"
        return $null
    }
    else {
        Write-host "Found DCE $($DCE.Name) with id $($DCE.Id)"
        $dceurl=$DCE.LogIngestionEndpoint
        Write-host "DCE URL: $dceurl"
    }
    if ($localtest) {
        Add-Type -AssemblyName System.Web
        $scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
        $body = "client_id=$appId&scope=$scope&client_secret=$appSecret&grant_type=client_credentials";
        $headers = @{"Content-Type" = "application/x-www-form-urlencoded" };
        $uri = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
        $bearerToken = (Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers).access_token
    }
    else {
        $scope="https://monitor.azure.com"
        $bearerToken = (Get-AzAccessToken -ResourceUrl $scope -TenantId $tenantId ).Token
        #$bearerToken
    }
    # When using a managed identity, use the following line to get the token:
    # $scope = [System.Web.HttpUtility]::UrlEncode("https://monitor.azure.com//.default")   
    # if data is a hashtable, convert it to an array of objects
    if ($data.count -eq 1) {
        $body = "[$($data | ConvertTo-Json -Depth 10)]"
    }
    else {
        $body = $data | ConvertTo-Json 
    }
    
    $body
    if ([string]::IsNullOrEmpty($streamname)) {
        $streamname=("Custom-$tableName") #.Replace("_CL","")
        Write-host "No stream name provided, using default stream name. $streamname"
    }
    else {
        Write-host "Using stream name $streamname"
    }
    #$headers = @{"Authorization" = "Bearer $bearerToken"; "Content-Type" = "application/json" };
    # The stream name is what counts here and needs to match the stream name in the DCR.
    $uri = "$dceurl/dataCollectionRules/$DcrImmutableId/streams/$streamname"+"?api-version=2023-01-01";
    Write-host "Sending data to DCR at $uri"
    try {
        #$uploadResponse = Invoke-RestMethod -Uri $uri -Method "Post" -Body $body -Headers $headers;
        $uploadResponse=Invoke-RestMethod -Method Post -Uri $uri -Headers @{"Authorization"="Bearer $bearerToken"} -Body $body -ContentType "application/json"   
        Write-host "Data sent to DCR successfully."
        Write-host "Response: $($uploadResponse | ConvertTo-Json -Depth 10)"
    }
    catch {
        Write-Error "Error sending data to DCR: $_"
        return $null
    }
}

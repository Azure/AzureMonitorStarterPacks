# Functions needed
# Add discovery tags and installs required vm appliation
# Can determine discovery by OS, so each OS will have its own discovery DCR with different tags:

# Still needs to check if AMA is present and install if the case
# Discovery is equal to have the application installed on the VM, having the VM associated with the proper DCR.

# Discovery sources:
# MSI - result of query
# Registry - All or some
# File system - All or some
# Process - All or some
# Roles - All or some
# Services - all or some
# Programs - All or some
# OS Version - Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProductName ?
# $DiscoveryRequest=@{
#     "ADDS"  = @{
#         "tag"        = "ADDS"
#         "role"= "AD-Domain-Services"
#     }
#     "DNS2016"   = @{
#         "tag"        = "DNS"
#         "role"= "DNS"
#         "OSVersion"= "Windows Server 2016"
#     }
#     "IIS"   = @{
#         "tag"        = "IIS"
#         "application"= "Web-Server"
#         "OSVersion"= "Windows Server 2012"
#     }
#     "IIS2016"   = @{
#         "tag"        = "IIS2016"
#         "application"= "Web-Server"
#         "OSVersion"= "Windows Server 2016"
#     }
#     # Add more mappings as needed
# }
function get-discoveryData {
    $discoveryData=@"
{
    "Packs": [
        {
            "Name": "nginx",
            "Tag": "nginx",
            "Description": "Nginx is a high-performance HTTP server and reverse proxy.",
            "OS": "Linux",
            "Query": "let maxts=Discovery_CL\n| project timestamp=todatetime(tostring(split(RawData,\",\")[0]))\n| where isnotempty(timestamp)\n| summarize maxts=max(timestamp);\nDiscovery_CL\n| extend Computer=_ResourceId\n| extend fields=split(RawData,\",\")\n| extend timestamp=todatetime(fields[0])\n| extend type=tostring(fields[1])\n| extend platform=tostring(fields[2])\n| extend package=iff (platform =~ 'linux', tostring(fields[4]),'')\n| extend name=iff (platform =~ 'linux', tostring(fields[3]), tostring(fields[3]))\n| extend othertype=tostring(fields[5])\n| extend vendor=tostring(fields[6])\n| extend OSVersion=iff(platform =~ 'linux', '',tostring(fields[3]))\n| where timestamp == toscalar(maxts)\n| project timestamp,Computer,type,name,platform,OSVersion,othertype,vendor\n| where platform =~ 'linux'\n| where name == \"nginx\""
        },
        {
            "Name": "ADDS",
            "Tag": "ADDS",
            "Description": "Active Directory Domain Services",
            "OS": "Windows",
            "Query": "let maxts=Discovery_CL\n| project timestamp=todatetime(tostring(split(RawData,\",\")[0]))\n| where isnotempty(timestamp)\n| summarize maxts=max(timestamp);\nDiscovery_CL\n| extend Computer=_ResourceId\n| extend fields=split(RawData,\",\")\n| extend timestamp=todatetime(fields[0])\n| extend type=tostring(fields[1])\n| extend platform=tostring(fields[2])\n| extend package=iff (platform =~ 'windows', tostring(fields[4]),'')\n| extend name=iff (platform =~ 'windows', tostring(fields[3]), tostring(fields[3]))\n| extend othertype=tostring(fields[5])\n| extend vendor=tostring(fields[6])\n| extend OSVersion=iff(platform =~ 'windows', '',tostring(fields[3]))\n| where timestamp == toscalar(maxts)\n| project timestamp,Computer,type,name,platform,OSVersion,othertype,vendor\n| where platform =~ 'windows'\n| where name == \"AD-Domain-Services\""
        }
    ]
}
"@ | ConvertFrom-Json -Depth 10
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
    $discoveryData=get-discoveryData
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
            $DiscoveryQuery = $pack.Query
            # replace the workspace id in the query with the workspace id from the resource graph query
            $queryResults=Invoke-AzOperationalInsightsQuery -WorkspaceId $workspace.CustomerId.Guid -Query $DiscoveryQuery | Select-Object -ExpandProperty Results
            if ($queryResults.Count -eq 0) {
                Write-host "No discovery data found for $($pack.Name)"
                return "{}"
            }
            else {
                #Return resourceID and tag for the pack
                $queryResults | ForEach-Object {
                    $result = @{} # Initialize as a hashtable
                    $result['Tag'] = $pack.Tag
                    $result['ResourceId'] = $_.Computer
                    $result['OS'] = $pack.OS
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
    return $results | ConvertTo-Json
}
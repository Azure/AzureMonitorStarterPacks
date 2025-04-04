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
function get-discovermappings {
    $discoveringMappings = @{
        "ADDS"  = "AD-Domain-Services"
        "DNS"   = "DNS"
        "IIS"   = "Web-Server"
        "Nginx" = "nginx-core"
    }
    return $discoveringMappings.Keys | Select-Object @{l = 'tag'; e = { $_ } }, @{l = 'application'; e = { $discoveringMappings.$_ } }
}
function get-discoveryresults {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LogAnalyticsWSResourceId
    )
    Write-host "Running Discovery"
    $DiscoveryQuery=@"
let maxts=Discovery_CL | summarize timestamp=max(tostring(split(RawData,",")[0]));
Discovery_CL
| extend Computer=tostring(split(_ResourceId,'/')[8])//,timestamp=todatetime(timestamp)
| extend fields=split(RawData,",")
| extend timestamp=todatetime(fields[0])
| extend type=tostring(fields[1])
| extend platform=tostring(fields[2])
| extend OSVersion=tostring(fields[3])
| extend name=tostring(fields[4])
| extend othertype=tostring(fields[5])
| extend vendor=tostring(fields[6])
| where timestamp == toscalar(maxts)
| project timestamp,Computer,type,name,platform,OSVersion,othertype,vendor
"@
    $wsname=$LogAnalyticsWSResourceId.split('/')[8]
    $wsresourceGroupname=$LogAnalyticsWSResourceId.split('/')[4]    
    # Write-host "Getting WS"
    $subscriptionId = $LogAnalyticsWSResourceId.split('/')[2]
    # # change context to subscription
    Set-AzContext -Subscription $subscriptionId | out-null
    try {
        $workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $wsresourceGroupname -Name $wsname
    }
    catch {
        Write-Error "Error finding workspace."
        break
    }
    # Select subscription from workspace

    if ($workspace) {
        Write-host "Running Query"
        $DiscoveryData=Invoke-AzOperationalInsightsQuery -Workspace $workspace -Query $DiscoveryQuery | select -ExpandProperty Results
    }
    else {
        $DiscoveryData=@()
    }
    Write-host "Found $($DiscoveryData.Count) entries in discovery."
    $DMs=get-discovermappings
    $results=@()
    foreach ($app in $DiscoveryData | Where-Object { $_.name -in $DMs.application }) {
        Write-host "Finding applications in the Discovery mappings"
        # For each DM in DMs we need to find computers in $DiscoveryData that match the DM
        # get the tag for the application
        $result=$app
        $result | Add-Member -MemberType Noteproperty -Name 'tag' -Value ($DMs | Where-Object { $_.application -eq $app.name } | select -ExpandProperty tag)
        $results+=$result
    }
    Write-host "Found $($results.count) results for discovery."
    return $results | ConvertTo-Json
}
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$RepoUrl = $env:repoURL

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
$TagList = $Request.Body.Pack.split(',')
$PackType = $Request.Body.PackType
$LogAnalyticsWSAVD = $Request.Body.AVDLAW

if ($resources) {
    #$TagName='MonitorStarterPacks'
    $TagName = $env:SolutionTag
    if ([string]::isnullorempty($TagName)) {
        $TagName = 'MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    # Add the option for multiple tags, comma separated
    "Working on $($resources.count) resource(s). Action: $action. Altering $TagName in the resource."
    switch ($action) {
        'AddTag' {
            foreach ($TagValue in $TagList) {
                foreach ($resource in $resources) {
                    # Tagging
                    Add-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $TagValue
                    # Add Agent
                    if ($PackType -in ('IaaS', 'Discovery')) {
                        Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.location
                    }
                    # Add Tag Based condition.
                    if ($TagValue -eq 'Avd') {
                        # Create AVD alerts function.
                        $hostPoolName = ($resource.Resource -split '/')[8]
                        $resourceGroupName = ($env:PacksUserManagedId -split '/')[4]
                        Config-AVD -hostpoolName $hostPoolName -resourceGroupName $resourceGroupName -location $resource.location -TagName $TagName `
                        -TagValue $TagValue -action $action -LogAnalyticsWSAVD $LogAnalyticsWSAVD
                    }
                } # End of resource loop
            }
        }
        'RemoveTag' {
            foreach ($TagValue in $TagList) {
                foreach ($resource in $resources) {
                    # Tagging
                    Remove-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $TagValue -PackType $PackType
                }
                if ($TagValue -eq 'Avd') {
                    $hostPoolName = ($resource.Resource -split '/')[8]
                    $resourceGroupName = ($env:PacksUserManagedId -split '/')[4]
                    $LogAnalyticsWS = $Request.Body.AltLAW
                    Config-AVD -hostpoolName $hostPoolName -resourceGroupName $resourceGroupName `
                                -location $resource.location -TagName $TagName -TagValue $TagValue `
                                -action $action `
                                -LogAnalyticsWSAVD $LogAnalyticsWS
                }
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }
}
else {
    "No resources provided."
}
$body = "This HTTP triggered function executed successfully. $($resources.count) were altered ($action)."
#Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $body
    })

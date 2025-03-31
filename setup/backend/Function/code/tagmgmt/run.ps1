using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$RepoUrl = $env:repoURL
$instanceName=$env:INSTANCENAME
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
$TagList = $Request.Body.Pack.split(',')
$PackType = $Request.Body.PackType
$LogAnalyticsWSAVD = $Request.Body.AVDLAW
$ResourceType = $Request.Body.Type
$defaultAG=$Request.Body.DefaultAG
#$Request | convertto-json
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
          foreach ($resource in $resources) {
              # Tagging
              if ($PackType -in ('IaaS', 'Discovery')) {
                foreach ($TagValue in $TagList) {
                  $InstallDependencyAgent = ($TagValue -eq 'InsightsDep') ? $true : $false
                  Add-Tag -resourceId $resource.Resource `
                  -TagName $TagName `
                  -TagValue $TagValue `
                  -instanceName $instanceName `
                  -packType $PackType `
                  -resourceType 'Compute'
         #-instanceName $instanceName `
                 # -packType $PackType -actionGroupId $defaultAG -resourceType "microsoft.compute"
                  # Add Agent
                  Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
                }
              }
              else { #Paas or Platform
                "PackType: $PackType"
                "Adding tag for resource type: $ResourceType. Tagname: $TagName. Resource: $($resource.Resource)"
                Add-Tag -resourceId $resource.Resource `
                 -TagName $TagName `
                 -TagValue $ResourceType `
                 -resourceType $ResourceType `
                 -actionGroupId $defaultAG `
                 -packtype $packType `
                 -instanceName $instanceName `
                 -location $resource.location
                if ($TagValue -eq 'Avd') {
                  # Create AVD alerts function.
                  $hostPoolName = ($resource.Resource -split '/')[8]
                  $resourceGroupName = ($env:PacksUserManagedId -split '/')[4]
                  Config-AVD -hostpoolName $hostPoolName -resourceGroupName $resourceGroupName -location $resource.Location -TagName $TagName `
                  -TagValue $TagValue -action $action -LogAnalyticsWSAVD $LogAnalyticsWSAVD
                }
              }
              # Add Tag Based condition.
            }  # End of resource loop
        } # End of AddTag
        'RemoveTag' {
          foreach ($resource in $resources) {
            # Tagging
            if ($PackType -in ('IaaS', 'Discovery')) {
              foreach ($TagValue in $TagList) {
                Remove-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $TagValue -PackType $PackType
              }
            }
            else { #Paas or Platform
              "PackType: $PackType"
              "Removing Tag from service."
              Remove-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $resource.tag -PackType $PackType
              if ($TagValue -eq 'Avd') {
                # Create AVD alerts function.
                $hostPoolName = ($resource.Resource -split '/')[8]
                $resourceGroupName = ($env:PacksUserManagedId -split '/')[4]
                Config-AVD -hostpoolName $hostPoolName -resourceGroupName $resourceGroupName -location $resource.Location -TagName $TagName `
                -TagValue $TagValue -action $action -LogAnalyticsWSAVD $LogAnalyticsWSAVD
              }
            }
            # Add Tag Based condition.
          }  # End of resource loop
        }  # End of Remove Tag

            # foreach ($TagValue in $TagList) {
            #     foreach ($resource in $resources) {
            #         # Tagging
            #         Remove-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $TagValue -PackType $PackType
            #     }
            #     if ($TagValue -eq 'Avd') {
            #         $hostPoolName = ($resource.Resource -split '/')[8]
            #         $resourceGroupName = ($env:PacksUserManagedId -split '/')[4]
            #         Config-AVD -hostpoolName $hostPoolName -resourceGroupName $resourceGroupName `
            #                     -location $resource.Location -TagName $TagName -TagValue $TagValue `
            #                     -action $action `
            #                     -LogAnalyticsWSAVD $LogAnalyticsWSAVD
            #     }
            # }
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

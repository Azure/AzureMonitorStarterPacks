using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$RepoUrl = $env:AMBAJsonURL
$instanceName=$env:InstanceName
$InformationPreference='SilentlyContinue'
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$Request | convertto-json
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
if ($null -ne $Request.Body.Pack) {
  $TagList = $Request.Body.Pack.split(',')
} else {
  $TagList = @() # probably discovery pack
}
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
          if ($PackType -ne 'Paas') {
            if ($PackType -eq 'Discovery') {
              $TagValue = $resource.Pack
              # Add Agent if not installed yet.
              $InstallDependencyAgent = ($TagValue -eq 'InsightsDep') ? $true : $false
              Write-Host "Will try to install dependency agent: $InstallDependencyAgent. Tag is $TagValue"
              Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
              Write-Host "PackType: $PackType. Adding tag for resource type: $ResourceType. TagValue: $TagValue. Resource: $($resource.Resource)"
              Add-Tag -resourceId $resource.Resource `
              -TagName $TagName `
              -TagValue $TagValue `
              -instanceName $instanceName `
              -packType $PackType `
              -resourceType 'Compute'
            }
            else {
              # Add Agent if not installed yet.
              $InstallDependencyAgent = ($TagValue -eq 'InsightsDep') ? $true : $false
              Write-Host "Will try to install dependency agent: $InstallDependencyAgent. Tag is $TagValue"
              Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
              foreach ($TagValue in $TagList) {
                Add-Tag -resourceId $resource.Resource `
                -TagName $TagName `
                -TagValue $TagValue `
                -instanceName $instanceName `
                -packType $PackType `
                -resourceType 'Compute'
              }
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
          }
          # Add Tag Based condition.
        }  # End of resource loop
      } # End of AddTag
      'RemoveTag' {
        foreach ($resource in $resources) {
          # Tagging
          if ($PackType -ne 'Paas') {
            if ($PackType -eq 'Discovery') {
              $TagValue = $resource.Packs
              # Add Agent if not installed yet.
              Write-Host "PackType: $PackType. Removing tag for resource type: $ResourceType. TagValue: $TagValue. Resource: $($resource.Resource)"
              if ($TagValue -ne '') {
                Remove-Tag -resourceId $resource.Resource `
                  -TagName $TagName `
                  -TagValue $TagValue `
                  -instanceName $instanceName `
                  -packType $PackType
              }
              else {
                Write-host " Error: No tag value found for $($resource.Resource)"
              }
            }
            else {
              foreach ($TagValue in $TagList) {
                Write-host "TAGMGMT: removing $TagValue tag from $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
                Remove-Tag -resourceId $resource.Resource `
                            -TagName $TagName -TagValue $TagValue `
                            -PackType $PackType -instanceName $instanceName
              }
            }
          }
          else { #Paas or Platform
            Write-host "TAGMGMT: removing $TagValue tag from $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
            Remove-Tag -resourceId $resource.Resource -TagName $TagName -TagValue $resource.tag -PackType $PackType -instanceName $instanceName
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

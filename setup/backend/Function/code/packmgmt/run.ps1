using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
#$RepoUrl = $env:AMBAJsonURL
$instanceName=$env:InstanceName
$InformationPreference='SilentlyContinue'
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$Request | convertto-json -Depth 10
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
if ($action -eq 'importPack') {
    #read current pack from the url blob
  $newPacks=$Request.Body.PackDef | ConvertTo-Json -Depth 20
  Write-host "New Packs: $newPacks"
  if ([string]::IsNullOrEmpty($newPacks)) {
    Write-host "No new packs to import. Exiting."
    $body = "No new packs to import. Exiting."
    break
  }
  try {
    $newPacksList=$newPacks | convertfrom-json -Depth 20
  }
  catch {
    Write-host "Error converting JSON to object. $_"
    $body = "Error converting JSON to object. $_"
    break
  }
  Write-host "Found $($newPacksList.count) packs to import."
  # Check if the pack already exists in the blob
  $packsUrl=$env:PacksUrl
  Write-host "Reading current packs from $packsUrl"
  $PacksDef=get-blobcontentfromurl -url $packsUrl | convertfrom-json -Depth 20
  $currentPacks=$PacksDef.Packs
  $finalPackslist=$currentPacks + $newPacksList
  Write-host "New Packs list count: $($finalPackslist.count)"
  $NewPacksDef=@{Packs=$finalPackslist} 
  
  try {
    Write-host "Updating blob content in $packsUrl"
    update-blobcontentinURL -url $packsUrl -content $($NewPacksDef | ConvertTo-Json -Depth 20)
  }
  catch {
    Write-host "Error updating blob content in $PacksUrl. $_"
    $body = "Error updating blob content in $PacksUrl. $_"
  }
}
else {
  if ([string]::IsNullOrEmpty($Request.Body.Pack)) {
    $TagList = @() # probably discovery pack or packs from discovery being assigned to the resource.
  } else {
    $TagList = $Request.Body.Pack.split(',')
  }
  $PackType = $Request.Body.PackType
  $LogAnalyticsWSAVD = $Request.Body.AVDLAW
  $ResourceType = $Request.Body.Type
  $defaultAG=$Request.Body.DefaultAG
  $workspaceResourceId=$Request.Body.WorkspaceId
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
        'AddPack' {
          foreach ($resource in $resources) {
            Write-host "Resource: $resource"
            Write-host "ResourceId: $($resource.Resource)"
            Write-host "Resource Pack: $($resource.Pack)"
            Write-host "Resource OS: $($resource.OS)"
            # Tagging
            if ($PackType -ne 'Paas') {
              if ($PackType -eq 'Discovery') {
                $TagValue = $resource.Pack
                # Add Agent if not installed yet.
                $InstallDependencyAgent = ($Taglist -contains 'SvcMap') ? $true : $false
                if ($InstallDependencyAgent) {
                  Write-Host "Will try to install dependency agent: $InstallDependencyAgent. Tag list is $Taglist"
                }
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
                $InstallDependencyAgent = ($Taglist -contains 'InsightsDep') ? $true : $false
                if ($TagList.Count -eq 0) {
                  Write-host "Taglist is null. Setting to $($resource.Pack)"
                  $TagList = @($resource.Pack)
                }
                if ($InstallDependencyAgent) {
                  Write-Host "Will try to install dependency agent: $InstallDependencyAgent. Taglist is $TagList"
                }
                Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
                foreach ($TagValue in $TagList) {
                  Write-host "TAGMGMT: adding $TagValue tag to $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
                  Add-Tag -resourceId $resource.Resource `
                  -TagName $TagName `
                  -TagValue $TagValue `
                  -instanceName $instanceName `
                  -packType $PackType `
                  -resourceType 'Compute' `
                  -actionGroupId $defaultAG `
                  -workspaceResourceId $workspaceResourceId `
                  -location $resource.Location
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
        }  # End of AddPack
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
}
#Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $body
})

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
    import-pack -packNewDefinition $newPacks
    #$newPacksList=$newPacks | convertfrom-json -Depth 20
  }
  catch {
    Write-host "Error importing pack. $_"
    $body = "Error importing pack. $_"
    break
  }
}
else {
  if ([string]::IsNullOrEmpty($Request.Body.Pack)) {
    $TagList = @() # probably discovery pack or packs from discovery being assigned to the resource.
  } else {
    $TagList = $Request.Body.Pack.split(',')
  }
  $PackType = $Request.Body.PackType
  #$LogAnalyticsWSAVD = $Request.Body.AVDLAW
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
      Write-host "Working on $($resources.count) resource(s). Action: $action. Altering $TagName in the resource."
      Write-host "Resources: $($resources | convertto-json -Depth 10)"
      switch ($action) {
        'AddPack' {
          foreach ($resource in $resources) {
            # Write-host "Resource: $resource"
            # Write-host "ResourceId: $($resource.Resource)"
            # Write-host "Resource Pack: $($resource.Pack)"
            # Write-host "Resource OS: $($resource.OS)"
            # Tagging
            switch ($PackType) {
              'Iaas' {
                # check if adding multiple packs or a single pack.
                if ($TagList.Count -eq 0) {
                  Write-host "Taglist is null. Setting to $($resource.Pack)"
                  $TagList = @($resource.Pack)
                }
                $InstallDependencyAgent = ($Taglist -contains 'SvcMap') ? $true : $false
                if ($InstallDependencyAgent) {
                  Write-Host "Will try to install dependency agent? $InstallDependencyAgent. Taglist is $TagList"
                }
                Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
                foreach ($TagValue in $TagList) {
                  Write-host "TAGMGMT: adding $TagValue tag to $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
                  Add-Monitoring -resourceId $resource.Resource `
                    -TagName $TagName `
                    -TagValue $TagValue `
                    -instanceName $instanceName `
                    -packType $PackType `
                    -resourceType 'Compute' `
                    -actionGroupId $defaultAG `
                    -workspaceResourceId $workspaceResourceId `
                    -location $resource.Location
                }
                #start-opstasks
              }
              'Discovery' {
                $TagValue = $resource.Pack
                # Add Agent if not installed yet.
                $InstallDependencyAgent = ($Taglist -contains 'SvcMap') ? $true : $false
                if ($InstallDependencyAgent) {
                  Write-Host "Will try to install dependency agent: $InstallDependencyAgent. Tag list is $Taglist"
                }
                Add-Agent -resourceId $resource.Resource -ResourceOS $resource.OS -location $resource.Location -InstallDependencyAgent $InstallDependencyAgent
                Write-Host "PackType: $PackType. Adding tag for resource type: $ResourceType. TagValue: $TagValue. Resource: $($resource.Resource)"
                Add-Monitoring -resourceId $resource.Resource `
                    -TagName $TagName `
                    -TagValue $TagValue `
                    -instanceName $instanceName `
                    -packType $PackType `
                    -resourceType 'Compute' `
                    -workspaceResourceId $workspaceResourceId `
                    -actionGroupId $defaultAG `
                    -location $resource.Location
              }
              'PaaS'  {
                "PackType: $PackType"
                $ResourceType = $resource.type
                if ([string]::IsNullOrEmpty($ResourceType)) {
                  Write-host "Error: No resource type found for $($resource.Resource)"
                  break
                }
                "Adding tag for resource type: $ResourceType. Tagname: $TagName. Resource: $($resource.Resource)"
                Add-Monitoring -resourceId $resource.Resource `
                        -TagName $TagName `
                        -TagValue $ResourceType `
                        -resourceType $ResourceType `
                        -actionGroupId $defaultAG `
                        -packtype $packType `
                        -instanceName $instanceName `
                        -location $resource.location `
                        -workspaceResourceId $workspaceResourceId
                start-opstasks -TaskNames @("MonitoredServices","UnmonitoredServices")
              }
              default {
                Write-host "Invalid PackType: $PackType"
              }
            }
          }  # End of resource loop
        }  # End of AddPack
        'RemoveTag' {
          foreach ($resource in $resources) {
            # Tagging
            switch ($PackType) {
              'Iaas' {
                foreach ($TagValue in $TagList) {
                  Write-host "TAGMGMT: removing $TagValue tag from $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
                  Remove-Monitoring  -resourceId $resource.Resource `
                              -TagName $TagName -TagValue $TagValue `
                              -PackType $PackType -instanceName $instanceName
                }
              }
              'Discovery' {
                $TagValue = $resource.Packs
                # Add Agent if not installed yet.
                Write-Host "PackType: $PackType. Removing tag for resource type: $ResourceType. TagValue: $TagValue. Resource: $($resource.Resource)"
                if ($TagValue -ne '') {
                  Remove-Monitoring -resourceId $resource.Resource `
                    -TagName $TagName `
                    -TagValue $TagValue `
                    -instanceName $instanceName `
                    -packType $PackType
                }
                else {
                  Write-host " Error: No tag value found for $($resource.Resource)"
                }
              }
              'Paas' {
                Write-host "TAGMGMT: removing $TagValue tag from $($resource.Resource). PackType: $PackType. Instance Name: $instanceName"
                Remove-Monitoring -resourceId $resource.Resource -TagName $TagName -TagValue $resource.tag -PackType $PackType -instanceName $instanceName
              }
              default {
                Write-host "Invalid PackType: $PackType"
              }
            }
          }  # End of resource loop           
          start-opstasks
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

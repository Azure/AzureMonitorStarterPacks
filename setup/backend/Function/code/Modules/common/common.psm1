#######################################################################
# Common functions used in the Monitoring Packs backend functions.
#######################################################################
# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.

# this will be eventually used to update the local catalog from the repo.
# function get-AMBAJsonFromRepo {
#     param (
#         [string]$AMBAJsonURL = "https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json"
#     )
#     $AMBAJson = Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content # | ConvertFrom-Json
#     return $AMBAJson
# }
function get-AMBAJsonContent {
    $ambaJsonURL=$env:AMBAJsonURL
    if ($null -eq $ambaJsonURL) {
        Write-Host "Error fetching AMBA URL, stopping function"
        return $null
    }
    Write-Host "Fetching AMBA Catalog from $ambaJsonURL"
    get-blobContentFromUrl -url $ambaJsonURL 
}
# function get-AMBAJsonContent2 {
#     $StorageAccountName=$env:StorageAccountName
#     $ResourceGroupName=$env:ResourceGroup
#     Write-host "Storage Account: $StorageAccountName"
#     Write-host "RG: $ResourceGroupName"
#     $StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
#     $sacontext=New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -UseConnectedAccount
#     $ContainerName = "amba"
#     $BlobName = "amba-alerts.json"
#     $Destination = "$($env:TEMP)\$BlobName"
#     $Blob2HT = @{
#         Container        = $ContainerName
#         Blob             = $BlobName
#         Context          = $sacontext
#     }
#     # Check if the blob exists and is not older than 30 days
#     Write-host "Checking if blob exists and is not older than 30 days..."
#     $currentblob = Get-AzStorageBlob @Blob2HT #-ErrorAction SilentlyContinue
#     if ($null -ne $currentblob -and $currentblob.LastModified -gt (Get-Date).AddDays(-30)) {
#         Write-host "Blob found. Downloading to $Destination."
#         $BlobContent = Get-AzStorageBlobContent @Blob2HT -Force -Context $sacontext -Destination $Destination
#         # check if the file exists and was downloaded correctly
#         if (Test-Path $Destination) {
#             Write-host "Blob content downloaded successfully to $Destination file."
#             $AMBAJson = get-content $Destination
#         } else {
#             Write-host "Blob content not downloaded. Please check the blob name and container name."
#         }
#     } 
#     else {
#         Write-Host "Blob not found. Please check the blob name and container name."
#         # $AMBAJsonURL="https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json"
#         # Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content 
#         get-AMBAJsonFromRepo | Out-File -FilePath "amba-alerts.json" -Encoding utf8
#         # Write json contetnt to a blog in the storage account under the amba container using managed identity
#         $Blob1HT = @{
#             File             = "amba-alerts.json"
#             Container        = $ContainerName
#             Blob             = $BlobName
#             Context          = $sacontext
#             StandardBlobTier = 'Hot'
#         }
#         Set-AzStorageBlobContent @Blob1HT
#         $AMBAJson = get-content $BlobName
#     }
#     #$AMBAJson = Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content # | ConvertFrom-Json
#     return $AMBAJson
# }
function set-systemAssignedIdentity {
    param (
        [Parameter(Mandatory = $true)]
        [string]$subscriptionId,
        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$vmName
    )
    $URL = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName" + "?api-version=2018-06-01"
    $Method = "PATCH"
    $Body = @"
{
    "identity": {
        "type": "SystemAssigned"
    }
}
"@
    try {
        invoke-Azrestmethod -URI $URL -Method $Method -Payload $Body 
    }
    catch {
        Write-Host "Error setting identity. $($_.Exception.Message)"
    }
}
function install-extension {
    param(
        [Parameter(Mandatory = $true)]
        [string]$subscriptionId, 
        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$vmName, 
        [Parameter(Mandatory = $true)]
        [string]$location,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionName, #  AzureMonitorWindowsAgent or AzureMonitorLinuxAgent
        [Parameter(Mandatory = $true)]
        [string]$ExtensionTypeHandlerVersion, #1.2 for windows, 1.27 for linux
        [Parameter(Mandatory = $true)]
        [object]$tags,
        [Parameter(Mandatory = $false)]
        [string]$EnableAutomaticUpgrade="true",
        [Parameter(Mandatory = $true)]
        [string]$publisher
    )
    $Method = "PUT"
    $URL = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/extensions/$ExtensionName" + "?api-version=2023-09-01"
    $Body = @"
    {
        "properties": {
            "autoUpgradeMinorVersion": true,
            "enableAutomaticUpgrade": "$EnableAutomaticUpgrade",
            "publisher": "$publisher",
            "type": "$ExtensionName",
            "typeHandlerVersion": "$ExtensionTypeHandlerVersion",
            "settings": {
                "authentication": {
                    "managedIdentity": {
                        "identifier-name": "mi_res_id",
                        "identifier-value": "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/"
                    }
                }
            }
        },
        "location": "$location",
        "tags": $tags
    }
}
"@
    try {
        Invoke-AzRestMethod -URI $URL -Method $Method -Payload $Body
    }
    catch {
        Write-Host "Error installing agent. $($_.Exception.Message)"
    }
}
function Install-azMonitorAgent {
    param (
        [Parameter(Mandatory = $true)]
        $subscriptionId, 
        [Parameter(Mandatory = $true)]
        $resourceGroupName,
        [Parameter(Mandatory = $true)]
        $vmName, 
        [Parameter(Mandatory = $true)]
        $location,
        [Parameter(Mandatory = $true)]
        [string]$ExtensionName, #  AzureMonitorWindowsAgent or AzureMonitorLinuxAgent
        [Parameter(Mandatory = $true)]
        [string]$ExtensionTypeHandlerVersion, #1.2 for windows, 1.27 for linux,
        [Parameter(Mandatory = $false)]
        [Boolean]$InstallDependencyAgent=$false #1.2 for windows, 1.27 for linux,
    )
    "Installing "
    "Subscription Id: $subscriptionId"
    set-systemAssignedIdentity -subscriptionId $subscriptionId `
                                     -resourceGroupName $resourceGroupName `
                                     -vmName $vmName
    # Extension
    Set-AzContext -SubscriptionId $subscriptionId
    $tags = get-azvm -Name $vmName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
    install-extension -subscriptionId $subscriptionId `
        -resourceGroupName $resourceGroupName `
        -vmName $vmName `
        -location $location `
        -ExtensionName $ExtensionName `
        -ExtensionTypeHandlerVersion $ExtensionTypeHandlerVersion `
        -tags $tags `
        -publisher "Microsoft.Azure.Monitor"
    
    if ($InstallDependencyAgent) {
        install-extension -subscriptionId $subscriptionId `
            -resourceGroupName $resourceGroupName `
            -vmName $vmName `
            -location $location `
            -ExtensionName "DependencyAgentWindows" `
            -ExtensionTypeHandlerVersion "9.0" `
            -tags $tags `
            -EnableAutomaticUpgrade "false" `
            -publisher "Microsoft.Azure.Monitoring.DependencyAgent"
    }
}
# Depends on Function Install-azMonitorAgent
function Add-Agent {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$ResourceOS,
        [Parameter(Mandatory = $true)]
        [string]$location,
        [boolean]$InstallDependencyAgent=$false
    )
    $resourceName = $resourceId.split('/')[8]
    $resourceGroupName = $resourceId.Split('/')[4]
    # VM Extension setup
    $resourceSubcriptionId = $resourceId.split('/')[2]

    Write-Host "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
    if ($ResourceOS -eq 'Linux') {
        if ($resourceId.split('/')[7] -eq 'virtualMachines') {
            $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
        }
        else {
            $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue 
        }
    }
    else {
        if ($resourceId.split('/')[7] -eq 'virtualMachines') {
            $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
        }
        else {
            $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
        }
    }
    if ($agentstatus) {
        Write-Host "Azure Monitor Agent already installed."
        if ($InstallDependencyAgent) {
            Write-Host "Checking Dependency agent for machines with AMA already installed."
            # Check for Linux
            if ($ResourceOS -eq 'Linux') {
                if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                    $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
                    if ($agentstatus) {
                        Write-Host "Dependency Agent already installed."
                    }
                    else {
                        Write-Host "Dependency Agent not installed. Installing..."
                        install-extension -subscriptionId $resourceSubcriptionId `
                                          -resourceGroupName $resourceGroupName `
                                          -vmName $resourceName `
                                          -location $location `
                                          -ExtensionName "DependencyAgentLinux" `
                                          -ExtensionTypeHandlerVersion "9.0" 
                    }
                }
                else {
                    $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
                }
            }
            else {
                if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                    $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentWindows" -ErrorAction SilentlyContinue
                    if ($agentstatus) {
                        Write-Host "Dependency Agent already installed."
                    }
                    else {
                        Write-Host "Dependency Agent not installed. Installing..."
                        install-extension -subscriptionId $resourceSubcriptionId `
                                          -resourceGroupName $resourceGroupName `
                                          -vmName $resourceName `
                                          -location $location `
                                          -ExtensionName "DependencyAgentWindows" `
                                          -ExtensionTypeHandlerVersion "9.0" `
                                          -publisher "Microsoft.Azure.Monitoring.DependencyAgent"
                    }
                }
                else {
                    # ARC
                    $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "DependencyAgentWindows" -ErrorAction SilentlyContinue
                    if ($agentstatus) {
                        Write-Host "Dependency Agent already installed."
                    }
                    else {
                        Write-Host "Dependency Agent not installed. Installing..."
                        $agent=New-AzConnectedMachineExtension -Name DependencyAgentWindows `
                            -ExtensionType DependencyAgentWindows `
                            -Publisher Microsoft.Azure.Monitoring.DependencyAgent `
                            -ResourceGroupName $resourceGroupName `
                            -MachineName $resourceName `
                            -Location $location `
                            -EnableAutomaticUpgrade -Tag $tags
                    }
                }
            }
        }
    }
    else {
        "Agent not installed. Installing..."
        if ($ResourceOS -eq 'Linux') {
            # 
            if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
                    -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27" -InstallDependencyAgent $InstallDependencyAgent
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tagst = (Get-AzConnectedMachine -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags)
                # convert tags (dictionary or JSON) to hashtable
                $tags=@{}
                # foreach key in $tags, added an entry to $t2 hashtable and with the same value
                foreach ($key in $tagst.Keys) {
                    $tags[$key] = $tagst[$key]
                }
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName -MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
                if ($InstallDependencyAgent) {
                    $agent = New-AzConnectedMachineExtension -Name DependencyAgentLinux -ExtensionType DependencyAgentLinux -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName -MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
                }
            }
        }
        else {
            # Windows
            if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName `
                                        -vmName $resourceName -location $location `
                                        -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2" `
                                        -InstallDependencyAgent $installDependencyAgent
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tagst = (Get-AzConnectedMachine -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags)
                # convert tags (dictionary or JSON) to hashtable
                $tags=@{}
                # foreach key in $tags, added an entry to $t2 hashtable and with the same value
                foreach ($key in $tagst.Keys) {
                    $tags[$key] = $tagst[$key]
                }
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent `
                                    -Publisher Microsoft.Azure.Monitor `
                                    -ResourceGroupName $resourceGroupName `
                                    -MachineName $resourceName `
                                    -Location $location `
                                    -EnableAutomaticUpgrade `
                                    -Tag $tags
                if ($InstallDependencyAgent) {
                    $agent=New-AzConnectedMachineExtension -Name DependencyAgentWindows `
                                                           -ExtensionType DependencyAgentWindows `
                                                           -Publisher Microsoft.Azure.Monitoring.DependencyAgent `
                                                           -ResourceGroupName $resourceGroupName `
                                                           -MachineName $resourceName `
                                                           -Location $location `
                                                           -EnableAutomaticUpgrade `
                                                           -Tag $tags
                }
            }
        }
        if ($agent) {
            Write-Host "Agent installed."
        }
        else {
            Write-Host "Agent not installed."
        }
    }
    #End of agent installation
}
function Add-DCRa {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )
    Write-Host "Adding DCR association for $resourceId with tag $TagValue"
    Write-Host "Looking for DCR(s) with tag $TagValue"
    $DCRs=Get-AzDataCollectionRule | Where-Object {$_.Tag["MonitorStarterPacks"] -eq $TagValue -and $_.Tag["instanceName"] -eq $instanceName}
    Write-host "Found $($DCRs.count) rule(s)."
    Write-host "DCR id (s): $($DCRs.id)"
    if ($DCRs.count -eq 0) {
        Write-Host "No DCR found for $TagValue tag. Please check the tag value."
        return $false
    }
    foreach ($DCR in $DCRs) {
    #Check if the DCR is associated with the VM
        Write-host "Checking if DCR $($DCR.Name) is associated with $resourceId"
        $associated=Get-AzDataCollectionRuleAssociation -ResourceUri $resourceId | Where-Object { $_.DataCollectionRuleId -eq $DCR.Id }
        if ($null -eq $associated) {
            Write-Output "VM: $resourceName Pack: $TagValue) DCR: $($DCR.Name) not associated"
            # Create the association
            try {
                New-AzDataCollectionRuleAssociation -ResourceUri $resourceId -DataCollectionRuleId $DCR.Id -AssociationName "Association for $resourceName and $($DCR.Name)"
                Write-Output "Association created successfully."
            }
            catch {
                Write-Output "Error creating association: $($_.Exception.Message)"
                return $false
            }
        } 
        else {
            Write-Output "VM: $resourceName Pack: $Pack DCR: $($DCR.Name) already associated. All good."
        }
        Write-Output "VM: $resourceName Pack: $TagValue DCR: $($DCR.Name)"
    }
    return $true
}
function Remove-DCRa {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )

    $DCRQuery = @"
resources
| where type == "microsoft.insights/datacollectionrules"
| extend MPs=tostring(['tags'].MonitorStarterPacks), instanceName=tostring(['tags'].instanceName)
| where MPs=~'$TagValue' and instanceName=~'$instanceName'
| summarize by name, id
"@
    $DCRs = Search-AzGraph -Query $DCRQuery
    "Found rule(s) $($DCRs.name)."
    "DCR id (s): $($DCRs.id)"
    "resource: $resourceId"
    foreach ($DCR in $DCRs) {
        $associationQuery = @"
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0], ruleId=properties.dataCollectionRuleId
| where isnotnull(properties.dataCollectionRuleId)
| where resourceId =~ '$resourceId' and
ruleId =~ '$($DCR.id)'
"@
        #$associationQuery
        $association = Search-AzGraph -Query $associationQuery -UseTenantScope
        if ($association.count -gt 0) {
            "Found association $($association.name). Removing..."
            $resourceSubcriptionId = $resourceId.split('/')[2]
            $currentSub=(Get-AzContext).Subscription.Id
            if ($resourceSubcriptionId -ne $currentSub) {
                Set-AzContext -SubscriptionId $resourceSubcriptionId
            }
            Remove-AzDataCollectionRuleAssociation -TargetResourceId $resourceId -AssociationName $association.name
        }
        else {
            "No association Found."
        }
    }
}
# Depends on Function Remove-DCRa
function Remove-Monitoring {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$PackType,
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )
    "Running $action for $($resourceId) resource. TagValue: $TagValue"
    #[System.Object]$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
    if ($TagValue -eq 'All') { #This only applies (should) to IaaS and Discovery packs.
        # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings and vm applications.
        #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
        #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
        $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
        if ($null -ne $tag) {
            $taglist=$tag.$tagName.split(',')
            "Removing all associations $($taglist.count) for $taglist."
            foreach ($tagv in $taglist) {
                Write-Host "Removing association for $tagv. on $resourceId."
                Remove-DCRa -resourceId $resourceId -TagValue $tagv -instanceName $instanceName
                "Removing vm application(s) if any for $tagv tag and instance name $instanceName, if any."
                remove-vmapp -ResourceId $resourceId -packtag $tagv -instanceName $instanceName
                remove-tag -resourceId $resourceId -TagName $TagName -TagValue $tagv -instanceName $instanceName
            }
        }
        else {
                Write-Host "No tags found. Nothing to remove."
                return
        }
    }
    else {
           if ($PackType -eq 'IaaS' -or $PackType -eq 'Discovery') {
            "Removing DCR Association."
            Remove-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            "Removing vm application(s) if any for $tagvalue tag and instance name $instanceName, if any."
            remove-vmapp -ResourceId $resourceId -packtag $tagvalue -instanceName $instanceName
            "Removing tag $TagName for $TagValue."
            remove-tag -resourceId $resourceId -TagName $TagName -TagValue $TagValue -instanceName $instanceName
        }
        else {
            "Paas Pack. No need to remove association."
            "Will look for diagnostic settings to remove with specific name. Won't remove if that is not found since it could be for something else."
            try {
                $diagnosticConfig = Get-AzDiagnosticSetting -ResourceId $resourceId -Name "AMP-$TagValue" -ErrorAction SilentlyContinue
            }
            catch {
                $diagnosticConfig = $null
            }
            if ($diagnosticConfig) {
                "Found diagnostic setting. Removing..."
                Remove-AzDiagnosticSetting -ResourceId $resourceId -Name "AMSP-$TagValue"
            }
            else {
                "No diagnostic setting found."
            }
            # Need to remove alert rules for the specific resource.
            # Find the alert rules for the resource using the resourceId and graph query.
            Write-host "Debug(Remove-Monitoring): removing alert rules for $resourceId"
            $graphQuery = @"
            resources
| where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
| where isnotempty(tags.MonitorStarterPacks)
| project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, Resource=tostring(properties.scopes[0])
| where Resource =~ '$resourceId'
"@
            $alertRules = Search-AzGraph -Query $graphQuery -UseTenantScope
            Write-host "Found $($alertRules.count) alert rule(s) for $resourceId."
            foreach ($alertRule in $alertRules) {
                Write-host "Found alert rule $($alertRule.Name) for $resourceId. Removing..."
                Remove-AzResource -ResourceId $alertRule.id -Force -ErrorAction SilentlyContinue
            }
        }
    }
}
function get-alertApiVersion {
    param (
    [Parameter(Mandatory = $true)]
    [string]$alertId)
    # Get the specific resource
    $resource = Get-AzResource -ResourceId $alertId
    # Get the resource provider and resource type
    $providerNamespace = $resource.ResourceType.Split('/')[0]
    $resourceType = $resource.ResourceType.Split('/')[1]
    # Get the resource provider
    $provider = Get-AzResourceProvider -ProviderNamespace $providerNamespace
    # Get the API versions for the resource type
    $apiVersions = $provider.ResourceTypes | Where-Object ResourceTypeName -eq $resourceType | Select-Object -ExpandProperty ApiVersions
    # The most recent API version is the first one in the list
    $apiVersion = $apiVersions[0]
    return $apiVersion
}
# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
# function Install-azMonitorAgent {
#     param (
#         [Parameter(Mandatory = $true)]
#         $subscriptionId, 
#         [Parameter(Mandatory = $true)]
#         $resourceGroupName,
#         [Parameter(Mandatory = $true)]
#         $vmName, 
#         [Parameter(Mandatory = $true)]
#         $location,
#         [Parameter(Mandatory = $true)]
#         [string]$ExtensionName, #  AzureMonitorWindowsAgent or AzureMonitorLinuxAgent
#         [Parameter(Mandatory = $true)]
#         [string]$ExtensionTypeHandlerVersion #1.2 for windows, 1.27 for linux,
#     )
#     "Subscription Id: $subscriptionId"
#     # Identity 
#     $URL = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName" + "?api-version=2018-06-01"
#     $Method = "PATCH"
#     $Body = @"
# {
#     "identity": {
#         "type": "SystemAssigned"
#     }
# }
# "@
#     try {
#         invoke-Azrestmethod -URI $URL -Method $Method -Payload $Body 
#     }
#     catch {
#         Write-Host "Error setting identity. $($_.Exception.Message)"
#     }
#     # Extension
#     Set-AzContext -SubscriptionId $subscriptionId
#     $tags = get-azvm -Name $vmName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
#     $Method = "PUT"
#     $URL = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/extensions/$ExtensionName" + "?api-version=2023-09-01"
#     $Body = @"
#     {
#         "properties": {
#             "autoUpgradeMinorVersion": true,
#             "enableAutomaticUpgrade": true,
#             "publisher": "Microsoft.Azure.Monitor",
#             "type": "$ExtensionName",
#             "typeHandlerVersion": "$ExtensionTypeHandlerVersion",
#             "settings": {
#                 "authentication": {
#                     "managedIdentity": {
#                         "identifier-name": "mi_res_id",
#                         "identifier-value": "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.ManagedIdentity/userAssignedIdentities/"
#                     }
#                 }
#             }
#         },
#         "location": "$location",
#         "tags": $tags
#     }
# }
# "@
#     try {
#         Invoke-AzRestMethod -URI $URL -Method "PUT" -Payload $Body
#     }
#     catch {
#         Write-Host "Error installing agent. $($_.Exception.Message)"
#     }
# }
function Remove-Agent {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$ResourceOS,
        [Parameter(Mandatory = $true)]
        [string]$location
    )
    $resourceName = $resourceId.split('/')[8]
    $resourceGroupName = $resourceId.Split('/')[4]
    # VM Extension setup
    $resourceSubcriptionId = $resourceId.split('/')[2]
    if ($ResourceOS -eq 'Linux') {
        $agentstatus=Get-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
    }
    else {
        $agentstatus=Get-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
    }
    if (!$agentstatus) {
        "Agent not installed."
    }
    else {
        "Agent installed. Removing..."
        if ($ResourceOS -eq 'Linux') { # 
            if ($resource.id.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - remove extension
                Remove-AzVMExtension -Name AzureMonitorLinuxAgent -ResourceGroupName $resourceGroupName  -VMName $resourceName -Force
                # install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $resource.location `
                # -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27"
                # #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.location -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine - remove extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                Remove-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ResourceGroupName $resourceGroupName -MachineName $resourceName
            }
        }
        else { # Windows
            if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - remove extension
                Remove-AzVMExtension -Name AzureMonitorWindowsAgent -ResourceGroupName $resourceGroupName  -VMName $resourceName -Force
                # install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $resource.location `
                # -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
                # #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -VMName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine - remove extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                Remove-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ResourceGroupName $resourceGroupName -MachineName $resourceName
            }
        }
    }
}
function Add-Monitoring { # This adds a single pack to a single resource.
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$instanceName,
        [Parameter(Mandatory = $true)]
        [string]$packType,
        [Parameter(Mandatory = $true)]
        [string]$resourceType,
        [Parameter(Mandatory = $true)]
        [string]$actionGroupId,
        [Parameter(Mandatory = $true)]
        [string]$workspaceResourceId,
        [Parameter(Mandatory = $true)]
        [string]$location
    )
    $resourceName = $resourceId.split('/')[8]
    Write-Host "Resource: $resourceId"
    Write-Host "Running $action for $resourceName resource. TagValue: $TagValue"
    # Action Group IP:
    Write-host "Add-monitoring: Action Group ID: $actionGroupId"
    $resourceGroupName = $env:resourceGroup
    #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
    # Checks current tags on the resource.
    
    #$tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
    #"Current tags: $($tag)"
    # if ($null -eq $tag) {
    #     # initializes if no tag is there.
    #     $tag = @{}
    # }
    # Different approach for IaaS, Discovery and PaaS packs.
    switch ($packType) {
        'IaaS' { 
            #Will check if the required DCRs and alerts already exist. If not, it will create them.
            Write-host "Installing pack for $TagValue, if not installed yet."
            $packDef=new-pack -location $location `
                -instanceName $instanceName `
                -resourceGroup $resourceGroupName `
                -workspaceId $workspaceResourceId `
                -packtag $TagValue `
                -AGId $actionGroupId `
                -urlDeployment `
                -installBicep
            # Once Pack is installed, need to know what else is required for the pack, like Agents, VM Applications, etc.
            # Once the DCRs is in place, add association to the VM (this being IaaS).
            try {
                Add-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            }
            catch {
                Write-host "Error adding association for $TagValue. Not adding tag or adding VM application."
                return
            }
            Write-host "Checking if the pack needs a VM application: $($packDef.Agents)"
            if (!([string]::isnullorempty($packdef.Rules.ClientAppName))) {
                # Need a VM application for the pack. This is only for IaaS packs.
                Write-host "Addinng VM application for $TagValue."
                try {
                    New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue
                    Write-host "VM application created for $TagValue, if any. Adding tag."
                }
                catch {
                    Write-host "Error creating VM application for $TagValue. Not adding tag."
                    # should eventually remove association if was created, since the pack is not functional with out the VM application.
                    Write-host "Removing DCR association for $TagValue since VM application was not created."
                    Remove-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
                    return
                }
            }
            # Finally, add the tag to the resource if nothing else failed before.
            try {
                New-Tag -ResourceId $resourceId -TagName $TagName -TagValue $TagValue -instanceName $instanceName
            }
            catch {
                Write-host "Error adding tag to resource $resourceId. $($_.Exception.Message)"
                # should remove VM App and association since pack tag is not there.
                return
            }
        }
        'Discovery' { 
            # Add rule association to the DCR for the pack (discovery)
            try {
                Add-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            }
            catch {
                Write-host "Error adding association for $TagValue. Not adding tag or adding VM application."
                return
            }
            # Add VM application for the pack, if required. For discovery packs, this is always required.
            Write-host "Addinng VM application for $TagValue."
            try {
                New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue
                Write-host "VM application created for $TagValue, if any. Adding tag."
            }
            catch {
                Write-host "Error creating VM application for $TagValue. Not adding tag."
                # should eventually remove association if was created, since the pack is not functional with out the VM application.
                Write-host "Removing DCR association for $TagValue since VM application was not created."
                Remove-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
                return
            }
            try {
                New-Tag -ResourceId $resourceId -TagName $TagName -TagValue $TagValue -instanceName $instanceName
            }
            catch {
                Write-host "Error adding tag to resource $resourceId. $($_.Exception.Message)"
                # should remove VM App and association since pack tag is not there.
                return
            }
            # if ($null -ne $packDef.Agents) {
            #     # Need a VM application for the pack. This is only for IaaS packs and discovery.
            #     Write-host "Addinng VM application for $TagValue."
            #     try {
            #         New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue
            #         Write-host "VM application created for $TagValue, if any. Adding tag."
            #     }
            #     catch {
            #         Write-host "Error creating VM application for $TagValue. Not adding tag."
            #         # should eventually remove association if was created, since the pack is not functional with out the VM application.
            #         Write-host "Removing DCR association for $TagValue since VM application was not created."
            #         Remove-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            #         return
            #     }
            # }
        }
        'PaaS' { 
            new-PaaSAlert -packTag $resourceType `
                            -TagName $TagName `
                            -resourceId $resourceId `
                            -actionGroupId $actionGroupId `
                            -resourceGroupName $resourceGroupName `
                            -instanceName $instanceName `
                            -resourceType $resourceType `
                            -location "global"
            #Update-AzTag -ResourceId $resourceId -Tag $resourceType -Operation Replace
        }
        default { Write-Host "Unknown pack type. Exiting." ; return }
    }
}
function New-Tag {
    param (
        [Parameter(Mandatory=$true)]
        [string]$TagName,
        [Parameter(Mandatory=$true)]
        [string]$resourceId,
        [Parameter(Mandatory=$true)]
        [string]$TagValue,
        [Parameter(Mandatory=$true)]
        [string]$instanceName
    )
    $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
    $updateTag = $false
    if ($null -eq $tag) {
        # initializes if no tag is there in the resource
        $tag = @{}
    }
    if ($tag.Keys -notcontains $TagName) {
        # doesn´t have the monitoring tag - Adding a new tag and value
        $tag.Add($TagName, $TagValue) # this is the first time we add the tag
        # also add the instance name tag (instanceName)
        # check if the instance name tag already exists. If not, add it.
        if ($tag.Keys -notcontains 'instanceName') {
            $tag.Add('instanceName', $instanceName)
        }
        $updateTag = $true
    }
    else {
        # if the tag already exists, check if the value is already there
        if ($tag.$tagName.Split(',') -notcontains $TagValue) {
            $tag[$TagName] += ",$TagValue"
            $updateTag = $true   
        }
        else {
            "$TagName already has the $TagValue value."
        }
    }
    if ($updateTag) {
        Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace 
    }
}
function Remove-Tag {
    param (
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )
    [System.Object]$tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
    if ($tag.count -eq 0) {
        # initializes if no tag is there.
        "No tags to remove."
        return
    }
    else {
        if ($tag.Keys -notcontains $tagName) {
            # doesn´t have the monitoring tag
            "No monitoring tag, can't delete the value. Something is wrong"
        }
        if ($TagValue -eq 'All') {
            # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings and vm applications.
            #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
            #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
            $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
            # if tag is not null, remove the tag.

            #$taglist=$tag.$tagName.split(',')
            # "Removing all associations $($taglist.count) for $taglist."
            # foreach ($tagv in $taglist) {
            #     Write-Host "Removing association for $tagv. on $resourceId."
            #     Remove-DCRa -resourceId $resourceId -TagValue $tagv -instanceName $instanceName
            #     "Removing vm application(s) if any for $tagv tag and instance name $instanceName, if any."
            #     remove-vmapp -ResourceId $resourceId -packtag $tagv -instanceName $instanceName
            # }
            #removes the monitoring tag from the resource.
            $tag.Remove($tagName)
            #removes the instance name tag from the resource.
            $tag.Remove('instanceName')
            if ($tag.count -ne 0) {
                #updating since resource has other tags.
                Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
            }
            else {
                $tagToRemove = @{"$($TagName)" = "$($tag.$tagValue)" }
                Update-AzTag -ResourceId $resourceId -Tag $tagToRemove -Operation Delete
                # Also remove the instance name tag.
                $tagToRemove = @{"instanceName" = "$($instanceName)" }
                Update-AzTag -ResourceId $resourceId -Tag $tagToRemove -Operation Delete
            }
        }
        else {
            if ($tag.$tagName.Split(',') -notcontains $TagValue) {
                "Tag exists, but not the value. Can't remove it. Something is wrong."
            }
            else {
                [System.Collections.ArrayList]$tagarray = $tag[$tagName].split(',')
                $tagarray.Remove($TagValue)
                if ($tagarray.Count -eq 0) {
                    "Removing tag since it has no values."
                    $tag.Remove($tagName)
                    "Also removing instance name tag since it is empty."
                    $tagToRemove = @{"$($TagName)" = "$($tag.$tagValue)"; "instanceName" = "$($instanceName)" }
                    Update-AzTag -ResourceId $resourceId -Tag $tagToRemove -Operation Delete
                }
                else {
                    $tag[$tagName] = $tagarray -join ','
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
            }
        }
    }
}
function Remove-PaaSAlertRules {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId)
    # for the specific Resource ID, find alert rules that have the tag "MonitorStarterPacks" and the resource Id as target(scope)
    Write-Host "Removing PaaS alerts for $resourceId"
    $AlertsToRemoveQuery = @"
    resources
| where tolower(type) in ("microsoft.insights/scheduledqueryrules","microsoft.insights/metricalerts","microsoft.insights/activitylogalerts")
| where isnotempty(tags.MonitorStarterPacks)
| extend scopes = (properties.scopes)
| where scopes contains '$ResourceId'
"@
    $AlertsToRemoveQuery
    $AlertsToRemove = Search-AzGraph -Query $AlertsToRemoveQuery -UseTenantScope
    Write-Host "Found $($AlertsToRemove.Count) alert rules to remove."
    if ($AlertsToRemove) {
        foreach ($alert in $AlertsToRemove) {
            Write-Host "Removing alert rule $($alert.name)"
            if ($alert.type -eq 'microsoft.insights/scheduledqueryrules') {
                Remove-AzScheduledQueryRule -ResourceGroupName $alert.resourceGroup -Name $alert.name -Force
            }
            elseif ($alert.type -eq 'microsoft.insights/metricalerts') {
                Remove-AzMetricAlertRuleV2 -ResourceGroupName $alert.resourceGroup -Name $alert.name -Force
            }
            elseif ($alert.type -eq 'microsoft.insights/activitylogalerts') {
                Remove-AzActivityLogAlert -ResourceGroupName $alert.resourceGroup -Name $alert.name
            }
        }
    }
    else {
        Write-Host "No alerts found to remove."
    }
}
function new-staticCriterionAlert {
    param (
    [Parameter(Mandatory=$true)]
        [object]$alert,
    [Parameter(Mandatory=$true)]
        [string]$packtag,
    [Parameter(Mandatory=$true)]
        [string]$tagName,
    [Parameter(Mandatory=$true)]
        [string]$resourceId,
    [Parameter(Mandatory=$true)]
        [string]$actionGroupId,
    [Parameter(Mandatory=$true)]
        [string]$resourceGroupName,
    [Parameter(Mandatory=$true)]
        [string]$instanceName,
    [Parameter(Mandatory=$true)]    
        [string]$resourceType
    )
    # user resourcegroup name where the resource is located.
    $resourceGroupName=$resourceId.Split('/')[4]
    $subscriptionId=$resourceId.Split('/')[2]
    $resourceName=$resourceId.Split('/')[8]
    # get current context and set the subscription to the one where the resource is located, if needed.
    $currentSub=(Get-AzContext).Subscription.Id
    if ($subscriptionId -ne $currentSub) {
        Set-AzContext -SubscriptionId $subscriptionId
    }
    $rulename="AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace)".Replace("%","Pct").Replace("/","-")
    Write-host "Creating StaticThresholdCriterion alert: $rulename in $resourceGroupName, subscription $subscriptionId."
    $condition=New-AzMetricAlertRuleV2Criteria  -MetricName $alert.Properties.metricName `
                                                -MetricNamespace $alert.Properties.metricNameSpace `
                                                -Operator $alert.Properties.operator `
                                                -Threshold $alert.Properties.threshold `
                                                -TimeAggregation $alert.Properties.timeAggregation
    $automaticMitigation=$null -eq $alert.Properties.autoMitigate ? $false : $alert.Properties.autoMitigate              
    $newRule=Add-AzMetricAlertRuleV2    -Name $rulename `
                                        -ResourceGroupName $resourceGroupName `
                                        -TargetResourceId $resourceId `
                                        -Description $alert.description `
                                        -Severity $alert.Properties.severity `
                                        -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                        -Condition $condition `
                                        -WindowSize ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
                                        -ActionGroupId $actionGroupId `
                                        -AutoMitigate $automaticMitigation `
                                        -Verbose                                           
    $tag = @{
        $tagName=$packtag
        "instanceName"=$instanceName
    }
    if ($newRule) {
        Write-host "Setting Tag in alert rule $($newRule.Id) with tag $($tagName) and value $($packtag) and adding Instance Name $instanceName."
        Update-AzTag -ResourceId $newRule.Id -Tag $tag -Operation Replace
    }
    else {
        Write-Host "Error creating alert rule."
        return $false
    }
}
function new-PaaSAlert {
    param (
    [Parameter(Mandatory=$true)]
    [string]$packTag,
    [Parameter(Mandatory=$true)]
    [string]$TagName,
    [Parameter(Mandatory=$true)]
    [string]$resourceId,
    [Parameter(Mandatory=$true)]
    [string]$actionGroupId,
    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$instanceName,
    [Parameter(Mandatory=$true)]
    [string]$resourceType,
    [Parameter(Mandatory=$true)]
    [string]$location
)
    $category=$resourceType.Split('/')[0].split(".")[1]
    $subCategory=$resourceType.Split('/')[1]
    $subscriptionId=$resourceId.Split('/')[2]
    $resourceName=$resourceId.Split('/')[8]
    # get current context and set the subscription to the one where the resource is located, if needed.
    $currentSub=(Get-AzContext).Subscription.Id
    if ($subscriptionId -ne $currentSub) {
        Set-AzContext -SubscriptionId $subscriptionId
    }
    $resourceType="{0}/{1}" -f $resourceId.Split('/')[6],$resourceId.Split('/')[7]
    "Creating New PaaS alert for $resourceId of type $resourceType."
    $ambaAlerts=(get-AMBAJsonContent | convertfrom-json).$category.$subCategory # | where {$_.properties.metricNamespace -eq $resourceType -and $_.properties.metricName -ne $null}
    if ($ambaAlerts.count -eq 0) {
        Write-Host "No alerts found for $resourceType."
        exit
    }
    else {
        Write-Host "Found $($ambaAlerts.count) alerts for $resourceType."
    }
    foreach ($alert in $ambaAlerts ) {
        if ($alert.type -eq 'metric') {
            # Check if the metric applies to the resource in question.
            if ($alert.properties.metricNamespace -ne $resourceType) {
                Write-Host "Alert $($alert.name) does not apply to $resourceType. Metric Name space is : $($alert.properties.metricNamespace).Skipping."
                continue
            }
            else {
                $alertType=$alert.Properties.criterionType
                switch ($alertType) {
                    'StaticThresholdCriterion' {
                        new-staticCriterionAlert -alert $alert `
                                                -packtag $packTag `
                                                -tagName $TagName `
                                                -resourceId $resourceId `
                                                -actionGroupId $actionGroupId `
                                                -instanceName $instanceName `
                                                -resourceType $resourceType `
                                                -resourceGroupName $resourceGroupName
                    }
                    'DynamicThresholdCriterion' {
                        "Creating DynamicThresholdCriterion alert."
                        $condition=New-AzMetricAlertRuleV2Criteria  -MetricName $alert.Properties.metricName `
                                                                    -MetricNamespace $alert.Properties.metricNameSpace `
                                                                    -Operator $alert.Properties.operator `
                                                                    -DynamicThreshold `
                                                                    -TimeAggregation $alert.Properties.timeAggregation `
                                                                    -ViolationCount $alert.properties.failingPeriods.numberOfEvaluationPeriods `
                                                                    -ThresholdSensitivity $alert.Properties.alertSensitivity 
                        $rulename="AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace)".Replace("%","Pct").Replace("/","-")
                        $automaticMitigation=$null -eq $alert.Properties.autoMitigate ? $false : $alert.Properties.autoMitigate 
                        $newRule=Add-AzMetricAlertRuleV2 -Name $rulename `
                                                        -ResourceGroupName $resourceGroupName `
                                                        -TargetResourceId $resourceId `
                                                        -Description $alert.description `
                                                        -Severity $alert.Properties.severity `
                                                        -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                                        -Condition $condition `
                                                        -AutoMitigate $automaticMitigation `
                                                        -WindowSize ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
                                                        -ActionGroupId $actionGroupId 
                        #update rule with new tags
                        $tag = @{
                            $tagName=$packTag
                            "instanceName"=$instanceName
                        }
                        Write-host "Setting Tag in alert rule $($newRule.Id) with tag $($tagName) and value $($packtag) and adding Instance Name $instanceName."
                        Update-AzTag -ResourceId $newRule.Id -Tag $tag -Operation Replace
                    }
                    default {
                        Write-Host "Unknown criterion type"
                    }
                }
            }
        }
        #Activity Log
        if ($alert.type -eq 'ActivityLog') {
            "Creating Activity Log Alert."       
            $condition1=New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Equal Administrative -Field category
            $any1=New-AzActivityLogAlertAlertRuleLeafConditionObject -Field properties.status -Equal "$($alert.properties.status)"
            $any2=New-AzActivityLogAlertAlertRuleLeafConditionObject -Equal "$($alert.properties.operationName)" -Field operationName
            $condition2=New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -AnyOf $any1,$any2
            $actiongroup=New-AzActivityLogAlertActionGroupObject -Id $actionGroupId
            New-AzActivityLogAlert -Name "AMP-$instanceName-$resourceName-$($alert.Name)" `
                                -ResourceGroupName $resourceGroupName `
                                -Description $alert.description `
                                -Scope $resourceId `
                                -Action $actiongroup `
                                -Condition @($condition1,$condition2) `
                                -Tag @{$tagName=$packTag; "instanceName"=$instanceName} `
                                -Location "global"                         
        }
    }
    New-Tag -ResourceId $resourceId -TagName $tagName -TagValue $packTag -instanceName $instanceName

}
function get-AmbaCatalog {
    Write-Host "Get-AmbaCatalog: Fetching AMBA Catalog from storage account."
    $ambaJSONContent=get-AMBAJsonContent #-ambaJsonURL $ambaJsonURL
    if ($null -eq $ambaJSONContent) {
        Write-Host "Error fetching AMBA JSON content."
        return $false
    }
    $aaa=$ambaJSONContent | convertfrom-json -Depth 10
    $Categories=$aaa.psobject.properties.Name
    #$Categories
    $body=@"
    {
        "Categories": [
"@
    $i=0
    foreach ($category in $Categories) {
        $svcs=$aaa.$($category).psobject.properties.Name
        foreach ($svc in $svcs) {
            $namespace="microsoft.$($category.tolower())/$($svc.tolower())"
            if ($null -ne $aaa.$category.$svc.name) {                  
                if ($null -ne $aaa.$category.$svc[0].properties.metricNamespace) {
                    $metricnamespace=$aaa.$category.$svc[0].properties.metricNamespace.tolower()
                }
                else {
                    $metricnamespace="microsoft.$($category.tolower())/$($svc.tolower())"
                }
                $metricDetails=@(
                    foreach ($metric in $aaa.$category.$svc.properties.metricName) {
                        $metric
                    }
                ) -join "`n"
                $bodyt=@"
          {
            "category" : "$category",
            "service" : "$svc",
            "namespace": "$namespace",
            "metricnamespace": "$metricnamespace",
            "tag": "$namespace",
            "NumberOfMetrics": $($aaa.$category.$svc.Count),
            "Details": "$metricDetails",
          }
"@          
                if ($i -eq 0) {
                    $body+=@"
                    $bodyt
"@
                    $i++
                }
                else {
                    $body+=@"
            ,
                 $bodyt
"@
                } #
            } # if the name is not null
        } #foreach svc
    } #category foreach
            $body+=@"
            ]
            }
"@
    return $body
}
function new-pack {
    param (
        # Parameter help description
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the package to be created.")]
        [string]$packtag,
        #location
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the location.")]
        [string]$location,
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the instance.")]
        [string]$instanceName = $env:InstanceName,
        #resource group
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the resource group.")]
        [string]$resourceGroup = $env:ResourceGroupName,
        #workspaceId
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the workspaceId.")]
        [string]$workspaceId,
        #agId
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the agId.")]
        [string]$AGId = $env:AGId,
        #urlDeploymentSwitch
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the urlDeploymentSwitch.")]
        [switch]$urlDeployment,
        #installBicepSwitch
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the installBicepSwitch.")]
        [switch]$installBicep
    )
    $modulesRoot = "./modules"
    $modulesURLroot=$env:PacksModulesRootURL
    try {
        "Collecting pack content from URL: $packContentURL"
        $packlist = get-blobcontentfromurl -url $env:PacksURL | ConvertFrom-Json -Depth 15
    }
    catch {
        Write-Error "Failed to fetch pack content from URL: $packContentURL. $_"
        return $false
    }
    $DceId=(Get-AzDataCollectionEndpoint | Where-Object {$_.Tag['instanceName'] -eq $instanceName}).Id
    if (!$DceId) {
        Write-Error "No DCE Id found!"
    }
    #$packlist=get-content ./packs/packsdef.json | ConvertFrom-Json -Depth 15
    Write-host "Found $($packlist.Packs.Count) packs in the file. "
    Write-host "Available Tags: $($packlist.Packs | Select-Object -ExpandProperty Tag | Sort-Object -Unique)"
    $packs=$packlist.Packs | Where-Object { $_.Tag -eq $packtag } # there should be only one pack with the tag.
    Write-host "Found $($packs.Count) packs for tag $($packtag)."
    if ($packs.Count -eq 0) {
        Write-Host "No packs found for tag $($packtag)."
        return $false
    }
    else {
        #install bicep
        if ($installBicep) {
            # test if bicep is installed
            $bicepInstalled = Get-Command bicep -ErrorAction SilentlyContinue
            if ($bicepInstalled) {
                Write-Host "Bicep is already installed. Version: $($bicepInstalled.Version)"
            }
            else {
                # install bicep
                $installPath = "$env:USERPROFILE\.bicep"
                $installDir = New-Item -ItemType Directory -Path $installPath -Force
                $installDir.Attributes += 'Hidden'
                # Fetch the latest Bicep CLI binary
                (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
                # Add bicep to your PATH
                $currentPath = $env:PATH
                if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
                if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
            }
        }
    }
    if ($packs.Count -gt 0) {
        Write-Host "At least one pack found for tag $($packtag). It should be the only one!"
                # Download pack templates from modules URL
        if ($urlDeployment) {
            Write-Host "Downloading pack templates from URL: $modulesURLroot"
            get-blobContainerContentFromUrl -url $modulesURLroot -DestinationPath $env:temp
            # $alertfilestoDownload =@('alert.bicep','alerts.bicep','scheduledqueryruleAggregate.bicep','scheduledqueryruleRows.bicep')
            # foreach ($file in $alertfilestoDownload) {
            #     $templateUri = "$modulesURLroot/$file"
            #     #(Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$file"
            #     get-blobContentFromUrl -url $templateUri | out-file "$($env:temp)/$file"
            # }
        }
    }
    # Verify you can now access the 'bicep' command.
    $packs | foreach { # should be only one pack, but just in case.
        $pack = $_
        $packName = $pack.Name
        $packTag = $pack.Tag
        $packOS = $pack.OS
        $TagsToUse=@{ # MonitorStarterPacks and instanceName are mandatory tags
            MonitorStarterPacks = $packtag
            instanceName = $instanceName
        }
        Write-Host "Creating pack for tag: $($packTag)"
        Write-Host "Pack Name: $($packName)"
        Write-Host "Pack OS: $($packOS)"
        Write-Host "Pack Location: $($location)"
        # Create the required DCRs based on configuration

        Write-host "Pack $($packName) has $($pack.Rules.Count) rules."
        $newPack = $false
        foreach ($rule in $pack.Rules) {
            $ruleName = "AMP-$instanceName-$packtag-$($rule.RuleName)"
            $ruleTag = $packTag
            $ruleOS = $pack.OS
            Write-Host "Creating rule for tag: $($ruleTag)"
            Write-Host "Rule Name: $($ruleName)"
            Write-Host "Rule OS: $($ruleOS)"
            # based on the rule type, create the required DCRs
            $dcrname=$rule.RuleNamePath #$ruleOS -eq "Windows" ? "dcr-basicWinVM.bicep" : "dcr-basicLinuxVM.bicep"
            $createDCR = $true
            $createAlerts=$true

            $dcr = Get-AzDataCollectionRule -ResourceGroupName $resourceGroup -Name $ruleName -ErrorAction SilentlyContinue
            if ($dcr) {
                Write-Host "DCR $($ruleName) already exists. Skipping creation of DCR(s)"

            }
            else {
                switch ($rule.RuleType) {
                    'syslog' {
                        Write-Host "Creating Syslog DCR $($ruleName)..."
                        # if ($urlDeployment) {
                        #     $templateUri = "$modulesURLroot/$dcrname"
                        #     Write-host "Template URI: $templateUri"
                        #     get-blobContentFromUrl -url $templateUri | out-file "$($env:temp)/$dcrname"
                        #     #(Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"
                        # }
                        # else {
                        #     $templateFile = "$modulesRoot/DCRs/$dcrname"
                        # }
                        New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                        -TemplateFile "$($env:temp)/$dcrname" `
                                                        -ResourceGroupName $resourceGroup `
                                                        -Location $location `
                                                        -rulename $ruleName `
                                                        -workspaceResourceId $WorkspaceId `
                                                        -facilityNames $rule.facilitynames `
                                                        -logLevels $rule.logLevels `
                                                        -kqlTransformation $rule.kqlTransformation `
                                                        -Tags $TagsToUse `
                                                        -tableName $rule.tableName `
                                                        -filepatterns $rule.filepatterns `
                                                        -createTable $true `
                                                        -dceId $dceId
                        Write-Host "DCR $($ruleName) created successfully."
                    }
                    'CustomData' { # this will be a tough one. 
                        # Create the Data collection DCR for the custom data
                        # Create Application in the gallery and app version
                        # assign the application to the VM in the end but that is already there, hopefully works timely and find the app version. 
                        # May need to some wait.
                        # Since we have Powershell, this will likely be easier if we use it to create the VM application instead of bicep. No need to updload and do all that. It will be quicker...hopefully.
                        # Create the DCR using the bicep template
                        Write-Host "Creating Custom DCR $($ruleName)..."
                        # if ($urlDeployment) {
                        #     $templateUri = "$modulesURLroot/$dcrname"
                        #     Write-host "Template URI: $templateUri"
                        #     #(Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"                           
                        #     get-blobContentFromUrl -url $templateUri | out-file "$($env:temp)/$dcrname"
                        # }
                        # else {
                        #     $templateFile = "$modulesRoot/DCRs/$dcrname"
                        # }
                        New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                            -TemplateFile "$($env:temp)/$dcrname" `
                            -ResourceGroupName $resourceGroup `
                            -location $location `
                            -solutionTag "MonitorStarterPacks" `
                            -workspaceResourceId $WorkspaceId `
                            -tableName $rule.tableName `
                            -packtag $packtag `
                            -filepatterns $rule.filepatterns `
                            -dceId $dceId `
                            -instanceName $instanceName `
                            -rulename $ruleName `
                            -tags $TagsToUse
                                                    
                        Write-Host "DCR $($ruleName) created successfully."                                                    
                        # Create the VM Application using Powershell instead of bicep.

                            # -Debug
                        # }
                        
                        #     New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                        #                                 -TemplateFile "$($env:temp)/$dcrname" `
                        #                                 -ResourceGroupName $resourceGroup `
                        #                                 -Location $location `
                        #                                 -rulename $ruleName `
                        #                                 -workspaceResourceId $WorkspaceId `
                        #                                 -facilityNames $rule.facilitynames `
                        #                                 -logLevels $rule.logLevels `
                        #                                 -kqlTransformation $rule.kqlTransformation `
                        #                                 -Tags $TagsToUse `
                        #                                 -dceId $dceId
                        
                    }
                    default {
                        # use bicep file to create the DCR. It will need to be available in the SA or repository
                        # test if DCR already exists
                        # Create the DCR using the bicep template
                        Write-Host "Creating DCR $($ruleName)..."
                        # if ($urlDeployment) {
                        #     $templateUri = "$modulesURLroot/$dcrname"
                        #     #(Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"
                        #     get-blobContentFromUrl -url $templateUri | out-file "$($env:temp)/$dcrname"
                        # }                        
                        # else {
                        #     $templateFile = "$modulesRoot/DCRs/$dcrname"
                        # }
                        New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                    -TemplateFile "$($env:temp)\$dcrname" `
                                                    -ResourceGroupName $resourceGroup `
                                                    -Location $location `
                                                    -rulename $ruleName `
                                                    -workspaceResourceId $WorkspaceId `
                                                    -xPathQueries $rule.XPathQueries `
                                                    -counterSpecifiers $rule.CounterSpecifiers `
                                                    -Tags $TagsToUse `
                                                    -dceId $dceId
                        Write-Host "DCR $($ruleName) created successfully."
                    }                                     
                }
            }
        }
        # Alerts
        $alerts = Search-AzGraph -Query "resources | where type =~ 'microsoft.insights/scheduledqueryrules' | where tags.instanceName =~ '$($instanceName)' and tags.MonitorStarterPacks =~ '$($packtag)'" -UseTenantScope
        if ($alerts.count -ne 0) {
            Write-Host "Alerts already exist for DCR $($ruleName). Pack is already installed. Maybe they need updates...who knows?"
            $createAlerts=$false
        }
        else {
            if ($pack.Alerts.Count -ne 0 -and $createAlerts -eq $true) {
                Write-host "Creating $($pack.Alerts.Count) alerts for pack $($packtag)..."
                # Convert to json and remove square brackets from the start and end of the string
                $alertlistT = $pack.Alerts# | ConvertTo-Json -Depth 15 -Compress #| Out-String | ForEach-Object { $_ -replace '\"', '"' }
                # $alertlist = $alertlist.TrimStart('["').TrimEnd('"]')
                $alertlist=ConvertPSObjectToHashtable $alertlistT
                $modulePrefix="AMP-$instanceName-$packtag"
                if ($urlDeployment) {
                    # $alertfilestoDownload =@('alert.bicep','alerts.bicep','scheduledqueryruleAggregate.bicep','scheduledqueryruleRows.bicep')
                    # foreach ($file in $alertfilestoDownload) {
                    #     $templateUri = "$modulesURLroot/$file"
                    #     #(Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$file"
                    #     get-blobContentFromUrl -url $templateUri | out-file "$($env:temp)/$file"
                    # }
                    New-AzResourceGroupDeployment -name "alerts-$packtag-$instanceName-$location" `
                    -TemplateFile "$($env:temp)/alerts.bicep" `
                    -ResourceGroupName $resourceGroup `
                    -Location $location `
                    -TemplateParameterObject @{
                        alertlist = $alertlist
                        AGId = $AGId
                        moduleprefix = $modulePrefix
                        packtag = $packtag
                        Tags = $TagsToUse # Add any tags you want to pass here
                        workspaceId = $workspaceId
                        location = $location
                    }
                }
                else {
                    $alertTemplateFile = "$modulesRoot/alerts/alerts.bicep"    <# Action when all if and elseif conditions are false #>
                    New-AzResourceGroupDeployment -name "alerts-$packtag-$instanceName-$location" `
                    -TemplateFile $alertTemplateFile `
                    -ResourceGroupName $resourceGroup `
                    -Location $location `
                    -TemplateParameterObject @{
                        alertlist = $alertlist
                        AGId = $AGId
                        moduleprefix = $modulePrefix
                        packtag = $packtag
                        Tags = $TagsToUse # Add any tags you want to pass here
                        workspaceId = $workspaceId
                        location = $location
                    }
                }
            }
        }
        # Create the VM application if it is a custom data rule       
        if ([string]::IsNullOrEmpty($rule.clientAppName)) {
            Write-Host "No client app name found. Skipping application creation."
        }
        else{
            # Create the VM application using the rule information if needed. It may exist already and have versions.
            create-vmapplication -rule $rule `
                                    -resourceGroup $resourceGroup `
                                    -location $location `
                                    -pack $pack `
                                    -TagsToUse $TagsToUse
            
        }
    }
    return $packs # which should be only one pack.
}
function create-vmapplication {
    param (
        [Parameter(Mandatory=$true)]
        [object]$rule,
        [Parameter(Mandatory=$true)]
        [string]$resourceGroup,
        [Parameter(Mandatory=$true)]
        [string]$location,
        [Parameter(Mandatory=$true)]
        [object]$pack,
        [Parameter(Mandatory=$true)]
        [hashtable]$TagsToUse
    )
    $applicationsURL = $env:applicationsURL
    $application=Get-AzGalleryApplication -ResourceGroupName $resourceGroup -GalleryName $env:galleryName -Name $rule.clientAppName -ErrorAction SilentlyContinue
    if ($application.count -gt 0) {
        Write-Host "Application $($rule.clientAppName) already exists. Skipping creation."
    }
    else {
        Write-host "Creating VM application $($rule.clientAppName) for $($rule.RuleName)."
        $application=New-AzGalleryApplication -ResourceGroupName $resourceGroup `
                                                -GalleryName $env:galleryName `
                                                -Name $rule.clientAppName `
                                                -Location $location `
                                                -Description $rule.description `
                                                -SupportedOSType $pack.OS `
                                                -Tag $TagsToUse
    }
    $appversion = Get-AzGalleryApplicationVersion -ResourceGroupName $resourceGroup `
        -GalleryName $env:galleryName `
        -GalleryApplicationName $rule.clientAppName  `
        -Name $rule.clientAppVersion `
        -ErrorAction SilentlyContinue
    if ($appversion) {
        Write-Host "Application version $($rule.clientAppVersion) already exists for application $($rule.clientAppName). Skipping creation."
        return $true
    }
    else {
        # Upload the application package to the storage account first
        $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $env:storageAccountName   
        $context = $storageAccount.Context
        $container = Get-AzStorageContainer -Name "applications" -Context $context
        # read the content from the repository from the URL and save it to a file in the temp folder
        Write-host "Downloading application package from $applicationsURL/$($rule.clientAppZIPFile)"
        # get a SAS token for an hour for the bob
        $sasToken = New-AzStorageBlobSASToken -Blob $rule.clientAppZIPFile `
                                            -Container $container.Name `
                                            -Context $context `
                                            -Permission r `
                                            -ExpiryTime (Get-Date).AddHours(1) `
                                            -FullUri
        if ($sasToken -eq $null) {
            Write-Error "Failed to get SAS token for the application package."
            return $false
        }
        $appversion=New-AzGalleryApplicationVersion -ResourceGroupName $resourceGroup `
            -GalleryName $env:galleryName `
            -GalleryApplicationName $application.Name `
            -Name $rule.clientAppVersion `
            -Location $location `
            -Install $rule.clientAppInstallCommand `
            -Remove $rule.clientAppUninstallCommand `
            -PackageFileLink $sasToken `
            -Tag $TagsToUse
        # wait for the application version to be created
        $appversion = Get-AzGalleryApplicationVersion -ResourceGroupName $resourceGroup `
            -GalleryName $env:galleryName `
            -GalleryApplicationName $application.Name `
            -Name $rule.clientAppVersion `
            -ErrorAction SilentlyContinue
        while ($appversion.ProvisioningState -eq "Creating") { 
            Write-Host "Waiting for application version $($rule.clientAppVersion) to be created. Current state: $($appversion.ProvisioningState)"
            Start-Sleep -Seconds 15
            $appversion = Get-AzGalleryApplicationVersion -ResourceGroupName $resourceGroup `
                -GalleryName $env:galleryName `
                -GalleryApplicationName $application.Name `
                -Name $rule.clientAppVersion `
                -ErrorAction SilentlyContinue
        }
    }
}
function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )
            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = (ConvertPSObjectToHashtable $property.Value).PSObject.BaseObject
            }
            $hash
        }
        else
        {
            $InputObject
        }
    }
}
function get-blobContentFromUrl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$url
    )
    
#having the URL need to infer container and blob name
    $uri = [System.Uri]$url
    $containerName = $uri.Segments[1].Trim('/')
    $blobName = $uri.Segments[2..($uri.Segments.Count - 1)] -join '/'
    #get the storage account name from the URL
    $storageAccountName = $uri.Host.Split('.')[0]
    # I am authorized already to access storage
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
    #get the blob content
    Get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination "$($env:temp)/$blobName" -Context $context -Force | Out-Null
    return Get-Content "$($env:temp)/$blobName"
}
function get-blobContainerContentFromUrl {
    param (
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )
    
#having the URL need to infer container and blob name
    $uri = [System.Uri]$url
    $containerName = $uri.Segments[1].Trim('/')
   
    #$blobName = $uri.Segments[2..($uri.Segments.Count - 1)] -join '/'
    #get the storage account name from the URL
    $storageAccountName = $uri.Host.Split('.')[0]
    # I am authorized already to access storage
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
    #get the blob content
        # Get a list of all blobs in the container
    $blobs = Get-AzStorageBlob -Container $containerName -Context $context
    # Loop through each blob and download it
    foreach ($blob in $blobs) {
        $blobName = $blob.Name
        # Create the destination path for the blob
        $filename = Join-Path -Path $DestinationPath -ChildPath $blobName
        # Create the directory if it doesn't exist
        # $directory = Split-Path -Path $destinationPath -Parent
        # if (-not (Test-Path -Path $directory)) {
        #     New-Item -ItemType Directory -Path $directory -Force | Out-Null
        # }
        # Download the blob to the destination path
        Get-AzStorageBlobContent -Container $containerName -Blob $blobName -Destination $filename -Context $context -Force | Out-Null
    }
    return $true
}
# function get-blobContentFromUrl2 {
#     return Get-Content "$($env:temp)/$blobName"
# }
function update-blobcontentinURL {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $true)]
        [string]$content
    )
    #having the URL need to infer container and blob name
    $uri = [System.Uri]$url
    $containerName = $uri.Segments[1].Trim('/')
    $blobName = $uri.Segments[2..($uri.Segments.Count - 1)] -join '/'
    #get the storage account name from the URL
    $storageAccountName = $uri.Host.Split('.')[0]
    # I am authorized already to access storage
    Write-host "Storage Account Name: $storageAccountName"
    $context = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
    if ($context -eq $null) {
        Write-host "Context is null. Exiting."
        return $false
    }
    #write the content to the file in the temp folder
    $content | Out-File "$($env:temp)/$blobName" -Force
    #get the blob content
    Write-host "Updating blob content in $url. Container: $containerName, Blob: $blobName"
    Set-AzStorageBlobContent -Container $containerName -Blob $blobName -Context $context -File "$($env:temp)/$blobName" -Force 
}
function get-availableIaaSPacks {
    param (
        [Parameter(Mandatory = $true)]
        [string]$packContentURL
    )
    # Get the available packs from the JSON file
    $packlist = get-blobContentFromUrl -Url $packContentURL | ConvertFrom-Json -Depth 15
    #$packlist=get-content ./packs/packsdef.json | ConvertFrom-Json -Depth 15
    $packlist.Packs.Tag | convertto-json
}
function get-packsdefinition {
# read the json from PacksURL and returns it
    $packsURL=$env:PacksURL
    $packslist=get-blobContentFromUrl -url $packsURL 
    return $packslist
}
function get-IaaSPacksContent {
    $fullpacks = get-packsdefinition | ConvertFrom-Json -Depth 15
    # return a json with packs, including Name, Tag, Number of rules, number of alerts, and the names of the alerts
    $packs = $fullpacks.Packs | Select-Object Name, Tag, 
        @{Name="NumberOfRules";Expression={$_.Rules.Count}}, 
        @{Name="NumberOfAlerts";Expression={$_.Alerts.Count}}, 
        @{Name="AlertNames";Expression={($_.Alerts | Select-Object -ExpandProperty alertRuleDisplayName) -join "`n"}} | ConvertTo-Json -Depth 15
    return $packs
}
function update-packsdefinition {
    param (
        [Parameter(Mandatory = $true)]
        [string]$packNewDefinition
    )
    # write new json to the file in the storage account
    $packsURL=$env:PacksURL
    update-blobcontentinURL -url $packsURL -content $packNewDefinition
}
function get-AmbaAlertsInfo {
    $ambaalerts=get-AMBAJsonContent | ConvertFrom-Json -Depth 10

}
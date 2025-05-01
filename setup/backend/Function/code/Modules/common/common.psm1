#######################################################################
# Common functions used in the Monitoring Packs backend functions.
#######################################################################
# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
function get-AMBAJsonFromRepo {
    param (
        [string]$AMBAJsonURL = "https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json"
    )
    $AMBAJson = Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content # | ConvertFrom-Json
    return $AMBAJson
}
function get-AMBAJsonContent {
    $StorageAccountName=$env:StorageAccountName
    $ResourceGroupName=$env:ResourceGroup
    Write-host "Storage Account: $StorageAccountName"
    Write-host "RG: $ResourceGroupName"
    $StorageAccount=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $sacontext=New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -UseConnectedAccount
    $ContainerName = "amba"
    $BlobName = "amba-alerts.json"
    $Destination = "$($env:TEMP)\$BlobName"
    $Blob2HT = @{
        Container        = $ContainerName
        Blob             = $BlobName
        Context          = $sacontext
    }
    # Check if the blob exists and is not older than 30 days
    Write-host "Checking if blob exists and is not older than 30 days..."
    $currentblob = Get-AzStorageBlob @Blob2HT #-ErrorAction SilentlyContinue
    if ($null -ne $currentblob -and $currentblob.LastModified -gt (Get-Date).AddDays(-30)) {
        Write-host "Blob found. Downloading to $Destination."
        $BlobContent = Get-AzStorageBlobContent @Blob2HT -Force -Context $sacontext -Destination $Destination
        # check if the file exists and was downloaded correctly
        if (Test-Path $Destination) {
            Write-host "Blob content downloaded successfully to $Destination file."
            $AMBAJson = get-content $Destination
        } else {
            Write-host "Blob content not downloaded. Please check the blob name and container name."
        }
    } 
    else {
        Write-Host "Blob not found. Please check the blob name and container name."
        # $AMBAJsonURL="https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json"
        # Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content 
        get-AMBAJsonFromRepo | Out-File -FilePath "amba-alerts.json" -Encoding utf8
        # Write json contetnt to a blog in the storage account under the amba container using managed identity
        $Blob1HT = @{
            File             = "amba-alerts.json"
            Container        = $ContainerName
            Blob             = $BlobName
            Context          = $sacontext
            StandardBlobTier = 'Hot'
        }
        Set-AzStorageBlobContent @Blob1HT
        $AMBAJson = get-content $BlobName
    }
    #$AMBAJson = Invoke-WebRequest -Uri $AMBAJsonURL -UseBasicParsing | Select-Object -ExpandProperty Content # | ConvertFrom-Json
    return $AMBAJson
}
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
                                          -ExtensionTypeHandlerVersion "9.0" `
                                          -InstallDependencyAgent $InstallDependencyAgent
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
                                          -InstallDependencyAgent $InstallDependencyAgent `
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
                $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
                if ($InstallDependencyAgent) {
                    $agent = New-AzConnectedMachineExtension -Name DependencyAgentLinux -ExtensionType DependencyAgentLinux -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
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
                $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent `
                                    -Publisher Microsoft.Azure.Monitor `
                                    -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
                if ($InstallDependencyAgent) {
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
                return $true
            }
            catch {
                Write-Output "Error creating association: $($_.Exception.Message)"
                return $false
            }
        } 
        else {
            Write-Output "VM: $resourceName Pack: $Pack DCR: $($DCR.Name) already associated. All good."
            return $true
        }
        Write-Output "VM: $resourceName Pack: $TagValue DCR: $($DCR.Name)"
    }
    Write-host "No DCR found for $TagValue tag. Please check the tag value."
    return $false
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
        $associationQuery
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
function Remove-Tag {
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
    [System.Object]$tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
    if ($null -eq $tag) {
        # initializes if no tag is there.
        $tag = @{}
    }
    else {
        if ($tag.Keys -notcontains $tagName) {
            # doesn´t have the monitoring tag
            "No monitoring tag, can't delete the value. Something is wrong"
        }
        else {
            #Monitoring Tag exists. Good.  
            if ($TagValue -eq 'All') { #This only applies (should) to IaaS and Discovery packs.
                # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings and vm applications.
                #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
                #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
                $taglist=$tag.$tagName.split(',')
                "Removing all associations $($taglist.count) for $taglist."
                foreach ($tagv in $taglist) {
                    Write-Host "Removing association for $tagv. on $resourceId."
                    Remove-DCRa -resourceId $resourceId -TagValue $tagv -instanceName $instanceName
                    "Removing vm application(s) if any for $tagv tag and instance name $instanceName, if any."
                    remove-vmapp -ResourceId $resourceId -packtag $tagv -instanceName $instanceName
                }
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
                        $tagToRemove = @{"$($TagName)" = "$($tag.$tagValue)" }
                        Update-AzTag -ResourceId $resourceId -Tag $tagToRemove -Operation Delete
                    }
                    else {
                        $tag[$tagName] = $tagarray -join ','
                        Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                    }
                    # Remove association for the rule with the monitoring pack. PlaceHolder. Function will need to have monitoring contributor role.
                    # Find the specific rule by the tag with ARG
                    # Find association with the monitoring pack and that resource
                    # Remove association
                    # find rule
                    if ($PackType -eq 'IaaS' -or $PackType -eq 'Discovery') {
                        "Removing DCR Association."
                        Remove-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
                        "Removing vm application(s) if any for $tagvalue tag and instance name $instanceName, if any."
                        remove-vmapp -ResourceId $resourceId -packtag $tagvalue -instanceName $instanceName
                    }
                    elseif ($TagName -ne 'Avd') {
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
                        Write-Host "Debug(Remove-Tag): removing alert rule for $resourceId"
                        Remove-PaaSAlertRules -resourceId $resourceId
                    }
                }
                #Update-AzTag -ResourceId $resource.Resource -Tag $tag
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

function Add-Tag {
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
        [Parameter(Mandatory = $false)]
        [string]$actionGroupId,
        [Parameter(Mandatory = $false)]
        [string]$workspaceResourceId,
        [Parameter(Mandatory = $false)]
        [string]$location
    )
    $resourceName = $resourceId.split('/')[8]
    Write-Host "Resource: $resourceId"
    Write-Host "Running $action for $resourceName resource. TagValue: $TagValue"
    # Action Group IP:
    Write-host "Add-tag: Action Group ID: $actionGroupId"
    $resourceGroupName = $env:resourceGroup
    #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
    $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
    #"Current tags: $($tag)"
    if ($null -eq $tag) {
        # initializes if no tag is there.
        $tag = @{}
    }
    if ($tag.Keys -notcontains $TagName) {
        # doesn´t have the monitoring tag - Adding a new tag and value
        $tag.Add($TagName, $TagValue)
        # also add the instance name tag (instanceName)
        # check if the instance name tag already exists. If not, add it.
        if ($tag.Keys -notcontains 'instanceName') {
            $tag.Add('instanceName', $instanceName)
        }
        if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
            # If this is an IaaS Pack, I now need to first call the function to install the pack if not installed.
            # Add pack if not installed. The funcion tests if DCR exists and if not creates it. Alerts are created only if the pack is not installed.
            if ($packType -eq 'IaaS') {
                #need to add check if creating the pack worked. If it didn't, don't do anything else.
                Write-host "Installing pack for $TagValue, if not installed yet."
                new-pack -location $location `
                -instanceName $instanceName `
                -resourceGroup $env:resourceGroup `
                -workspaceId $workspaceResourceId `
                -packtag $TagValue `
                -AGId $actionGroupId `
                -urlDeployment
            }
            if (Add-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName) {
                Write-host "Addinng VM application for $TagValue."
                if (New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue) {
                    Write-host "VM application created for $TagValue, if any. Adding tag."
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
            }
            else {
                "Error adding association for $TagValue. Not adding tag or adding VM application."
            }
            #Update-AzTag -ResourceId $resource.Resource -Tag $tag -Force
        }
        else { #PaaS
            try {
                new-PaaSAlert -packTag $resourceType `
                              -packType $packType `
                              -TagName $TagName `
                              -resourceId $resourceId `
                              -actionGroupId $actionGroupId `
                              -resourceGroupName $resourceGroupName `
                              -instanceName $instanceName `
                              -resourceType $resourceType `
                              -location "global"
                Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
            }
            catch {
                "Failed to create tag and alerts."
                    throw
            }
        }
    }
    else {
        #Monitoring Tag exists - Adding a new tag value
        #If the tag already exists, the instanceName should be there already...
        if ($tag.$tagName.Split(',') -notcontains $TagValue) {
            $tag[$TagName] += ",$TagValue"
            #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
                if ($packType -eq 'IaaS') {
                    new-pack -location $location `
                    -instanceName $instanceName `
                    -resourceGroup $env:resourceGroup `
                    -workspaceId $workspaceResourceId `
                    -packtag $TagValue `
                    -AGId $actionGroupId `
                    -urlDeployment
                }
                if (Add-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName) {
                    Write-host "Addinng VM application for $TagValue."
                    if (New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue) {
                        Write-host "VM application created for $TagValue, if any. Adding tag."
                        Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                    }
                }
                else {
                    "Error adding association for $TagValue. Not adding tag or adding VM application."
                }
            }
            else {
                try {
                    new-PaaSAlert -packTag $resourceType `
                                   -packType $packType `
                                   -TagName $TagName `
                                   -resourceId $resourceId `
                                   -actionGroupId $actionGroupId 
                                   -resourceGroupName `
                                   -instanceName $instanceName `
                                   -location "global"
                Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
                catch {
                    "Failed to create tag and alerts."
                        throw
                }
            }
        }
        else {
            "$TagName already has the $TagValue value."
            # if the tag is already there we hope the instance name is there as well.
            if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
                "Trying adding the DCRa anyway in case it is missing."
                Add-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            }
            # Add a test to see if the alerts actually exist
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
function new-PaaSAlert {
    param (
    [Parameter(Mandatory=$true)]
    [string]
    $packTag,
    [Parameter(Mandatory=$true)]
    [string]
    $packType,
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
    #Register-PackageSource -Name Nuget.Org -Provider NuGet -Location "https://api.nuget.org/v3/index.json"
#    $ambaURL=$env:AMBAJsonURL
    $category=$resourceType.Split('/')[0].split(".")[1]
    $subCategory=$resourceType.Split('/')[1]
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
    # $resourceName=($resourceId -split '/')[8]
    # $alerts=get-ambaAlertsForResourceType -resourceId $resourceId -serviceFolder $serviceFolder
    # if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
    # Write-Host "No visible alerts found in the file"
    # exit
    # }
    # "Total Alerts found in the file: $($alerts.count)."
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
                        "Creating StaticThresholdCriterion alert."
                        $condition=New-AzMetricAlertRuleV2Criteria -MetricName $alert.Properties.metricName `
                                                                -MetricNamespace $alert.Properties.metricNameSpace `
                                                                -Operator $alert.Properties.operator `
                                                                -Threshold $alert.Properties.threshold `
                                                                -TimeAggregation $alert.Properties.timeAggregation
                        $automaticMitigation=$null -eq $alert.Properties.autoMitigate ? $false : $alert.Properties.autoMitigate
#                         Write-host @"
#     Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
#                                                 -ResourceGroupName $resourceGroupName `
#                                                 -TargetResourceId $resourceId `
#                                                 -Description $($alert.description) `
#                                                 -Severity $($alert.Properties.severity) `
#                                                 -Frequency $([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
#                                                 -Condition $condition `
#                                                 -WindowSize $([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
#                                                 -ActionGroupId $actionGroupId `
#                                                 -AutoMitigate $automaticMitigation `
#                                                 -Debug    
# "@
                        $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
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
                                                #

                                                $tag = @{$tagName=$packtag}
                                                Update-AzTag -ResourceId $newRule.Id -Tag $tag -Operation Replace
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
                        $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
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
                        $tag = @{$tagName=$packTag}
                        "Adding tag $($tagName) with value $($packTag) to rule $($newRule.Id)."
                        Update-AzTag -ResourceId $newRule.Id -Tag $tag  -Operation Replace
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
                                -Tag @{$tagName=$packTag} `
                                -Location $location                              
        }
    }
}
function get-AmbaCatalog {
    Write-Host "Get-AmbaCatalog: Fetching AMBA Catalog from URL."
    $ambaJSONContent=get-AMBAJsonContent #-ambaJsonURL $ambaJsonURL
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
                # $ambaFolder=$namespace.Replace('microsoft.','').Replace('/','.')#                        "$namespace $ambafolder"
                    $bodyt=@"
          {
            "category" : "$category",
            "service" : "$svc",
            "namespace": "$namespace",
            "metricnamespace": "$metricnamespace",
            "tag": "$namespace"
          }
"@
                }
                else {
                    $namespace="microsoft.$($category.tolower())/$($svc.tolower())"
                    # $ambaFolder=$namespace.Replace('microsoft.','').Replace('/','.')
                    # #"$namespace $ambafolder"
                    $bodyt=@"
            {
                "category" : "$category",
              "service" : "$svc",
              "namespace": "$namespace",
              "metricnamespace": "N/A",
              "tag" : "$namespace"
            }
"@  
                }
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
                          }
                      }
                  }
              }
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
    $modulesURLroot="https://raw.githubusercontent.com/FehseCorp/AzureMonitorStarterPacks/refs/heads/V3-SubDep/modules"
    $packContentURL= "https://raw.githubusercontent.com/FehseCorp/AzureMonitorStarterPacks/refs/heads/V3-SubDep/Packs/PacksDef.json"
    $packlist = (Invoke-WebRequest -Uri $packContentURL -UseBasicParsing).content | ConvertFrom-Json -Depth 15
    $DceId=(Get-AzDataCollectionEndpoint | Where-Object {$_.Tag['instanceName'] -eq $instanceName}).Id
    #$packlist=get-content ./packs/packsdef.json | ConvertFrom-Json -Depth 15
    Write-host "Found $($packlist.Packs.Count) packs in the file. "
    Write-host "Available Tags: $($packlist.Packs | Select-Object -ExpandProperty Tag | Sort-Object -Unique)"
    $packs=$packlist.Packs | Where-Object { $_.Tag -eq $packtag }
    Write-host "Found $($packs.Count) packs for tag $($packtag)."
    if ($packs.Count -eq 0) {
        Write-Host "No packs found for tag $($packtag)."
        return $false
    }
    # install bicep
    if ($installBicep) {
        $installPath = "$env:USERPROFILE\.bicep"
        $installDir = New-Item -ItemType Directory -Path $installPath -Force
        $installDir.Attributes += 'Hidden'
        # Fetch the latest Bicep CLI binary
        (New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")
        # Add bicep to your PATH
        $currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames') | Out-Null
        if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
        if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
    }
    # Verify you can now access the 'bicep' command.
    $packs | foreach {
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
            $dcr = Get-AzDataCollectionRule -ResourceGroupName $resourceGroup -Name $ruleName -ErrorAction SilentlyContinue
            if ($dcr) {
                Write-Host "DCR $($ruleName) already exists. Skipping creation."
            }
            else {
                $newPack=$true
            }
            if ($newPack) {
                switch ($rule.RuleType) {
                    'syslog' {
                        Write-Host "Creating Syslog DCR $($ruleName)..."
                        if ($urlDeployment) {
                            $templateUri = "$modulesURLroot/DCRs/$dcrname"
                            Write-host "Template URI: $templateUri"
                            (Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"                           
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
                        }
                        else {
                            $templateFile = "$modulesRoot/DCRs/$dcrname"
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
                                                        -dceId $dceId
                        }
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
                        if ($urlDeployment) {
                            $templateUri = "$modulesURLroot/DCRs/$dcrname"
                            Write-host "Template URI: $templateUri"
                            (Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"                           
                        }
                        else {
                            $templateFile = "$modulesRoot/DCRs/$dcrname"
                        }
                        New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                    -TemplateFile "$($env:temp)/$dcrname" `
                                                    -ResourceGroupName $resourceGroup `
                                                    -Location $location `
                                                    -rulename $ruleName `
                                                    -workspaceResourceId $WorkspaceId `
                                                    #-kqlTransformation $rule.kqlTransformation `
                                                    -Tags $TagsToUse `
                                                    -tableName $rule.tableName `
                                                    -filepatterns $rule.filepatterns `
                                                    -createTable $true `
                                                    -dceId $dceId
                        Write-Host "DCR $($ruleName) created successfully."                                                    
                        # Create the VM Application using Powershell instead of bicep.
                        $application=New-AzGalleryApplication -ResourceGroupName $resourceGroup `
                            -GalleryName $env:galleryName `
                            -Name $rule.clientAppName `
                            -Location $location `
                            -Description $rule.description `
                            -SupportedOSType $pack.OS `
                            -Tag $TagsToUse

                        # Upload the application package to the storage account first
                        $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $env:storageAccountName   
                        $context = $storageAccount.Context
                        $container = Get-AzStorageContainer -Name "applications" -Context $context
                        # read the content from the repository from the URL and save it to a file in the temp folder
                        (Invoke-WebRequest -Uri $rule.clientAppZIPURL -UseBasicParsing).Content | out-file "$($env:temp)/$($rule.clientAppName.tolower()).zip"
                        # Upload the application package to the storage account
                        $blob = Set-AzStorageBlobContent -File "$($env:temp)/$($rule.clientAppName.tolower()).zip" `
                                                        -Container $container.Name `
                                                        -Blob "$($rule.clientAppName.tolower()).zip" `
                                                        -Context $context `
                                                        -Force
                        $appversion=New-AzGalleryApplicationVersion -ResourceGroupName $resourceGroup `
                            -GalleryName $env:galleryName `
                            -GalleryApplicationName $application.Name `
                            -Name $rule.clientAppVersion `
                            -Location $location `
                            -Install $rule.clientAppInstallCommand `
                            -Uninstall $rule.clientAppUninstallCommand `
                            -PackageFileLink $blob.ICloudBlob.Uri.AbsoluteUri `
                            -Tag $TagsToUse
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
                        if ($urlDeployment) {
                            $templateUri = "$modulesURLroot/DCRs/$dcrname"
                            (Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$dcrname"                           
                            New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                        -TemplateFile "$($env:temp)/$dcrname" `
                                                        -ResourceGroupName $resourceGroup `
                                                        -Location $location `
                                                        -rulename $ruleName `
                                                        -workspaceResourceId $WorkspaceId `
                                                        -xPathQueries $rule.XPathQueries `
                                                        -Tags $TagsToUse `
                                                        -dceId $dceId
                        }
                        else {
                            $templateFile = "$modulesRoot/DCRs/$dcrname"
                            New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                        -TemplateFile $templateFile `
                                                        -ResourceGroupName $resourceGroup `
                                                        -Location $location `
                                                        -rulename $ruleName `
                                                        -workspaceId $WorkspaceId `
                                                        -xPathQueries $rule.XPathQueries `
                                                        -Tags $TagsToUse `
                                                        -dceId $dceId
                        }
                        Write-Host "DCR $($ruleName) created successfully."
                    }                   
                }
            }   
        }
        # Now deploy alerts based on the pack configuration
        if ($pack.Alerts.Count -ne 0 -and $newPack -eq $true) {
            Write-host "Creating $($pack.Alerts.Count) alerts for pack $($packtag)..."
            # Convert to json and remove square brackets from the start and end of the string
            $alertlistT = $pack.Alerts# | ConvertTo-Json -Depth 15 -Compress #| Out-String | ForEach-Object { $_ -replace '\"', '"' }
            # $alertlist = $alertlist.TrimStart('["').TrimEnd('"]')
            $alertlist=ConvertPSObjectToHashtable $alertlistT
            $modulePrefix="AMP-$instanceName-$packtag"
            if ($urlDeployment) {
                $alertfilestoDownload =@('alert.bicep','alerts.bicep','scheduledqueryruleAggregate.bicep','scheduledqueryruleRows.bicep')
                foreach ($file in $alertfilestoDownload) {
                    $templateUri = "$modulesURLroot/alerts/$file"
                    (Invoke-WebRequest -Uri $templateUri).Content | out-file "$($env:temp)/$file"
                }
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
        else {
            if ($newPack -eq $false) {
                Write-Host "Pack $($packtag). already installed. Skipping alert creation."
                return $true
            }
            else {
                Write-Host "No alerts found for pack $($packtag)."
            }
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
function get-availableIaaSPacks {
    param (
        [Parameter(Mandatory = $false)]
        [string]$packContentURL
    )
    # Get the available packs from the JSON file
    $packContentURL= "https://raw.githubusercontent.com/FehseCorp/AzureMonitorStarterPacks/refs/heads/V3-SubDep/Packs/PacksDef.json"
    $packlist = (Invoke-WebRequest -Uri $packContentURL -UseBasicParsing).content | ConvertFrom-Json -Depth 15
    #$packlist=get-content ./packs/packsdef.json | ConvertFrom-Json -Depth 15
    $packlist.Packs.Tag | convertto-json
}

# function Add-Agent {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$resourceId,
#         [Parameter(Mandatory = $true)]
#         [string]$ResourceOS,
#         [Parameter(Mandatory = $true)]
#         [string]$location,
#         [boolean]$InstallDependencyAgent=$false
#     )
#     $resourceName = $resourceId.split('/')[8]
#     $resourceGroupName = $resourceId.Split('/')[4]
#     # VM Extension setup
#     $resourceSubcriptionId = $resourceId.split('/')[2]

#     "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
#     if ($ResourceOS -eq 'Linux') {
#         if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#             $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
#         }
#         else {
#             $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue 
#         }
#     }
#     else {
#         if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#             $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
#         }
#         else {
#             $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
#         }
#     }
#     if ($agentstatus) {
#         "Azure Monitor Agent already installed."
#         if ($InstallDependencyAgent) {
#             "Checking Dependency agent."
#             # Check for Linux
#             if ($ResourceOS -eq 'Linux') {
#                 if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                     $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
#                     if ($agentstatus) {
#                         "Dependency Agent already installed."
#                     }
#                     else {
#                         "Dependency Agent not installed. Installing..."
#                         install-extension -subscriptionId $resourceSubcriptionId `
#                                           -resourceGroupName $resourceGroupName `
#                                           -vmName $resourceName `
#                                           -location $location `
#                                           -ExtensionName "DependencyAgentLinux" `
#                                           -ExtensionTypeHandlerVersion "9.0" `
#                                           -InstallDependencyAgent $InstallDependencyAgent
#                     }
#                 }
#                 else {
#                     $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
#                 }
#             }
#             else {
#                 if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                     $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentWindows" -ErrorAction SilentlyContinue
#                     if ($agentstatus) {
#                         "Dependency Agent already installed."
#                     }
#                     else {
#                         "Dependency Agent not installed. Installing..."
#                         install-extension -subscriptionId $resourceSubcriptionId `
#                                           -resourceGroupName $resourceGroupName `
#                                           -vmName $resourceName `
#                                           -location $location `
#                                           -ExtensionName "DependencyAgentWindows" `
#                                           -ExtensionTypeHandlerVersion "9.0" `
#                                           -InstallDependencyAgent $InstallDependencyAgent `
#                                           -publisher "Microsoft.Azure.Monitoring.DependencyAgent"
#                     }
#                 }
#                 else {
#                     # ARC
#                     $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "DependencyAgentWindows" -ErrorAction SilentlyContinue
#                     if ($agentstatus) {
#                         "Dependency Agent already installed."
#                     }
#                     else {
#                         "Dependency Agent not installed. Installing..."
#                         $agent=New-AzConnectedMachineExtension -Name DependencyAgentWindows `
#                             -ExtensionType DependencyAgentWindows `
#                             -Publisher Microsoft.Azure.Monitoring.DependencyAgent `
#                             -ResourceGroupName $resourceGroupName `
#                             -MachineName $resourceName `
#                             -Location $location `
#                             -EnableAutomaticUpgrade -Tag $tags
#                     }
#                 }
#             }
#         }
#     }
#     else {
#         "Agent not installed. Installing..."
#         if ($ResourceOS -eq 'Linux') {
#             # 
#             if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                 # Virtual machine - add extension
#                 install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
#                     -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27" -InstallDependencyAgent $InstallDependencyAgent
#                 #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -EnableAutomaticUpgrade $true
#             }
#             else {
#                 # Arc machine -add extension
#                 Set-AzContext -SubscriptionId $resourceSubcriptionId
#                 $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
#                 $agent = New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
#                 if ($InstallDependencyAgent) {
#                     $agent = New-AzConnectedMachineExtension -Name DependencyAgentLinux -ExtensionType DependencyAgentLinux -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
#                 }
#             }
#         }
#         else {
#             # Windows
#             if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                 # Virtual machine - add extension
#                 install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName `
#                                         -vmName $resourceName -location $location `
#                                         -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2" `
#                                         -InstallDependencyAgent $installDependencyAgent
#                 #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
#             }
#             else {
#                 # Arc machine -add extension
#                 Set-AzContext -SubscriptionId $resourceSubcriptionId
#                 $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
#                 $agent = New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent `
#                                     -Publisher Microsoft.Azure.Monitor `
#                                     -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
#                 if ($InstallDependencyAgent) {
#                     $agent=New-AzConnectedMachineExtension -Name DependencyAgentWindows `
#                                                            -ExtensionType DependencyAgentWindows `
#                                                            -Publisher Microsoft.Azure.Monitoring.DependencyAgent `
#                                                            -ResourceGroupName $resourceGroupName `
#                                                            -MachineName $resourceName `
#                                                            -Location $location `
#                                                            -EnableAutomaticUpgrade -Tag $tags
#                 }
#             }
#         }
#         if ($agent) {
#             "Agent installed."
#         }
#         else {
#             "Agent not installed."
#         }
#     }
#     #End of agent installation
# }
# Depends on Function Install-azMonitorAgent
# function Add-Agent {
#     param (
#         [Parameter(Mandatory = $true)]
#         [string]$resourceId,
#         [Parameter(Mandatory = $true)]
#         [string]$ResourceOS,
#         [Parameter(Mandatory = $true)]
#         [string]$location
#     )
#     $resourceName = $resourceId.split('/')[8]
#     $resourceGroupName = $resourceId.Split('/')[4]
#     # VM Extension setup
#     $resourceSubcriptionId = $resourceId.split('/')[2]

#     "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
#     if ($ResourceOS -eq 'Linux') {
#         if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#             $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
#         }
#         else {
#             $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue 
#         }
#     }
#     else {
#         if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#             $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
#         }
#         else {
#             $agentstatus = Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
#         }
#     }
#     if ($agentstatus) {
#         "Agent already installed."
#     }
#     else {
#         "Agent not installed. Installing..."
#         if ($ResourceOS -eq 'Linux') {
#             # 
#             if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                 # Virtual machine - add extension
                
#                 install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
#                     -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27" 
#                 #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -EnableAutomaticUpgrade $true
#             }
#             else {
#                 # Arc machine -add extension
#                 Set-AzContext -SubscriptionId $resourceSubcriptionId
#                 $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
#                 $agent = New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
#             }
#         }
#         else {
#             # Windows
#             if ($resourceId.split('/')[7] -eq 'virtualMachines') {
#                 # Virtual machine - add extension
#                 install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
#                     -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
#                 #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
#             }
#             else {
#                 # Arc machine -add extension
#                 Set-AzContext -SubscriptionId $resourceSubcriptionId
#                 $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
#                 $agent = New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
#             }
#         }
#         if ($agent) {
#             "Agent installed."
#         }
#         else {
#             "Agent not installed."
#         }
#     }
#     #End of agent installation
# }
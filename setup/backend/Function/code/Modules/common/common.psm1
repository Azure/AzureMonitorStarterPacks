############################
# Tagging Functions
############################

# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
function configure-systemAssignedIdentity {
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
        Invoke-AzRestMethod -URI $URL -Method "PUT" -Payload $Body
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
        [string]$InstallDependencyAgent=$false #1.2 for windows, 1.27 for linux,
    )
    "Installing "
    "Subscription Id: $subscriptionId"
    configure-systemAssignedIdentity -subscriptionId $subscriptionId `
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

    "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
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
        "Azure Monitor Agent already installed."
        if ($InstallDependencyAgent) {
            "Checking Dependency agent."
            # Check for Linux
            if ($ResourceOS -eq 'Linux') {
                if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                    $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
                    if ($agentstatus) {
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
            "Agent installed."
        }
        else {
            "Agent not installed."
        }
    }
    #End of agent installation
}
function Add-DCRa {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagValue
    )
    $DCRs=Get-AzDataCollectionRule | Where-Object {$_.Tag["MonitorStarterPacks"] -eq $TagValue}
    foreach ($DCR in $DCRs) {
    #Check if the DCR is associated with the VM
        $associated=Get-AzDataCollectionRuleAssociation -ResourceUri $resourceId | Where-Object { $_.DataCollectionRuleId -eq $DCR.Id }
        if ($associated -eq $null) {
            Write-Output "VM: $resourceName Pack: $TagValue) DCR: $($DCR.Name) not associated"
            # Create the association
            New-AzDataCollectionRuleAssociation -ResourceUri $resourceId -DataCollectionRuleId $DCR.Id -AssociationName "Association for $resourceName and $($DCR.Name)"
        } else {
            Write-Output "VM: $resourceName Pack: $Pack DCR: $($DCR.Name) associated"
        }
        Write-Output "VM: $resourceName Pack: $TagValue DCR: $($DCR.Name)"
    }
}
function Remove-DCRa {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagValue
    )

    $DCRQuery = @"
resources
| where type == "microsoft.insights/datacollectionrules"
| extend MPs=tostring(['tags'].MonitorStarterPacks)
| where MPs=~'$TagValue'
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
        [string]$PackType
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
                # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings. 
                #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
                #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
                $taglist=$tag.$tagName.split(',')
                "Removing all associations $($taglist.count) for $taglist."
                foreach ($tagv in $taglist) {
                    "Removing association for $tagv. on $resourceId."
                    Remove-DCRa -resourceId $resourceId -TagValue $tagv
                    "Removing vm application(s) if any."
                    remove-vmapp -ResourceId $resourceId -packtag $tagv
                }
                $tag.Remove($tagName)
                if ($tag.count -ne 0) {
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
                else {
                    $tagToRemove = @{"$($TagName)" = "$($tag.$tagValue)" }
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
                        Remove-DCRa -resourceId $resourceId -TagValue $TagValue
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
function get-alertApiVersion (
    [Parameter(Mandatory = $true)]
    [string]$alertId
)
{
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
#######################################################################
# Common functions used in the Monitoring Packs backend functions.
#######################################################################

# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
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
        [string]$ExtensionTypeHandlerVersion #1.2 for windows, 1.27 for linux,
    )
    "Subscription Id: $subscriptionId"
    # Identity 
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
    # Extension
    Set-AzContext -SubscriptionId $subscriptionId
    $tags = get-azvm -Name $vmName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
    $Method = "PUT"
    $URL = "https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/extensions/$ExtensionName" + "?api-version=2023-09-01"
    $Body = @"
    {
        "properties": {
            "autoUpgradeMinorVersion": true,
            "enableAutomaticUpgrade": true,
            "publisher": "Microsoft.Azure.Monitor",
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
        Invoke-AzRestMethod -URI $URL -Method "PUT" -Payload $Body
    }
    catch {
        Write-Host "Error installing agent. $($_.Exception.Message)"
    }
}
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

    "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
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
        "Azure Monitor Agent already installed."
        if ($InstallDependencyAgent) {
            "Checking Dependency agent."
            # Check for Linux
            if ($ResourceOS -eq 'Linux') {
                if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                    $agentstatus = Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "DependencyAgentLinux" -ErrorAction SilentlyContinue
                    if ($agentstatus) {
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
                        "Dependency Agent already installed."
                    }
                    else {
                        "Dependency Agent not installed. Installing..."
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
            "Agent installed."
        }
        else {
            "Agent not installed."
        }
    }
    #End of agent installation
}
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
        [string]$location
    )
    $resourceName = $resourceId.split('/')[8]
    "Resource: $resourceId"
    "Running $action for $resourceName resource. TagValue: $TagValue"
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
        if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
            if (Add-DCRa -resourceId $resourceId -TagValue $TagValue ) {
                if (New-VMApp -instanceName $instanceName -resourceId $resourceId -packtag $TagValue) {
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
            }
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
        if (Add-DCRa -resourceId $resourceId -TagValue $TagValue ) {
            Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
        }
        else {
            "Error adding association for $TagValue. Not adding tag."
        }
    }
    else {
        #Monitoring Tag exists - Adding a new tag value
        if ($tag.$tagName.Split(',') -notcontains $TagValue) {
            $tag[$TagName] += ",$TagValue"
            #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
                if (Add-DCRa -resourceId $resourceId -TagValue $TagValue ) {
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
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
            if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
                "Trying adding the DCRa anyway in case it is missing."
                Add-DCRa -resourceId $resourceId -TagValue $TagValue #-instanceName $instanceName
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
    $ambaURL=$env:AMBAJsonURL
    $category=$resourceType.Split('/')[0].split(".")[1]
    $subCategory=$resourceType.Split('/')[1]
    "Creating New PaaS alert for $resourceId"
    $ambaAlerts=(Invoke-WebRequest -uri $ambaURL | convertfrom-json).$category.$subCategory 
    # $resourceName=($resourceId -split '/')[8]
    # $alerts=get-ambaAlertsForResourceType -resourceId $resourceId -serviceFolder $serviceFolder
    # if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
    # Write-Host "No visible alerts found in the file"
    # exit
    # }
    # "Total Alerts found in the file: $($alerts.count)."
    foreach ($alert in $ambaAlerts ) {
        if ($alert.type -eq 'metric') {
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
                    Update-AzTag -ResourceId $newRule.Id -Tag $tag  -Operation Replace
                }
                default {
                    Write-Host "Unknown criterion type"
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
    param ($ambaJsonURL)
    Write-Host "Get-AmbaCatalog: Fetching AMBA Catalog from URL: $ambaJsonURL"
          $aaa=Invoke-WebRequest -uri $ambaJsonURL | convertfrom-json -Depth 10
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
                      if ($aaa.$category.$svc.name -ne $null) {                  
                          if ($aaa.$category.$svc[0].properties.metricNamespace -ne $null) {
                            $metricnamespace=$aaa.$category.$svc[0].properties.metricNamespace.tolower()
                            $ambaFolder=$namespace.Replace('microsoft.','').Replace('/','.')#                        "$namespace $ambafolder"
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
                            $ambaFolder=$namespace.Replace('microsoft.','').Replace('/','.')
                            #"$namespace $ambafolder"
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
# Depends on Functions Add-Tag, Add-Agent, Remove-DCRa

# function get-serviceTag {
#     param (
#         [string]$namespace,
#         [PSCustomObject]$tagMappings
#     )
#     $tag=($tagMappings.tags | Where-Object { $_.nameSpace -eq $namespace }).tag
#     return $tag
# }
# function get-paasquery {
#     return  @"
#         | where tolower(type) in (
#           'microsoft.storage/storageaccounts',
#           'microsoft.desktopvirtualization/hostpools',
#           'microsoft.logic/workflows',
#           'microsoft.sql/managedinstances',
#           'microsoft.sql/servers/databases',
#           'microsoft.network/vpngateways',
#           'microsoft.network/virtualnetworkgateways',
#           'microsoft.keyvault/vaults',
#           'microsoft.network/networksecuritygroups',
#           'microsoft.network/publicipaddresses',
#           'microsoft.network/privatednszones',
#           'microsoft.network/frontdoors',
#           'microsoft.network/azurefirewalls',
#           'microsoft.network/applicationgateways'
#       )
#       or (
#           tolower(type) ==  'microsoft.cognitiveservices/accounts' and tolower(['kind']) == 'openai'
#       ) or (tolower(type) == 'microsoft.network/loadbalancers' and tolower(sku.name) !='basic')
# "@
# }

using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
function Install-azMonitorAgent {
    param (
    [Parameter(Mandatory=$true)]
    $subscriptionId, 
    [Parameter(Mandatory=$true)]
        $resourceGroupName,
        [Parameter(Mandatory=$true)]
        $vmName, 
        [Parameter(Mandatory=$true)]
        $location,
        [Parameter(Mandatory=$true)]
        [string]$ExtensionName, #  AzureMonitorWindowsAgent or AzureMonitorLinuxAgent
        [Parameter(Mandatory=$true)]
        [string]$ExtensionTypeHandlerVersion #1.2 for windows, 1.27 for linux
    )
    # Identity 
    $URL="https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName"+"?api-version=2018-06-01"
    $Method="PATCH"
    $Body=@"
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
    $tags=get-azvm -Name $vmName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
    $Method="PUT"
    $URL="https://management.azure.com/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/virtualMachines/$vmName/extensions/$ExtensionName"+"?api-version=2023-09-01"
    $Body=@"
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
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
"Resources"
$resources
$action = $Request.Body.Action

if ($resources) {
    "Working on $($resources.count) resource(s). Action: $action. Altering AMA configuration."
    switch ($action) {
        'AddAgent' {
            foreach ($resource in $resources) {
                $resourceName=$resource.id.split('/')[8]
                $resourceSubcriptionId=$resource.id.split('/')[2]
                "Running $action for $resourceName resource."
                #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                if ($resource.OS -eq 'Linux') {
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
                }
                else {
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
                }
                if ($agentstatus) {
                    "Agent already installed."
                }
                else {
                    "Agent not installed. Installing..."
                    if ($resource.OS -eq 'Linux') { # 
                        if ($resource.id.split('/')[7] -eq 'virtualMachines') {
                            # Virtual machine - add extension
                            install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resource.'Resource Group' -vmName $resourceName -location $resource.location `
                            -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27"
                            #$agent=Set-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.location -EnableAutomaticUpgrade $true
                        }
                        else {
                            # Arc machine -add extension
                            Set-AzContext -SubscriptionId $subscriptionId
                            $tags=get-azvm -Name $resourceName -ResourceGroupName $resource.resourceGroup | Select-Object -ExpandProperty tags | ConvertTo-Json
                            $agent= New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resource.'Resource Group' -MachineName $resourceName -Location $resource.location -EnableAutomaticUpgrade -Tag $tags
                        }
                    }
                    else { # Windows
                        if ($resource.id.split('/')[7] -eq 'virtualMachines') {
                            # Virtual machine - add extension
                            install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resource.'Resource Group' -vmName $resourceName -location $resource.location `
                            -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
                            #$agent=Set-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
                        }
                        else {
                            # Arc machine -add extension
                            Set-AzContext -SubscriptionId $subscriptionId
                            $tags=get-azvm -Name $resourceName -ResourceGroupName $resource.resourceGroup | Select-Object -ExpandProperty tags | ConvertTo-Json
                            $agent=New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resource.'Resource Group' -MachineName $resourceName -Location $resource.location -EnableAutomaticUpgrade -Tag $tags
                        }
                    }
                    if ($agent) {
                        "Agent installed."
                    }
                    else {
                        "Agent not installed."
                    }
                }
                #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            }
        }
        'RemoveAgent' {
            foreach ($resource in $resources) {
                $resourceName=$resource.id.split('/')[8]
                $resourceSubcriptionId=$resource.id.split('/')[2]
                "Running $action for $resourceName resource."
                #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                if ($resource.OS -eq 'Linux') {
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
                }
                else {
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
                }
                if (!$agentstatus) {
                    "Agent not installed."
                }
                else {
                    "Agent installed. Removing..."
                    if ($resource.OS -eq 'Linux') { # 
                        if ($resource.id.split('/')[7] -eq 'virtualMachines') {
                            # Virtual machine - remove extension
                            Remove-AzVMExtension -Name AzureMonitorLinuxAgent -ResourceGroupName $resource.'Resource Group'  -VMName $resourceName -Force
                            # install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resource.'Resource Group' -vmName $resourceName -location $resource.location `
                            # -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27"
                            # #$agent=Set-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.location -EnableAutomaticUpgrade $true
                        }
                        else {
                            # Arc machine - remove extension
                            Set-AzContext -SubscriptionId $subscriptionId
                            Remove-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ResourceGroupName $resource.'Resource Group' -MachineName $resourceName
                        }
                    }
                    else { # Windows
                        if ($resource.id.split('/')[7] -eq 'virtualMachines') {
                            # Virtual machine - remove extension
                            Remove-AzVMExtension -Name AzureMonitorWindowsAgent -ResourceGroupName $resource.'Resource Group'  -VMName $resourceName -Force
                            # install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resource.'Resource Group' -vmName $resourceName -location $resource.location `
                            # -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
                            # #$agent=Set-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
                        }
                        else {
                            # Arc machine - remove extension
                            Set-AzContext -SubscriptionId $subscriptionId
                            Remove-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ResourceGroupName $resource.'Resource Group' -MachineName $resourceName
                        }
                    }
                }
                #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }
}
else
{
    "No resources provided."
}
$body = "This HTTP triggered function executed successfully. $($resources.count) were altered ($action)."
#Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

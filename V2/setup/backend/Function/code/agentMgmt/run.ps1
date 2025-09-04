
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
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
                Set-AzContext -subscriptionId $resourceSubcriptionId
                #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                if ($resource.OS -eq 'Linux') {
                    "Looking for the Linux agent on $resourceName and $($resource.'Resource Group') RG."
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
                }
                else {
                    "Looking for the Windows agent on $resourceName and $($resource.'Resource Group') RG."
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
                }
                #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            }
        }
        'RemoveAgent' {
            foreach ($resource in $resources) {
                $resourceName=$resource.id.split('/')[8]
                $resourceSubcriptionId=$resource.id.split('/')[2]
                "Running $action for $resourceName resource."
                Set-AzContext -subscriptionId $resourceSubcriptionId
                #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                if ($resource.OS -eq 'Linux') {
                                        "Looking for the Linux agent on $resourceName and $($resource.'Resource Group') RG."
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
                }
                else {
                                        "Looking for the Windows agent on $resourceName and $($resource.'Resource Group') RG."
                    $agentstatus=Get-AzVMExtension -ResourceGroupName $resource.'Resource Group' -VMName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
                }
                "Agent Status: $agentstatus"
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

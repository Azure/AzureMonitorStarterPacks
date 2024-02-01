
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
$Request=@"
{
    "Body": {
        "Action": "AddTag",
        "Resources": [
          {
            "Resource": "/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/AMonStarterPacks/providers/Microsoft.HybridCompute/machines/WIN-012O0PRF1EN",
            "Resource Group": "amonstarterpacks",
            "OS": "windows",
            "Location": "eastus",
            "Subscription": "JF-AIRS-Internal"
          }
        ],
        "Pack": "VMI"
      }
    }
"@ | ConvertFrom-Json
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
        [string]$ExtensionTypeHandlerVersion #1.2 for windows, 1.27 for linux,
    )
    "Subscription Id: $subscriptionId"
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
function Config-AVD {
    param (
        [Parameter(Mandatory=$true)]
        [string]$hostpoolResource,
        [Parameter(Mandatory=$true)]
        [string]$AVDResourceGroup
    )

    # Do your thing!
}
function Add-Tag {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resource,
        [Parameter(Mandatory=$true)]
        [string]$TagName,
        [Parameter(Mandatory=$true)]
        [string]$TagValue
    )
    $resourceName=$resource.split('/')[8]
    "Resource: $resource"
    "Running $action for $resourceName resource. TagValue: $TagValue"
    #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
    $tag=(get-aztag -ResourceId $resource).Properties.TagsProperty
    #"Current tags: $($tag)"
    if ($null -eq $tag) { # initializes if no tag is there.
        $tag = @{}
    }
    if ($tag.Keys -notcontains $TagName) { # doesn´t have the monitoring tag
        $tag.Add($TagName, $TagValue)
        Update-AzTag -ResourceId $resource -Tag $tag -Operation Replace
        #Check if agent exists. If not, install it.
    }
    else { #Monitoring Tag exists  
        if ($tag.$tagName.Split(',') -notcontains $TagValue) {
            $tag[$TagName] += ",$TagValue"
            #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            Update-AzTag -ResourceId $resource -Tag $tag -Operation Replace
        }
        else {
            "$TagName already has the $TagValue value"
        }
    }
}
function Add-Agent {
    param (
        [Parameter(Mandatory=$true)]
        [string]$resource,
        [Parameter(Mandatory=$true)]
        [string]$ResourceOS
    )
    $resourceName=$resource.split('/')[8]
    $resourceGroupName=$resource.Split('/')[4]
    # VM Extension setup
    $resourceSubcriptionId=$resource.split('/')[2]

    "Adding agent to $resourceName in $resourceGroupName RG in $resourceSubcriptionId sub. Checking if it's already installed..."
    if ($ResourceOS -eq 'Linux') {
        if ($resource.split('/')[7] -eq 'virtualMachines') {
            $agentstatus=Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue
        }
        else {
           $agentstatus=Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorLinuxAgent" -ErrorAction SilentlyContinue 
        }
    }
    else {
        if ($resource.split('/')[7] -eq 'virtualMachines') {
            $agentstatus=Get-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
        }
        else {
            $agentstatus=Get-AzConnectedMachineExtension -ResourceGroupName $resourceGroupName -MachineName $resourceName -Name "AzureMonitorWindowsAgent" -ErrorAction SilentlyContinue
        }
    }
    if ($agentstatus) {
        "Agent already installed."
    }
    else {
        "Agent not installed. Installing..."
        if ($ResourceOS -eq 'Linux') { # 
            if ($resource.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $resource.Location `
                -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27" 
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tags=get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName| Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent= New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $resource.Location -EnableAutomaticUpgrade -Tag $tags
            }
        }
        else { # Windows
            if ($resource.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $resource.Location `
                -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tags=get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent=New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $resource.Location -EnableAutomaticUpgrade -Tag $tags
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
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
$TagList = $Request.Body.Pack.split(',')
$PackType = $Request.Body.PackType

if ($resources) {
        #$TagName='MonitorStarterPacks'
    $TagName=$env:SolutionTag
    if ([string]::isnullorempty($TagName)) {
        $TagName='MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    # Add the option for multiple tags, comma separated
    "Working on $($resources.count) resource(s). Action: $action. Altering $TagName in the resource."
    switch ($action) {
        'AddTag' {
            foreach ($TagValue in $TagList) {
                foreach ($resource in $resources) {
                    # Tagging
                    Add-Tag -resource $resource.Resource -TagName $TagName -TagValue $TagValue
                    # Add Agent
                    if ($TagValue -eq 'VMI') {
                        Add-Agent -resource $resource.Resource -ResourceOS $resource.OS
                    }
                    # Add Tag Based condition.
                    if ($TagValue -eq 'AVD') {
                        # Create AVD alerts function.
                        $AVDRG=$Request.Body.AVDResourceGroup ? $Request.Body.AVDResourceGroup : $resource.'Resource Group'
                        Config-AVD -hostpoolResource $resource.Resource -AVDResourceGroup $AVDRG
                    }
                } # End of resource loop
            }
        }
        'RemoveTag' {
            foreach ($TagValue in $TagList) {
                foreach ($resource in $resources) {
                    "Running $action for $($resource.Resource) resource. TagValue: $TagValue"
                    #[System.Object]$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                    [System.Object]$tag=(get-aztag -ResourceId $resource.Resource).Properties.TagsProperty
                    if ($null -eq $tag) { # initializes if no tag is there.
                        $tag = @{}
                    }
                    else {
                        if ($tag.Keys -notcontains $tagName) { # doesn´t have the monitoring tag
                            "No monitoring tag, can't delete the value. Something is wrong"
                        }
                        else { #Monitoring Tag exists. Good.  
                            if ($TagValue -eq 'All') { # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings. 
                                #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
                                #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                                $tag=(get-aztag -ResourceId $resource.Resource).Properties.TagsProperty
                                $tag.Remove($tagName)
                                if ($tag.count -ne 0) {
                                    Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                                }
                                else {
                                    $tagToRemove=@{"$($TagName)"="$($tag.$tagValue)"}
                                    Update-AzTag -ResourceId $resource.Resource -Tag $tagToRemove -Operation Delete
                                }
                            }
                            else {
                                if ($tag.$tagName.Split(',') -notcontains $TagValue) {
                                    "Tag exists, but not the value. Can't remove it. Something is wrong."
                                }
                                else {
                                    [System.Collections.ArrayList]$tagarray=$tag[$tagName].split(',')
                                    $tagarray.Remove($TagValue)
                                    if ($tagarray.Count -eq 0) {
                                        "Removing tag since it has no values."
                                        $tag.Remove($tagName)
                                        $tagToRemove=@{"$($TagName)"="$($tag.$tagValue)"}
                                        Update-AzTag -ResourceId $resource.Resource -Tag $tagToRemove -Operation Delete
                                    }
                                    else {
                                        $tag[$tagName]=$tagarray -join ','
                                        Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                                    }
                                    if ($PackType -eq 'IaaS') {
                                        # Remove association for the rule with the monitoring pack. PlaceHolder. Function will need to have monitoring contributor role.
                                        # Find the specific rule by the tag with ARG
                                        # Find association with the monitoring pack and that resource
                                        # Remove association
                                        # find rule
                                        $DCRQuery=@"
resources
| where type == "microsoft.insights/datacollectionrules"
| extend MPs=tostring(['tags'].MonitorStarterPacks)
| where MPs=~'$TagValue'
| summarize by name, id
"@
                                        $DCR=Search-AzGraph -Query $DCRQuery
                                        "Found rule $($DCR.name)."
                                        "DCR id : $($DCR.id)"
                                        "resource: $($resource.Resource)"
                                        $associationQuery=@"
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0], ruleId=properties.dataCollectionRuleId
| where isnotnull(properties.dataCollectionRuleId)
| where resourceId =~ '$($resource.Resource)' and
ruleId =~ '$($DCR.id)'
"@
                                        $associationQuery
                                        $association=Search-AzGraph -Query $associationQuery
                                        "Found association $($association.name). Removing..."
                                        if ($association.count -gt 0) {
                                            Remove-AzDataCollectionRuleAssociation -TargetResourceId $resource.Resource -AssociationName $association.name
                                        }
                                        else {
                                            "No association Found."
                                        }
                                    }
                                    else {
                                        "Paas Pack. No need to remove association."
                                        $diagnosticConfig=Get-AzDiagnosticSetting -ResourceId $resource.Resource -Name "AMSP-$TagValue"
                                        if ($diagnosticConfig) {
                                            "Found diagnostic setting. Removing..."
                                            Remove-AzDiagnosticSetting -ResourceId $resource.Resource -Name "AMSP-$TagValue"
                                        }
                                        else {
                                            "No diagnostic setting found."
                                        }
                                    }
                                }
                            #Update-AzTag -ResourceId $resource.Resource -Tag $tag
                            }
                        }
                    }
                }
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

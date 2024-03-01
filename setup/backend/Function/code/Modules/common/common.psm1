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

# Depends on Function Install-azMonitorAgent
function Add-Agent {
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
        "Agent already installed."
    }
    else {
        "Agent not installed. Installing..."
        if ($ResourceOS -eq 'Linux') {
            # 
            if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
                    -ExtensionName "AzureMonitorLinuxAgent" -ExtensionTypeHandlerVersion "1.27" 
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorLinuxAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorLinuxAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorLinuxAgent -ExtensionType AzureMonitorLinuxAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
            }
        }
        else {
            # Windows
            if ($resourceId.split('/')[7] -eq 'virtualMachines') {
                # Virtual machine - add extension
                install-azmonitorAgent -subscriptionId $resourceSubcriptionId -resourceGroupName $resourceGroupName -vmName $resourceName -location $location `
                    -ExtensionName "AzureMonitorWindowsAgent" -ExtensionTypeHandlerVersion "1.2"
                #$agent=Set-AzVMExtension -ResourceGroupName $resourceGroupName -vmName $resourceName -Name "AzureMonitorWindowsAgent" -Publisher "Microsoft.Azure.Monitor" -ExtensionType "AzureMonitorWindowsAgent" -TypeHandlerVersion "1.0" -Location $resource.Location -ForceRerun -ForceUpdateTag -EnableAutomaticUpgrade $true
            }
            else {
                # Arc machine -add extension
                Set-AzContext -SubscriptionId $resourceSubcriptionId
                $tags = get-azvm -Name $resourceName -ResourceGroupName $resourceGroupName | Select-Object -ExpandProperty tags | ConvertTo-Json
                $agent = New-AzConnectedMachineExtension -Name AzureMonitorWindowsAgent -ExtensionType AzureMonitorWindowsAgent -Publisher Microsoft.Azure.Monitor -ResourceGroupName $resourceGroupName-MachineName $resourceName -Location $location -EnableAutomaticUpgrade -Tag $tags
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
        [Parameter(Mandatory = $false)]
        [string]$actionGroupId
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
            if (New-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName) {
                Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
            }
        }
        else {
            new-PaaSAlert -packTag $TagValue -packType $packType -TagName $TagName -resourceId $resourceId -actionGroupId $actionGroupId -resourceGroupName $resourceGroupName `
                -serviceFolder (get-AmbaPackFolder $TagValue) -instanceName $instanceName
            Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
        }
        if (New-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName) {
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
                if (New-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName) {
                    Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
                }
            }
            else {
                new-PaaSAlert -packTag $TagValue -packType $packType -TagName $TagName -resourceId $resourceId -actionGroupId $actionGroupId -resourceGroupName `
                -serviceFolder (get-AmbaPackFolder $TagValue) -instanceName $instanceName
                Update-AzTag -ResourceId $resourceId -Tag $tag -Operation Replace
            }
        }
        else {
            "$TagName already has the $TagValue value."
            if ($packType -eq 'IaaS' -or $packType -eq 'Discovery') {
                "Trying adding the DCRa anyway in case it is missing."
                New-DCRa -resourceId $resourceId -TagValue $TagValue -instanceName $instanceName
            }
            # Add a test to see if the alerts actually exist

        }
    }
}
function get-AmbaPackFolder {
    param (
        [Parameter(Mandatory = $true)]
        [string]$packName
    )
    $packName = $packName.ToLower()
    # Hashatable with packname and folder in the amba repo
    $packs = @{
        "KeyVault" = "KeyVault.vaults"
        "LogicApps" = "Logic.workflows"
        "ServiceBus" = "ServiceBus.namespaces"
        "Storage" = "Storage.storageAccounts"
        "WebApps" = "Web.sites"
        "SQL"= "Sql.servers"
        "SQLMI" = "Sql.managedInstances"
        "WebServer"= "Web.serverFarms"
        "AppGW"='Network.applicationGateways'
        "AzFW"='Network.azureFirewalls'
        'PrivZones'='Network.PrivateDnsZones'
        'PIP'= 'Network.publicIPAddresses'
        'UDR'='Network.routeTables'
        'AA'='Automation.automationAccounts'
        'NSG'='Network.networkSecurityGroups'
        'AzFD'= 'Network.frontodoors'
        'ALB'= 'Network.loadBalancers'
        'Bastion' = 'Network.bastionHosts'
        'VPNG'= 'Network.vpnGateways'
        'VnetGW'= 'Network.virtualNetworkGateways'
        'VNET'= 'Network.virtualNetworks'
    }
    if ($packs.ContainsKey($packName)) {
        return $packs[$packName]
    }
    else {
        return $null
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
    [string]$serviceFolder,
    [Parameter(Mandatory=$true)]
    [string]$instanceName
)
    #Register-PackageSource -Name Nuget.Org -Provider NuGet -Location "https://api.nuget.org/v3/index.json"
    $ambaJsonURL='https://azure.github.io/azure-monitor-baseline-alerts/amba-alerts.json'
    $ambaAlerts=Invoke-WebRequest -Uri $ambaJsonURL | Select-Object -ExpandProperty Content | Out-String | convertfrom-json
    
    $resourceName=($resourceId -split '/')[8]
    # $servicesBaseURL= 'https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/services'# $env:servicesBaseURL
    # $alertfile='/alerts.yaml'
    # $alertsFileURL="$servicesBaseURL$serviceFolder$alertfile"
    # "URL:"
    # $alertsFileURL
    # # $resourceGroupName='rg-Monstarpacks'
    # $location='global'
    # $alertsFile=Invoke-WebRequest -Uri $alertsFileURL | Select-Object -ExpandProperty Content | Out-String
    # # "Alerts File:"
    # # $alertsFile
    # $alertst=ConvertFrom-Yaml $alertsFile
    # # "Alertst:"
    # # $alertst
    # # "Before trying to create alerts, just converto-yaml json whatever..."
    # # ConvertTo-Yaml -JsonCompatible $alertst
    # $alerts=ConvertTo-Yaml -JsonCompatible $alertst | ConvertFrom-Json
    $alerts=$ambaAlerts.$($serviceFolder.split('.')[0]).$($serviceFolder.split('.')[1])
    if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
    Write-Host "No visible alerts found in the file"
    exit
    }
    "Total Alerts found in the file: $($alerts.count)."
    foreach ($alert in ($alerts | Where-Object {$_.visible -eq $true}) ) {
        if ($alert.type -eq 'metric') {
            $alertType=$alert.Properties.criterionType
            switch ($alertType) {
                'StaticThresholdCriterion' {
                    $condition=New-AzMetricAlertRuleV2Criteria -MetricName $alert.Properties.metricName `
                                                            -MetricNamespace $alert.Properties.metricNameSpace `
                                                            -Operator $alert.Properties.operator `
                                                            -Threshold $alert.Properties.threshold `
                                                            -TimeAggregation $alert.Properties.timeAggregation
                    $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
                                            -ResourceGroupName $resourceGroupName `
                                            -TargetResourceId $resourceId `
                                            -Description $alert.description `
                                            -Severity $alert.Properties.severity `
                                            -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                            -Condition $condition `
                                            -AutoMitigate $alert.Properties.autoMitigate `
                                            -WindowSize ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
                                            -ActionGroupId $actionGroupId `
                                            -Verbose
                                            $tag = @{$tagName=$packtag}
                                            Update-AzTag -ResourceId $newRule.Id -Tag $tag -Operation Replace
                }
                'DynamicThresholdCriterion' {
                    $condition=New-AzMetricAlertRuleV2Criteria  -MetricName $alert.Properties.metricName `
                                                                -MetricNamespace $alert.Properties.metricNameSpace `
                                                                -Operator $alert.Properties.operator `
                                                                -DynamicThreshold `
                                                                -TimeAggregation $alert.Properties.timeAggregation `
                                                                -ViolationCount $alert.properties.failingPeriods.minFailingPeriodsToAlert `
                                                                -ThresholdSensitivity $alert.Properties.alertSensitivity 
                    $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
                                                    -ResourceGroupName $resourceGroupName `
                                                    -TargetResourceId $resourceId `
                                                    -Description $alert.description `
                                                    -Severity $alert.Properties.severity `
                                                    -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                                    -Condition $condition `
                                                    -AutoMitigate $alert.Properties.autoMitigate `
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
    $DCRlist = Search-AzGraph -Query $DCRQuery
    "Found $($DCRlist.count) rule(s) with $TagValue pack."
    # "DCR id : $($DCR.id)"
    "resource: $resourceId"
    foreach ($DCR in $DCRlist) {
        $associationQuery = @"
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0], ruleId=properties.dataCollectionRuleId
| where isnotnull(properties.dataCollectionRuleId)
| where resourceId =~ '$resourceId' and
ruleId =~ '$($DCR.id)'
"@
        $associationQuery
        $association = Search-AzGraph -Query $associationQuery
        "Found association $($association.name). Removing..."
        if ($association.count -gt 0) {
            Remove-AzDataCollectionRuleAssociation -TargetResourceId $resourceId -AssociationName $association.name
        }
        else {
            "No association Found."
        }
    }
}
function New-DCRa {
    param (
        [Parameter(Mandatory = $true)]
        [string]$resourceId,
        [Parameter(Mandatory = $true)]
        [string]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$instanceName
    )
    $resourceName=$resourceId.split('/')[8]
    $DCRQuery = @"
resources
| where type == "microsoft.insights/datacollectionrules"
| extend MPs=tostring(['tags'].MonitorStarterPacks)
| where MPs=~'$TagValue'
| summarize by name, id
"@
    $DCR = Search-AzGraph -Query $DCRQuery
    if ($DCR -ne $null) {
        "Found rule $($DCR.name)."
        "DCR id : $($DCR.id)"
        "resource: $resourceId"
        $associationQuery = @"
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0], ruleId=properties.dataCollectionRuleId
| where isnotnull(properties.dataCollectionRuleId)
| where resourceId =~ '$resourceId' and
ruleId =~ '$($DCR.id)'
"@
        $associationQuery
        $association = Search-AzGraph -Query $associationQuery
        if ($association.count -eq 0) {
            "No association Found. Adding..."
            # Remove-AzDataCollectionRuleAssociation -TargetResourceId $resourceId -AssociationName $association.name
            # try {
                foreach ($DCRrule in $DCR) {
                    $associationName="$($DCRrule.name)-$resourceName"
                    New-AzDataCollectionRuleAssociation -AssociationName $associationName -Description "associating $TagValue pack with resource $resourceName" -TargetResourceId $resourceId -RuleId $DCRrule.id # -TargetResourceId $resourceId -DataCollectionRuleId $DCR.id
                }
                return "Association(s) added for $TagValue."
            # }
            # catch {
            #     "Error adding association for $TagValue."
            #     return $null
            # }
        }
        else {
            return "Found association $($association.name). No need to add..."
        }   
    }
    else {
        "No rule found for $TagValue"
        return $null
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
            if ($TagValue -eq 'All') {
                # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings. 
                #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
                #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                $tag = (get-aztag -ResourceId $resourceId).Properties.TagsProperty
                $taglist=$tag.$tagName.split(',')
                "Removing all associations for $taglist."
                foreach ($tagv in $taglist) {
                    "Removing association for $tagv. on $resourceId."
                    Remove-DCRa -resourceId $resourceId -TagValue $tagv
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
                    }
                }
                #Update-AzTag -ResourceId $resource.Resource -Tag $tag
            }
        }
    }
}
# Depends on Functions Add-Tag, Add-Agent, Remove-DCRa
function Config-AVD {
    param (
        [Parameter(Mandatory = $true)]
        [string]$action,
        [Parameter(Mandatory = $true)]
        [string]$hostPoolName,
        [Parameter(Mandatory = $true)]
        [string]$resourceGroupName,
        [Parameter(Mandatory = $true)]
        [string]$location,
        [Parameter(Mandatory = $true)]
        [string]$TagName,
        [Parameter(Mandatory = $true)]
        [object]$TagValue,
        [Parameter(Mandatory = $true)]
        [string]$LogAnalyticsWSAVD
    )
    $hostPoolName = $hostPoolName.ToLower()  # ensures case sensitivity with search
    $LogAnalyticsWS = $Request.Body.AltLAW

    # Graph Query to map host pool resources (App Group, Workspace, VMs, etc)
    "AVD - Perform an Azure Graph Query to map Host Pool's App Group, Workspace and VM resources and status. ($hostPoolName)"
    $MapResourcesQuery = @"
resources
| where type =~ 'microsoft.desktopvirtualization/hostpools'
| where name =~ '$hostPoolName'
| extend hostPool = tolower(name)
| extend hostPoolId = id
| join kind= leftouter (
    desktopvirtualizationresources
    | where type =~ 'microsoft.desktopvirtualization/hostpools/sessionhosts'
    | extend hostPool = tolower(tostring(split(name, '/')[0]))
    | extend sessionHostName = split(split(name, '/')[1], '.')[0]
    | project hostPool, tostring(sessionHostName)
    ) on hostPool
| join kind=leftouter (
    resources
    | where type =~ 'microsoft.desktopvirtualization/applicationgroups'
    | extend appGroupName = tolower(name), hostPool = tolower(tostring(split(properties.hostPoolArmPath, '/')[8]))
    | extend appGroupId = id
    | project appGroupName, hostPool, appGroupId
) on hostPool
| join kind=leftouter (
    resources
    | where type =~ 'microsoft.desktopvirtualization/workspaces'
    | mv-expand appGroup = properties.applicationGroupReferences
    | parse kind=regex appGroup with '/applicationGroups/' appGroupName
    | extend appGroupName = tolower(tostring(split(appGroup, '/')[8]))
    | extend appGroup = tolower(tostring(appGroup))
    | extend workspaceId = id
    | project workspace = name, appGroupName, appGroup, workspaceId
) on appGroupName
| project-away hostPool1, appGroup, appGroupName1, hostPool2
"@

    $VMQuery = @"
resources
| where type =~ 'microsoft.compute/virtualmachines'
| where name =~ 'CURRENTVM'
| extend VmName = name
| extend VmRG = resourceGroup, VMResId = id
| extend VMsubId = split(id, '/')[2]
| extend VmOS = properties.storageProfile.imageReference.publisher
| extend VmStatus = properties.extended.instanceView.powerState.displayStatus
| project VmName, VmRG, VMResId, VMsubId, VmOS, VmStatus, location
"@

    $AVDResources = Search-AzGraph -Query $MapResourcesQuery
    $Tag = @{$TagName = $TagValue }
    # Set Tagging on related resources (Host Pool already tagged inside main)
    #    Get current tags and append the new tag(s)
    If ($action -eq 'AddTag') {
        "AVD - Adding tags to resources associated with the Host Pool: $hostPoolName"
        Add-Tag -resourceId $AVDResources[0].id -TagName $TagName -TagValue $TagValue
        If ($AVDResources[0].workspaceId -ne '') { Add-Tag -resourceId $AVDResources[0].workspaceId -TagName $TagName -TagValue $TagValue }
        If ($AVDResources[0].appGroupId -ne '') { Add-Tag -resourceId $AVDResources[0].appGroupId -TagName $TagName -TagValue $TagValue }
    }
    If ($action -eq 'RemoveTag') {
        $diagnosticConfig = Get-AzDiagnosticSetting -ResourceId $AVDResources[0].id -Name "AMSP-$TagValue"
        if ($diagnosticConfig) {
            "AVD - Found Host Pool diagnostic setting AMSP-$TagValue. Removing..."
            Remove-AzDiagnosticSetting -ResourceId $AVDResources[0].id -Name "AMSP-$TagValue"
        }
        else {
            "AVD - No Host Pool diagnostic setting AMSP-$TagValue found."
        }
    }
    foreach ($vm in $AVDResources) {
        $currVMQuery = $VMQuery -replace 'CURRENTVM', $vm.sessionHostName
        $vmInfo = Search-AzGraph -Query $currVMQuery
        $vmName = $vmInfo.VmName
        If ($action -eq 'AddTag') {
            "AVD - Adding Tag to VM ($vmName)"
            Add-Tag -resourceId $vmInfo.VMResId -TagName $TagName -TagValue $TagValue
            If ($vmInfo.VmStatus -eq 'VM Running') {
                "AVD - Installing AMA agent on VM ($vmName)"
                Add-Agent -resourceId $vmInfo.VMResId -ResourceOS $vmInfo.VmOS -location $vmInfo.location
            }
            else { "AVD - AMA Agent NOT installed (VM $vmName Not Running!)" }
        }
        If ($action -eq 'RemoveTag') {
            "AVD - Removing Tag from VM ($vmName)"
            Update-AzTag -ResourceId $AVDResources[0].id -Tag $Tag -Operation Delete
            # Update DCR for each VM
            Remove-DCRa -resourceId $vmInfo.VMResId -TagValue $TagValue
        }
    }
    # Create Host Pool Specific Alerts
    "AVD - Getting Alerts from Repo and Creating Host Pool Specific Alerts for $hostPoolName"
    $AlertListSchedQueryJson = $RepoUrl + "Packs/PaaS/AVD/LogAlertsHostPool.json"
    $AlertListSchedQuery = Invoke-RestMethod -Uri $AlertListSchedQueryJson
    
    foreach ($alert in $AlertListSchedQuery) {
        [pscustomobject]$criteriaAllof = @{
            query           = $alert.query -replace 'xHostPoolNamex', $hostPoolName
            timeAggregation = "Count"
            dimensions      = $alert.dimensions
            operator        = "GreaterThanOrEqual"
            threshold       = 1
        }
        $evaluationFreq = [System.Xml.XmlConvert]::ToTimeSpan($alert.evaluationFrequency)
        $windowSize = [System.Xml.XmlConvert]::ToTimeSpan($alert.windowSize)
        $alertName = $alert.alertRuleName -replace 'xHostPoolNamex', $hostPoolName
        $alertDescription = $alert.alertRuleDescription -replace 'xHostPoolNamex', $hostPoolName
        $alertDisplayName = $alert.alertRuleDisplayName -replace 'xHostPoolNamex', $hostPoolName
        $alertSeverity = $alert.alertRuleSeverity
        If ($action -eq 'AddTag') {
            "AVD - Creating Query Alert: $alertName"
            if ($alert.autoMitigate -eq "True") {
                $AlertCreate = New-AzScheduledQueryRule -Name $alertName -ResourceGroupName $resourceGroupName -Location $location -DisplayName $alertDisplayName -Description $alertDescription `
                    -Scope $LogAnalyticsWS -Severity $alertSeverity -WindowSize $windowSize -EvaluationFrequency $evaluationFreq -CriterionAllOf $criteriaAllof -Tag $Tag -Enabled -AutoMitigate
            }
            else {
                $AlertCreate = New-AzScheduledQueryRule -Name $alertName -ResourceGroupName $resourceGroupName -Location $location -DisplayName $alertDisplayName -Description $alertDescription `
                    -Scope $LogAnalyticsWS -Severity $alertSeverity -WindowSize $windowSize -EvaluationFrequency $evaluationFreq -CriterionAllOf $criteriaAllof -Tag $Tag -Enabled
            }
        }
        If ($action -eq 'RemoveTag') {
            "AVD - Removing Query Alert: $alertName"
            Remove-AzScheduledQueryRule -ResourceGroupName $resourceGroupName -Name $alertName
        }
    }

}

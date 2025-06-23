# $dashboardId="subscriptions/e315fe54-eae5-464d-8266-0f41a0908da8/resourceGroups/rg-MonstarPacks/providers/Microsoft.Dashboard/dashboards/winos"
# $dashboarduid=$dashboardId.replace("/","~")
# $location='centralus'
# $tenantId=(Get-AzContext).Tenant.Id
# #$scope="https://monitor.azure.com"
# $bearerToken = (Get-AzAccessToken -TenantId $tenantId ).Token
# $bearerToken
# $location
# $URL="https://local-$($location).gateway.dashboard.azure.com/api/dashboards/uid/$($dashboarduid)"
# "URL: $URL"
# Invoke-RestMethod -Method Get -Uri $URL -Headers @{Authorization="Bearer $bearerToken"} #-ContentType "application/json"

function get-grafanaDashboard {
    param (
        [string]$dashboardName,
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$location,
        [string]$tenantId = (Get-AzContext).Tenant.Id
    )
    $dashboardId = "subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Dashboard/dashboards/$dashboardName"
    $dashboarduid = $dashboardId.replace("/", "~") 
    $bearerToken = (Get-AzAccessToken -TenantId $tenantId ).Token
    $bearerToken
    $location
    $URL="https://local-$($location).gateway.dashboard.azure.com/api/dashboards/uid/$($dashboarduid)"
    "URL: $URL"
    Invoke-RestMethod -Method Get -Uri $URL -Headers @{Authorization="Bearer $bearerToken"} #-ContentType "application/json"
}
function import-grafanaDashboard {
    param (
        [string]$dashboardName,
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$location,
        [string]$dashboardTitle,
        [string]$tenantId = (Get-AzContext).Tenant.Id,
        [string]$dashboardFilePath
    )
    # Select the subscription context if not already set to the current subscription
    if ((Get-AzContext).Subscription.Id -ne $subscriptionId) {
        Set-AzContext -SubscriptionId $subscriptionId
    }
    $dashboardId = "subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Dashboard/dashboards/$dashboardName"
    $dashboarduid = $dashboardId.replace("/", "~") 
    $bearerToken = (Get-AzAccessToken -TenantId $tenantId ).Token
    $body = get-content $dashboardFilePath # C:\git\AzureMonitorStarterPacks\Packs\dashboards\grafana-lxos.json
    # FIND the string "$$REPLACE_UID$$" in the body and replace it with the actual dashboarduid
    $body = $body -replace '\$\$UID\$\$', $dashboarduid
    $data =@"
    {
             "dashboard": $body,
                "folderUid": "",
                "message": "Made changes to $dashboardName",
                "overwrite": true
}
"@
    $URL="https://local-$($location).gateway.dashboard.azure.com/api/dashboards/db"
    Invoke-RestMethod -Method Post -Uri $URL -Headers @{Authorization="Bearer $bearerToken";Accept='application/json'} -Body $data -ContentType "application/json" 
}

function new-grafanaDashboard {
    param (
        [string]$dashboardName,
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$location,
        [string]$dashboardTitle,
        [string]$dashboardFilePath,
        [string]$packtag
    )
    # deploy a new Grafana dashboard using arm
    $tempTemplateFile= $env:temp + "\grafanaDashboard.json"
    $dashboardTemplate= @"
    {
        "`$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
        "contentVersion": "1.0.0.0",
        "resources": [
            {
                "name": "$dashboardName",
                "type": "microsoft.dashboard/dashboards",
                "location": "$location",
                "tags": {
                    "GrafanaDashboardResourceType": "Azure Monitor",
                    "MonitorStarterPacks": "$packtag",
                    "InstanceName": "$env:InstanceName"
                },
            "apiVersion": "2024-11-01-preview"
            }
        ]
    }
"@
    $dashboardTemplate | Out-File -FilePath $tempTemplateFile -Encoding utf8
    # Deploy arm template to create a new Grafana dashboard
    Write-host "Creating Grafana dashboard $dashboardName in resource group $resourceGroupName in location $location"
    New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName `
        -TemplateFile $tempTemplateFile
    # Import the Grafana dashboard using the import-grafanaDashboard function
    Write-host "Importing Grafana dashboard $dashboardName from file $dashboardFilePath"
    import-grafanaDashboard -subscriptionId $subscriptionId `
                     -resourceGroupName $resourceGroupName -dashboardName $dashboardName `
                     -location $location `
                     -dashboardTitle $dashboardTitle `
                     -dashboardFilePath $dashboardFilePath
}


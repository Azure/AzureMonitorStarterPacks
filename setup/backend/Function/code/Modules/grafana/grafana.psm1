$dashboardId="subscriptions/e315fe54-eae5-464d-8266-0f41a0908da8/resourceGroups/rg-MonstarPacks/providers/Microsoft.Dashboard/dashboards/winos"
$dashboarduid=$dashboardId.replace("/","~")
$location='centralus'
$tenantId=(Get-AzContext).Tenant.Id
#$scope="https://monitor.azure.com"
$bearerToken = (Get-AzAccessToken -TenantId $tenantId ).Token
$bearerToken
$location
$URL="https://local-$($location).gateway.dashboard.azure.com/api/dashboards/uid/$($dashboarduid)"
"URL: $URL"
Invoke-RestMethod -Method Get -Uri $URL -Headers @{Authorization="Bearer $bearerToken"} #-ContentType "application/json"

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
function new-grafanaDashboard {
    param (
        [string]$dashboardName,
        [string]$subscriptionId,
        [string]$resourceGroupName,
        [string]$location,
        [string]$dashboardTitle,
        [string]$tenantId = (Get-AzContext).Tenant.Id
    )
    $dashboardId = "subscriptions/$subscriptionId/resourceGroups/$resourceGroupName/providers/Microsoft.Dashboard/dashboards/$dashboardName"
    $dashboarduid = $dashboardId.replace("/", "~") 
    $bearerToken = (Get-AzAccessToken -TenantId $tenantId ).Token
    $body = @"
    {
        "dashboard": {
            "id": null,
            "uid": null,
            "title": "$dashboardTitle",
            "tags": [ "templated" ],
            "timezone": "browser",
            "schemaVersion": 16,
            "refresh": "25s",
            "version": 1
            },
            "folderUid": "",
            "message": "Made changes to $dashboardName",
            "overwrite": true
    }
"@
    $URL="https://local-$($location).gateway.dashboard.azure.com/api/dashboards/db"
    Invoke-RestMethod -Method Post -Uri $URL -Headers @{Authorization="Bearer $bearerToken"} -Body $body -ContentType "application/json" 
}


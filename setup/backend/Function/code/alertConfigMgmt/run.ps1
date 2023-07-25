using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$alerts = $Request.Body.Alerts
$action = $Request.Body.Action
#$TagValue = $Request.Body.Pack
$apiversion="2023-03-15-preview"
if ($alerts) {
        #$TagName='MonitorStarterPacks'
    $TagName=$env:TagName
    if ([string]::isnullorempty($TagName)) {
        $TagName='MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    "Working on $($alerts.count) server(s). Action: $action. "
    switch ($action) {
        'Enable' {
            $bodyAction=@"
            {
                "properties": {
                  "enabled": "true"
                }
            }
"@
        }
        'Disable' {
            $bodyAction=@"
            {
                "properties": {
                  "enabled": "false"
                }
            }
"@
        }
        default {
            Write-Host "Invalid Action"
        }
    }
    foreach ($alert in $alerts) {
        $alertinfo=$alert.id.split("/") #2 is subscription, 4 is resource group,#8 is alert name
        
        "Running $action for $($alertinfo[8]) alert."
        $patchURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.Insights/scheduledQueryRules/{2}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[8]
        Invoke-AzRestMethod -Method PATCH -Uri $patchURL -Payload $bodyAction
    }
}
else
{
    "No alerts provided."
}
$body = "This HTTP triggered function executed successfully. $($alerts.count) were altered ($action)."
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

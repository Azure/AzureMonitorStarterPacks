using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$alerts = $Request.Body.AlertIds
$action = $Request.Body.Action
#$TagValue = $Request.Body.Pack

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
            foreach ($alert in $alerts) {
                # Enable alert
            }
        }
        'Disable' {
            foreach ($alert in $alerts) {
                "Running $action for $($alert.Server) alert."
                #Disable alert
            }
        }
        default {
            Write-Host "Invalid Action"
        }
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

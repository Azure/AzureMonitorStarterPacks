using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Request will contain a body with the following parameters:
# TaskNames - Array of strings with the names of the tasks to run. Use "All" to run all tasks.
# Other tasknames can be:
# - AvailablePacks
# - SupportedServices
# - MonitoredServices
# - UnmonitoredServices
Write-host "Request Body: $($Request.Body | ConvertTo-Json -Depth 10)"

$TaskNames = $Request.Body.TaskNames
if ([string]::IsNullOrEmpty($TaskNames)) {
    Write-Host "No TaskNames provided. Running all tasks."
    $TaskNames = @("All")
}
else {
    Write-Host "TaskNames provided: $($TaskNames -join ', ')"
}
<#
param availableIaaSPackstablename string = 'AvailableIaaSPacks_CL'
param supportedServicesTableName string = 'SupportedServices_CL'
param monitoredPaaSTableName string = 'MonitoredPaaSTable_CL'
param nonMonitoredPaaSTableName string = 'NonMonitoredPaaSTable_CL'
#>
try {
    start-opstasks -TaskNames $TaskNames
    $body="OK"
}catch {
    Write-Host "Error in start-opstasks. $_"
    $body = "Error in start-opstasks. $_"
}
    # Write an information log with the current time.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body       = $body
})



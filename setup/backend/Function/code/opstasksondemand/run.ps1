using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
<#
param availableIaaSPackstablename string = 'AvailableIaaSPacks_CL'
param supportedServicesTableName string = 'SupportedServices_CL'
param monitoredPaaSTableName string = 'MonitoredPaaSTable_CL'
param nonMonitoredPaaSTableName string = 'NonMonitoredPaaSTable_CL'
#>
try {
    start-opstasks
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



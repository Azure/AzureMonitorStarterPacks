# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
<#
param availableIaaSPackstablename string = 'AvailableIaaSPacks_CL'
param supportedServicesTableName string = 'SupportedServices_CL'
param monitoredPaaSTableName string = 'MonitoredPaaSTable_CL'
param nonMonitoredPaaSTableName string = 'NonMonitoredPaaSTable_CL'
#>
start-opstasks
# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

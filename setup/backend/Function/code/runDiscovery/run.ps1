# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
$instanceName=$env:InstanceName
if ($instanceName) {
    get-discoveryresults -instanceName $instanceName # analyses results and stores results in log analytics workspace under the resultsdiscovery table.
}
else {
    Write-Host "No instance name provided."
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

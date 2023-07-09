# Input bindings are passed in via param block.
param($Timer)

# Get the current universal time in the default string format.
$currentUTCtime = (Get-Date).ToUniversalTime()

# The 'IsPastDue' property is 'true' when the current function invocation is later than scheduled.
if ($Timer.IsPastDue) {
    Write-Host "PowerShell timer is running late!"
}
Connect-AzAccount -Identity

Select-Azsubscription 6c64f9ed-88d2-4598-8de6-7a9527dc16ca

Write-Output "Starting Discovery using Custom Script Extension for Windows VMs."


$date="$(Get-Date -format 'o')"
$FileUri="https://amonstarterpacks2abbd.blob.core.windows.net/discovery/cse-discoverwindows.ps1"
$Run="cse-discoverwindows.ps1"
$ResourceGroupName="AMonStarterpacks"
$Location="eastus"
$WindowsVMs=Get-AzVM -Status | ? {$_.PowerState -eq 'VM running' -and $_.OSProfile.WindowsConfiguration -ne $null}
Write-Output "Date: $date"
Write-Output "FileUri: $FileUri"
Write-Output "Run: $Run"
Write-Output "ResourceGroupName: $ResourceGroupName"
Write-Output "Found $($WindowsVMs.Count) Started Windows VMs."
$WindowsVMs | foreach {
    try {
        Set-AzVMCustomScriptExtension -ResourceGroupName $_.ResourceGroupName `
            -VMName $_.Name -Name "CustomScriptDiscovery" `
            -Location $Location `
            -FileUri $FileUri `
            -Run $Run `
            -Argument "$date"
    }
    catch {
        Write-Output "Error Calling script extension on $($_.Name) VM: $($_.Exception.Message)"
    }
}

# Write an information log with the current time.
Write-Host "PowerShell timer trigger function ran! TIME: $currentUTCtime"

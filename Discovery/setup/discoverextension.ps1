#$date=(get-date).tostring("yyyyMMddHHmmss")
Write-Output "Starting Discovery using Custom Script Extension for Windows VMs."
Write-Output "Date: $date"
Write-Output "FileUri: $FileUri"
Write-Output "Run: $Run"
Write-Output "ResourceGroupName: $ResourceGroupName"

$date="$(Get-Date -format 'o')"
$FileUri="c:\temp\script.ps1"
$Run="script.ps1"
$ResourceGroupName="AMonStarterPacks"
$Location="eastus"
$WindowsVMs=Get-AzVM -Status | ? {$_.PowerState -eq 'VM running' -and $_.OSProfile.WindowsConfiguration -ne $null}
Write-Output "Found $($WindowsVMs.Count) Started Windows VMs."
$WindowsVMs | foreach {
    try {
        Set-AzVMCustomScriptExtension -ResourceGroupName $ResourceGroupName `
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
# 2023-02-11T21:11:54Z

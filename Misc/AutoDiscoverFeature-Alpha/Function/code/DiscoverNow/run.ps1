using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
Connect-AzAccount -Identity

Select-Azsubscription 6c64f9ed-88d2-4598-8de6-7a9527dc16ca

Write-Output "Starting Discovery using Custom Script Extension for Windows VMs."


$date="$(Get-Date -format 'o')"
$FileUri="https://amonstarterpacks2abbd.blob.core.windows.net/discovery/cse-discoverwindows.ps1"
$Run="cse-discoverwindows.ps1"
$ResourceGroupName="AMonStarterpacks"
$Location="eastus"
$WindowsVMs=Get-AzVM -Status | Where-Object {$_.PowerState -eq 'VM running' -and $_.OSProfile.WindowsConfiguration -ne $null}
Write-Output "Date: $date"
Write-Output "FileUri: $FileUri"
Write-Output "Run: $Run"
Write-Output "ResourceGroupName: $ResourceGroupName"
Write-Output "Found $($WindowsVMs.Count) Started Windows VMs."
$WindowsVMs | ForEach-Object {
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

# # Interact with query parameters or the body of the request.
# $name = $Request.Query.Name
# if (-not $name) {
#     $name = $Request.Body.Name
# }

# $body = "This HTTP triggered function executed successfully. Pass a name in the query string or in the request body for a personalized response."

# if ($name) {
#     $body = "Hello, $name. This HTTP triggered function executed successfully."
# }

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

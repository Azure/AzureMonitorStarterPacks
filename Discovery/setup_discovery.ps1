param (
    [Parameter(Mandatory = $true)]
    [string]
    $configFilePath,
    [Parameter(Mandatory = $true)]
    [string]
    $userId,
    [string] 
    $subscriptionId
)
#region Configuration and initialization
#Other Variables

#before deploying anything, check if current user can be found.
$begin = get-date
Write-Verbose "Adding current user as a Keyvault administrator (for setup)."
if ($userId -eq "") {
    $currentUserId = (get-azaduser -SignedIn).Id 
}
else {
    $currentUserId = (get-azaduser -UserPrincipalName $userId).Id
}
if ($null -eq $currentUserId) {
    Write-Error "Error: no current user could be found in current Tenant. Context: $((Get-AzAdUser -SignedIn).UserPrincipalName). Override specified: $userId."
    break;
}
#$tenantDomainUPN=$userId.Split("@")[1]
#region  Template Deployment

Write-Output "Reading Config file:"
try {
    $config = get-content $configFilePath | convertfrom-json
}
catch {
    "Error reading config file."
    break
}
#$tenantIDtoAppend="-"+$($env:ACC_TID).Split("-")[0]
$tenantIDtoAppend = "-" + $((Get-AzContext).Tenant.Id).Split("-")[0]

$keyVaultName = $config.keyVaultName + $tenantIDtoAppend
$resourcegroup = $config.resourcegroup + $tenantIDtoAppend
$region = $config.region
$logAnalyticsworkspaceName = $config.logAnalyticsworkspaceName + $tenantIDtoAppend
$functionname = $config.functionName + $tenantIDtoAppend
$keyVaultRG=$resourcegroup
$deployKV=$true
# Checks permissions, now for both update and setup
#if ( $null -eq (Get-AzRoleAssignment | Where-Object { $_.RoleDefinitionName -eq "User Access Administrator"`
#                -and $_.SignInName -eq $userId -and $_.Scope -eq "/" })) {
#        Write-Output $userId + " doesn't have Access Management for Azure Resource permissions,please refer to the requirements section in the setup document"
#        Break                                                
#}
#checks if logged in.
$subs = Get-AzSubscription -ErrorAction SilentlyContinue
if (-not($subs)) {
    Connect-AzAccount
}
if ([string]::IsNullOrEmpty($subscriptionId)){
    $subs = Get-AzSubscription -ErrorAction SilentlyContinue
    if ($subs.count -gt 1) {
        Write-output "More than one subscription detected. Current subscription $((get-azcontext).Name)"
        Write-output "Please select subscription for deployment or Enter to keep current one:"
        $i = 1
        $subs | ForEach-Object { Write-output "$i - $($_.Name) - $($_.SubscriptionId)"; $i++ }
        [int]$selection = Read-Host "Select Subscription number: (1 - $($i-1))"
    }
    else { $selection = 0 }
    if ($selection -ne 0) {
        if ($selection -gt 0 -and $selection -le ($i - 1)) { 
            Select-AzSubscription -SubscriptionObject $subs[$selection - 1]
        }
        else {
            Write-output "Invalid selection. ($selection)"
            break
        }
    }
    else {
        Write-host "Keeping current subscription."
    }
}
else {
    Write-Output "Selecting $subcriptionId subscription:"
    try {
        Select-AzSubscription -Subscription $subscriptionId
    }
    catch {
        Write-error "Error selecting provided subscription."
        break
    }
}
Write-Output "Creating bicep parameters file for this deployment."
$templateParameterObject = @{
    'kvName' = $keyVaultName
    'location' = $region
    'storageAccountName' = $storageaccountName
    'logAnalyticsWorkspaceName' = $logAnalyticsworkspaceName
    'functionname' = $functionname
}
# Adding URL parameter if specified
If (![string]::IsNullOrEmpty($alternatePSModulesURL)) {
    $templateParameterObject += @{CustomModulesBaseURL = $alternatePSModulesURL }
}
#checks if update or not.
#   # #### #   #   ##### ##### ##### #   # #####
##  # #    #   #   #     #       #   #   # #   #
# # # ###  # # #   ##### ####    #   #   # #####
#  ## #    ## ##       # #       #   #   # #   
#   # #### #   #   ##### #####   #   ##### #   
if (!$update)
{
    #Configuration Variables
    $randomstoragechars = -join ((97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })
    $storageaccountName = "$($config.storageaccountName)$randomstoragechars"
    #Storage verification
    if ((Get-AzStorageAccountNameAvailability -Name $storageaccountName).NameAvailable -eq $false) {
        Write-Error "Storage account $storageaccountName not available."
        break
    }
    if ($storageaccountName.Length -gt 24 -or $storageaccountName.Length -lt 3) {
        Write-Error "Storage account name must be between 3 and 24 lowercase characters."
        break
    }
    $templateParameterObject.storageAccountName=$storageaccountname #needs to set this again since it is an update.
    #endregion
    #region keyvault verification
    $kvContent = ((Invoke-AzRest -Uri "https://management.azure.com/subscriptions/$((Get-AzContext).Subscription.Id)/providers/Microsoft.KeyVault/checkNameAvailability?api-version=2021-11-01-preview" `
                -Method Post -Payload "{""name"": ""$keyVaultName"",""type"": ""Microsoft.KeyVault/vaults""}").Content | ConvertFrom-Json).NameAvailable
    if (!($kvContent) -and $deployKV) {
        write-output "Error: keyvault name $keyVaultName is not available."
        break
    }
    #endregion
    Write-Verbose "Creating $resourceGroup in $region location."
    try {
        New-AzResourceGroup -Name $resourceGroup -Location $region -Tags $tagstable
    }
    catch { 
        throw "Error creating resource group. $_" 
    }
    #$templateParameterObject

    Write-Output "Deploying solution through bicep."
    try { 
        New-AzResourceGroupDeployment -ResourceGroupName $resourcegroup -Name "azmonstarpacks$(get-date -format "ddmmyyHHmmss")" `
            -TemplateParameterObject $templateParameterObject -TemplateFile .\setup\discovery.bicep -WarningAction SilentlyContinue
    }
    catch {
        Write-error "Error deploying solution to Azure. $_"
    }
    #endregion
    #region configuration
    # Copies discovery script to storage account.
    copy-toBlob -FilePath '../Packs/packs.json' -storageaccountName $storageaccountName -resourceGroup $resourcegroup -force -containerName "discovery"
    copy-toBlob -FilePath './setup/cse-discoverwindows.ps1' -storageaccountName $storageaccountName -resourceGroup $resourcegroup -force -containerName "discovery"

    
    #$keyVaultRG=$resourcegroup
    #$logAnalyticsWorkspaceRG=$resourcegroup
    #Add current user as a Keyvault administrator (for setup)
    #try { $kv = Get-AzKeyVault -ResourceGroupName $keyVaultRG -VaultName $keyVaultName } catch { "Error fetching KV object. $_"; break }
    #try { New-AzRoleAssignment -ObjectId $currentUserId -RoleDefinitionName "Key Vault Administrator" -Scope $kv.ResourceId }catch { "Error assigning permissions to KV. $_"; break }
    #Write-Output "Sleeping 30 seconds to allow for permissions to be propagated."
    #Start-Sleep -Seconds 30
    #region Secret Setup
    # Adds keyvault secret user permissions to the Function App
    # Write-Verbose "Adding automation account Keyvault Secret User."
    # try {
    #     New-AzRoleAssignment -ObjectId (Get-azwebapp -Name $functionName -ResourceGroupName $resourceGroup).Identity.PrincipalId -RoleDefinitionName "Key Vault Secrets User" -Scope $kv.ResourceId
    #     New-AzRoleAssignment -ObjectId (Get-azwebapp -Name $functionName -ResourceGroupName $resourceGroup).Identity.PrincipalId -RoleDefinitionName "Key Vault Reader" -Scope $kv.ResourceId
    # }
    # catch {
    #     "Error assigning permissions to Automation account (for keyvault). $_"
    #     break
    # }
    #endregion
    #region Import main runbook
    Write-Verbose "Installing function code." #install function trigger code
    try {
        ###Deploy function code
        Compress-Archive -Path './Discovery/Function/code/*' -DestinationPath /tmp/discovery.zip -Force
        Publish-AzWebApp -ResourceGroupName $resourcegroup -Name $functionname -ArchivePath /tmp/discovery.zip -Force
    }
    catch {
        "Error installing code for trigger function. $_"
        break
    }
    #endregion
    $timetaken = ((get-date) - $begin) 
    "Time to deploy: $([Math]::Round($timetaken.TotalMinutes,0)) Minutes."
}

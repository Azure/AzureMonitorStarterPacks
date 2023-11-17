<#
    .SYNOPSIS
        Deploy or Updated the Azure Monitor Started packs solution.
    .DESCRIPTION
        This script will deploy the Azure Monitor Started packs solution.
    .NOTES
        N/A
    .LINK
        https://github.com/Azure/AzureMonitorstarterPacks
    .EXAMPLE 
        # Minimal parameters required to deploy the solution:
        .\setup.ps1 -resourceGroup "myResourceGroup" -location "eastus"

        This example will ask for a workspace and a subscription. It will try to use the default DCR based on the MSVMI-<workspacename> pattern.
        It will also ask for an Action Group to be created. If you want to use an existing Action Group, use the -useExistingAG switch.
    #>
param (
    # the log analytics workspace where monitoring data will be sent
    [Parameter(Mandatory=$false)]
    [string]
    $workspaceResourceId,
    # the resource group where the azure monitor starter packs solution will be deployed
    [Parameter(Mandatory=$true)]
    [string]
    $solutionResourceGroup,
    # tag name used to identify the resources created by the solution and specify configuration
    [Parameter()]
    [string]
    $solutionTag='MonitorStarterPacks',
    # azure region where solution components will be deployed. Not all workloads must be deployed in the same region, but cross-region charges may apply.
    [Parameter(Mandatory=$true)]
    [string]
    $location,
    # specify to use an existing Action Group
    [Parameter()]
    [switch]
    $useExistingAG,
    # specify the name of the new or existing Action Group
    [Parameter()]
    [string]
    $actionGroupName,
    # names of recipients configured in the Action Group
    [Parameter()]
    [string[]]
    $emailreceivers=@(), 
    # email addresses of recipients configured in the Action Group
    [Parameter()]
    [string[]]
    $emailreceiversEmails=@(),
    # specify to skip deployment of Policies used to deploy the Azure Monitor Agent on target VMs
    [Parameter()]
    [switch]
    $skipAMAPolicySetup,
    # specify to skip the deployment of the main solution? (workbooks, alerts, etc)
    [Parameter()]
    [switch]
    $skipMainSolutionSetup,
    # specify to skip the deployment of Pack-specific resources
    [Parameter()]
    [switch]
    $skipPacksSetup,
    [Parameter()]
    [switch]
    $confirmEachPack,
    # specify the subscription ID where the solution will be deployed
    [Parameter()]
    [string]
    $subscriptionId,
    [Parameter(
        HelpMessage="Specify the management group where the solution will be deployed. If not specified, the script will ask for one. This is the last of a management group id (e.g. /providers/Microsoft.Management/managementGroups/<management group name>)."
    )]
    [string]
    $managementGroupName,
    # specify to use the same Action Group for all packs, otherwise a new Action Group will be created for each pack
    [Parameter()]
    [switch]
    $useSameAGforAllPacks,
    # specify the location of the packs.json file
    [Parameter()]
    [string]
    $packsFilePath="./Packs/packs.json",
    [Parameter()]
    [string]
    $grafanalocation,
    [Parameter(
        HelpMessage="Specify whether assignment should be at a single subscription level or at a management group level for pack policies. Default is subscription."
    )]
    [string]
    $assignmentLevel='subscription'
)
$solutionVersion="0.1.0"
$allowedGrafanaRegions=('southcentralus,westcentralus,westeurope,eastus,eastus2,northeurope,uksouth,australiaeast,swedencentral,westus,westus2,westus3,southeastasia,canadacentral,centralindia,eastasia').split(",")

if ([string]::IsNullOrEmpty($grafanalocation)) {
    $grafanalocation=$location
}
if ($grafanalocation -notin $allowedGrafanaRegions) {
    Write-Error "Grafana is not available in $grafanalocation. Please select a different location."
    Write-Error "You can use -grafanalocation to specify a different location."
    return    
}

#region basic initialization
Write-Output "Installing/Loading Azure Graph module."
if ($null -eq (get-module Az.ResourceGraph)) {
    try {
        install-module az.resourcegraph #-Force # if -Force is used, it causes issues in the CLI (older Az.Account module is loaded)
        import-module az.ResourceGraph #-Force
    }
    catch {
        Write-Error "Unable to install az.resourcegraph module. Please make sure you have the proper permissions to install modules."
        return
    }
}
"Import local common module."
if ($null -eq (get-module AzMPacks-Common)) {
    try {
        import-module ./modules/ps/AzMPacks-common.psm1
    }
    catch {
        Write-Error "Unable to import AzMPacks-Common module. Please make sure the module is present in the modules/ps folder."
        return
    }
}
# tests if subscriptionId is provided. If not, it will ask for one.
if (!([string]::IsNullOrEmpty($subscriptionId))) {
    Write-host "Using subscription $subscriptionId to deploy the packs, log analytics workspace and DCRs."
    Select-AzSubscription -SubscriptionId $subscriptionId -ErrorAction Stop | out-null
    $sub=Get-AzSubscription -SubscriptionId $subscriptionId
}
else {
    # If more subscriptions are present, select one to deploy the packs.
    if ((Get-AzSubscription -ErrorAction SilentlyContinue).count -gt 1) {
        Write-host "Select a subscription to deploy the packs, log analytics workspace and DCRs."
        $sub=select-subscription
        if ($null -eq $sub) {
            Write-Error "No subscription selected. Exiting."
            return
        }
        Select-AzSubscription -SubscriptionId $sub.Id
    }
    else {
        $sub=Get-AzSubscription
        "Using $($sub.Name) subscription since there is no other one."
    }
}
if ($null -eq $sub) {
    Write-Error "No subscription selected. Exiting."
    return
}
#Creates the resource group if it does not exist.
# Add test to see if RG is in the same region as the new requested region.
if (!(Get-AzResourceGroup -name $solutionResourceGroup -ErrorAction SilentlyContinue)) {
    try {
        $resourceGroupId=(New-AzResourceGroup -Name $solutionResourceGroup -Location $location).ResourceId
    }
    catch {
        Write-Error "Unable to create resource group $solutionResourceGroup. Please make sure you have the proper permissions to create a resource group in the $location location."
        return
    }
}
else {
    $resourceGroupId=(Get-AzResourceGroup -name $solutionResourceGroup).ResourceId
    if ((Get-AzResourceGroup -name $solutionResourceGroup -ErrorAction SilentlyContinue).Location -ne $location) {
        Write-Error "Resource group $solutionResourceGroup already exists in a different location. Please select a different resource group name or delete the existing resource group."
        return
    }
    else {
        Write-Host "Using existing resource group $solutionResourceGroup."

    }
}
if ( [string]::IsNullOrEmpty($workspaceResourceId)) {
    $ws=select-workspace -location $location -resourceGroup $solutionResourceGroup -solutionTag $solutionTag
}
else { 
    $ws=Get-AzOperationalInsightsWorkspace -Name $workspaceResourceId.split('/')[8] -ResourceGroupName $workspaceResourceId.split('/')[4] -ErrorAction SilentlyContinue
    if ($null -eq $ws) {
        Write-Error "Workspace $($workspaceResourceId.split('/')[8]) not found. "
        return
    }
}
#Deployments are always done at MG level now. 
if ([string]::IsNullOrEmpty($managementGroupName)) {
    $MG=new-list -objectList (Get-AzManagementGroup -ErrorAction SilentlyContinue) -type "ManagementGroup" -fieldName1 "DisplayName" -fieldName2 "Id"
    if ($null -eq $MG) {
        Write-Error "No management group selected. Exiting."
        return
    }
    $MGName=$MG.Name
}
else {
    $MGName=$managementGroupName
}
# Determine MG level if needed


#$wsfriendlyname=$ws.Name
$userId=(Get-AzADUser -SignedIn).Id

# Az available for Grafana setup of the modules? Only test if packs are to be deployed.
if (!($skipPacksSetup)) {

    # check whether Azure CLI is installed
    if (Get-Command 'az.*' -ErrorAction SilentlyContinue) {
        $azAvailable=$true}
    else {$azAvailable=$false}

    if ($azAvailable) {
        az extension add --name amg
        $azloggedIn=$false
        "Testing az cli login..."
        $output=az account get-access-token --query "expiresOn" --output json
        if (!$output) {
            "you don't seem to be logged in to Azure via the Azure CLI."
            return
        }
        else {
            Write-host "Setting Azure Cli susbscription to $($sub.Id). If you see an error here, you aren't probably logged in. use 'az login' to connect to Azure."
            az account set --subscription $($sub.Id)
            $azloggedIn=$true
        }
    }
    else {
        $azloggedIn=$false
    }
}
#endregion
#region AMA policy setup
if (!$skipAMAPolicySetup) {
    Write-Host "Enabling custom policy initiative to enable automatic AMA deployment. "

    $parameters=@{
        solutionTag=$solutionTag
        location=$location
        solutionVersion=$solutionVersion
        subscriptionId=$sub.Id
        resourceGroupName=$solutionResourceGroup
        assignmentlevel=$assignmentLevel
    }
    Write-Host "Deploying the AMA policy initiative to the the selected management group."
    Write-Host "Assigning initiative at the $assignmentLevel level."
    New-AzManagementGroupDeployment -name "amapolicy$(get-date -format "ddmmyyHHmmss")" -ManagementGroupId $MGName -location $location `
    -TemplateFile './setup/AMAPolicy/amapoliciesmg.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null 
    # }
    # else {
    #     $parameters=@{
    #         solutionTag=$solutionTag
    #         location=$location
    #         solutionVersion=$solutionVersion
    #     }
    #     Write-Host "Deploying the AMA policy initiative to the current subscription."
    #     New-AzResourceGroupDeployment -name "amapolicy$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $solutionResourceGroup `
    #     -TemplateFile './setup/AMAPolicy/amapolicies.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null 
    # }
}
else {
    Write-Host "Skipping AMA policy check and configuration, as requested."
}
#endregion
#region Main solution setup - Backend
# Setup Workbook, function, logic app  for Tag Configuration
if (!($skipMainSolutionSetup)) {

    # generate random storage account name
    $randomstoragechars = -join ((97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })

    # zip the Function App's code
    compress-archive ./setup/backend/Function/code/* ./setup/backend/backend.zip -Force
    $existingSAs=Get-AzStorageAccount -ResourceGroupName $solutionResourceGroup -ErrorAction SilentlyContinue
    if ($existingSAs) {
        if ($existingSAs.count -gt 1) {
            $storageaccountName=(new-list -objectList $existingSAs -type "StorageAccount" -fieldName1 "StorageAccountName" -fieldName2 "ResourceGroupName").StorageAccountName
        }
        else {
            $storageaccountName=$existingSAs.StorageAccountName
            Write-Output "Using existing storage account $storageaccountName."
        }
    }
    else {
        $storageaccountName = "azmonstarpacks$randomstoragechars"
        Write-Host "Using storage account name: $storageaccountName"
    }

    # Check if the function app already exists to acount for role assignments, which is annoying.
    # $existingFunctionApp=Get-AzResource -ResourceType 'Microsoft.Web/sites' -ResourceGroupName $solutionResourceGroup -ErrorAction SilentlyContinue
    # if ($existingFunctionApp) {
        
    # }
    $grafanaName="AMSP$($sub.id.split("-")[0])"
    $functionName="MonitorStarterPacks-$($sub.id.split("-")[0])"
    $parameters=@{
        functionname=$functionName
        location=$location
        storageAccountName=$storageAccountName
        lawresourceid=$ws.ResourceId
        appInsightsLocation=$location
        solutionTag=$solutionTag
        solutionVersion=$solutionVersion
        currentUserIdObject=$userId
        grafanaName=$grafanaName
        grafanalocation=$grafanalocation
        subscriptionId=$sub.Id
        resourceGroupName=$solutionResourceGroup
        mgname=$MGName
    }
    Write-Host "Deploying the backend components(function, logic app and workbook)."
    try {
        $backend=New-AzManagementGroupDeployment -name "maindeployment$(get-date -format "ddmmyyHHmmss")" -ManagementGroupId $MGName -location $location `
        -TemplateFile './setup/backend/code/backend.bicep' -templateParameterObject $parameters -ErrorAction Stop # | Out-Null #-Verbose
        #$backend.Outputs
        $packsUserManagedIdentityPrincipalId=$backend.Outputs.packsUserManagedIdentityId.Value
        $packsUserManagedIdentityResourceId=$backend.Outputs.packsUserManagedResourceId.Value
    }
    catch {
        Write-Error "Unable to deploy the backend components. Please make sure you have the proper permissions to deploy resources in the $solutionResourceGroup resource group."
        Write-Error $_.Exception.Message
        return
    }
}
# Reads the packs.json file
if (!($skipPacksSetup)) {
    Write-Host "Found the following ENABLED packs in packs.json config file:"

    $packs=Get-Content -Path $packsFilePath | ConvertFrom-Json| Where-Object {$_.Status -eq 'Enabled'}
    $packs | ForEach-Object {Write-Host "$($_.PackName) - $($_.Status)"}
    $dceName="DCE-$solutionTag-$location"
    $dceId="/subscriptions/$($sub.Id)/resourceGroups/$solutionResourceGroup/providers/Microsoft.Insights/dataCollectionEndpoints/$dceName"
    if (!(Get-AzResource -ResourceId $dceId -ErrorAction SilentlyContinue)) {
        Write-Host "Endpoint $dceName ($dceId) not found."
        break
    }
    else {
        Write-Host "Using existing Data Collection Endpoint $dceName"
    }
    # Look for existing user managed identity. 
    if ([string]::IsNullOrEmpty($packsUserManagedIdentityPrincipalId)) {
        # Fetch existing managed identity. Name should be:
        $packsUserManagedIdentityResourceId=(get-azresource -ResourceGroupName $solutionResourceGroup -ResourceType 'Microsoft.ManagedIdentity/userAssignedIdentities' -Name 'packsUserManagedIdentity').ResourceId
        $packsUserManagedIdentityPrincipalId=(Get-AzADServicePrincipal -DisplayName 'packsUserManagedIdentity').Id
    }
    # deploy packs if any are enabled
    if ($packs.count -gt 0) {
        if ($useSameAGforAllPacks) {
            Write-host "'useSameAGforAllPacks' flag detected. Please provide AG information to be used to all Packs, either new or existing (depending on useExistingAG switch)"
            if ([string]::IsNullOrEmpty($existingAGName)) {
                $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
                if ($null -eq $AGinfo) {
                    Write-Error "No Action Group selected. Exiting."
                    return
                }
            }
            else {
                $AG=get-azactionGroup | Where-Object {$_.Name -eq $existingAGName}
                if ($AG.Count -eq 1) {
                    $AGInfo=@{
                        name=$AG.name
                        emailReceivers=$AG.emailReceivers
                        emailReceiversEmails=$AG.emailReceiversEmails
                        resourceGroup=$AG.ResourceGroupName
                    }
                }
                else {
                    Write-Host "Action Group $existingAGName not found or more than one found. Please select AG:"
                    $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
                }
            }
        }

        install-packs -packinfo $packs `
            -resourceGroupId $resourceGroupId `
            -AGInfo $AGinfo `
            -useExistingAG:$useExistingAG.IsPresent `
            -existingAGName $actionGroupName `
            -useSameAGforAllPacks:$useSameAGforAllPacks.IsPresent `
            -workspaceResourceId $ws.ResourceId `
            -solutionTag $solutionTag `
            -solutionVersion $solutionVersion `
            -confirmEachPack:$confirmEachPack.IsPresent `
            -location $location `
            -dceId $dceId `
            -azAvailable $azloggedIn `
            -userManagedIdentityResourceId $packsUserManagedIdentityResourceId `
            -grafananame "AMSP$($sub.id.split("-")[0])" `
            -assignmentlevel $assignmentLevel `
            -managementGroupName $MGName `
            -subscriptionId $sub.Id
            

        # Grafana dashboards
        # if ($deploymentResult -eq $true) {
        #     $azAvailable=$false
        #     try {
        #         az
        #         $azAvailable=$true
        #     }
        #     catch {
        #         "didn't find az"
        #         $azAvailable=$false
        #     }
        #     if ($azAvailable) {
        #         # This should be moved into the install packs routine eventually
        #         az extension add --name amg
        #         az account set --subscription $($sub.Id)
        #         foreach ($pack in $packs) {
        #             if (!([string]::IsNullOrEmpty($pack.GrafanaDashboard))) {
        #                 "Installing Grafana dashboard for $($pack.PackName)"
        #                 $temppath=$pack.GrafanaDashboard
        #                 if (get-item $temppath -ErrorAction SilentlyContinue) {
        #                     "Importing $($pack.GrafanaDashboard) dashboard."
        #                     az grafana dashboard import -g $solutionResourceGroup -n "MonstarPacks" --definition $temppath
        #                 }
        #                 else {
        #                     "Dashboard $($pack.GrafanaDashboard) not found."
        #                 }
        #             }
        #         }
        #     }
        # }
        # else {
        #     "Deployment failed for pack $($pack.PackName). Skipping Grafana dashboard deployment, if exists."
        # }
#endregion
    }
    else {
        Write-Error "No packs found in $packsFilePath or no servers identified. Please correct the error and try again."
        return
    }
}
else {
    Write-Host "Skipping Packs setup."
}
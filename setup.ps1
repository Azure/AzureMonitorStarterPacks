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
        .\setup.ps1 -resourceGroup "myResourceGroup"

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
    # specify the subscription ID where the solution will be deployed
    [Parameter()]
    [string]
    $subscriptionId,
    # specify to use the same Action Group for all packs, otherwise a new Action Group will be created for each pack
    [Parameter()]
    [switch]
    $useSameAGforAllPacks,
    # specify the location of the packs.json file
    [Parameter()]
    [string]
    $packsFilePath="./Packs/packs.json",
    # specify the discovery method used to identify VMs to monitor
    [Parameter()]
    [string]
    $discoveryType="tags"
)
$solutionVersion="0.1.0"
#region basic initialization
if ($null -eq (get-module Az.ResourceGraph)) {
    try {
        install-module az.resourcegraph -AllowPrerelease
        import-module az.ResourceGraph #-Force
    }
    catch {
        Write-Error "Unable to install az.resourcegraph module. Please make sure you have the proper permissions to install modules."
        return
    }
}
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
    if ((Get-AzSubscription).count -gt 1) {
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
if ($sub -eq $null) {
    Write-Error "No subscription selected. Exiting."
    return
}
#Creates the resource group if it does not exist.
if (!(Get-AzResourceGroup -name $solutionResourceGroup -ErrorAction SilentlyContinue)) {
    try {
        New-AzResourceGroup -Name $solutionResourceGroup -Location $location
    }
    catch {
        Write-Error "Unable to create resource group $solutionResourceGroup. Please make sure you have the proper permissions to create a resource group in the $location location."
        return
    }
}
if ( [string]::IsNullOrEmpty($workspaceResourceId)) {
    $ws=select-workspace -location $location -resourceGroup $solutionResourceGroup -solutionTag $EnableTagName
}
else { 
    $ws=Get-AzOperationalInsightsWorkspace -Name $workspaceResourceId.split('/')[8] -ResourceGroupName $workspaceResourceId.split('/')[4] -ErrorAction SilentlyContinue
    if ($null -eq $ws) {
        Write-Error "Workspace $($workspaceResourceId.split('/')[8]) not found. "
        return
    }
}
$wsfriendlyname=$ws.Name
#endregion
#region AMA policy setup
if (!$skipAMAPolicySetup) {
    Write-Host "Enabling custom policy initiative to enable automatic AMA deployment. The policy only applies to the subscription where the packs are deployed."

    $parameters=@{
        solutionTag=$solutionTag
    }
    Write-Host "Deploying the AMA policy initiative to the current subscription."
    New-AzResourceGroupDeployment -name "amapolicy$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $solutionResourceGroup `
    -TemplateFile './amapolicies.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null 
}
else {
    Write-Host "Skipping AMA policy check and configuration, as requested."
}
#endregion
#region Main solution setup - Discovery
# Setup Workbook, function, logic app  for Tag Discovery
if (!($skipMainSolutionSetup)) {

    # generate random storage account name
    $randomstoragechars = -join ((97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })

    # zip the Function App's code
    compress-archive ./Discovery/Function/code/* ./Discovery/setup/discovery.zip -Force
    $existingSAs=Get-AzStorageAccount -ResourceGroupName $solutionResourceGroup -ErrorAction SilentlyContinue
    if ($existingSAs) {
        if ($existingSAs.count -gt 1) {
            $storageaccountName=(create-list -objectList $existingSAs -type "StorageAccount" -fieldName1 "StorageAccountName" -fieldName2 "ResourceGroupName").StorageAccountName
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
    $parameters=@{
        functionname="MonitorStarterPacks-$($sub.id.split("-")[0])"
        location=$location
        storageAccountName=$storageAccountName
        lawresourceid=$ws.ResourceId
        appInsightsLocation=$location
        solutionTag=$solutionTag
        solutionVersion=$solutionVersion
    }

    Write-Host "Deploying the discovery function, logic app and workbook."
    New-AzResourceGroupDeployment -name "functiondeployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $solutionResourceGroup `
    -TemplateFile './Discovery/setup/discovery.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null #-Verbose
}
#endregion

# Reads the packs.json file
#region discovery - depending on the discovery type, it will find the servers to deploy the packs to.
# tags - uses AppList tag to find servers then further on with tag values to find workloads. 
# auto - uses the discovery function and looks for discovery info into log analytics tables (applications and roles)
#$foundServers=$false
#region PLACEHOLDER - Use LAW discovery to find potential targets for the packs.
# if ($discoveryType -eq 'auto') {
#     # Discovery Loop - Adds discovered servers to the packs object
#     Write-Host "Starting automatic discovery using $wsfriendlyname workspace." -ForegroundColor Green
#     "Currently disabled."
#     foreach ($pack in $packs)
#     {
#         switch ($pack.DiscoveryType) {
#             'RoleName' {
#                 Write-Host "Looking for servers with $($pack.RoleName) role."
#                 $ARGQuery="AzMonStarPacks_CL | parse RawData with Time ' ' Name ',' DisplayName ',' RoleType ',' Depth | extend Computer=tostring(split(_ResourceId,'/')[8]) | where RoleType == 'Role' and Name == '$($pack.RoleName)' | summarize by Computer, Id=_ResourceId"
#                 #$ServerList=Search-azgraph -Query $ARGQuery -UseTenantScope
#                 $ServerList=(Invoke-AzOperationalInsightsQuery -query $ARGQuery -Workspace $ws).Results.Id
#                 #$ServerList.Results
#                 if ($ServerList.Count -eq 0) {
#                     Write-Error "No servers found with the $($pack.RoleName) role."
#                 }
#                 else {
#                     $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
#                     $foundServers=$true
#                     Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
#                     $ServerList | ForEach-Object {Write-Output $_.split('/')[8]}
#                 }
#             }
#             'Application' {
#                 Write-Host "Looking for servers with $($pack.ApplicationNames) application names."
#                 $applist=''
#                 $pack.ApplicationNames|ForEach-Object {
#                         $applist+=$("'$_',")
#                     $applist=$applist.TrimEnd(',')
#                 }
#                 $Query=@"
#     let applicationNames = dynamic( [$applist]);
#     AzMonStarPacksInventory_CL 
#     | parse RawData with Time ' ' Name ',' Publisher ',' DisplayName | extend Computer=tostring(split(_ResourceId,'/')[8]) 
#     | where DisplayName in (applicationNames)
#     | summarize by Computer, Id=_ResourceId
# "@
#                 #$ServerList=Search-azgraph -Query $ARGQuery -UseTenantScope
#                 $ServerList=(Invoke-AzOperationalInsightsQuery -query $Query -Workspace $ws).Results.Id
#                 #$ServerList.Results
#                 if ($ServerList.Count -eq 0) {
#                     Write-Error "No servers found with the $($pack.ApplicationNames) application."
#                 }
#                 else {
#                     $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
#                     $foundServers=$true
#                     Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
#                     $ServerList | ForEach-Object {Write-Output $_.split('/')[8]}
#                 }
#             }
#             'OS' {
#                 Write-Host "Looking for servers with $($pack.osTarget) OS."
#                 $Query=@"
#             resources
#             | where subscriptionId == '$subscriptionId'
# | where type =~ 'microsoft.compute/virtualmachines' | where tolower(properties.storageProfile.osDisk.osType) =~ '$($pack.osTarget)' | project id, name
# | union (resources |  where type=~'Microsoft.HybridCompute/machines' and tolower(properties.osType) == tolower('$($pack.osTarget)') | project id,name)
# "@
#                 $ServerList=Search-azgraph -Query $Query
#                 if ($ServerList.Count -eq 0) {
#                     Write-Error "No servers found with the $($pack.osTarget) OS."
#                 }
#                 else {
#                     $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value ($ServerList).id
#                     $foundServers=$true
#                     Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
#                     $ServerList | ForEach-Object {Write-Output $_.name}
#                 }

#             }
#             'Default' { "Unknown discovery type."}
#         }
#     }
#p}
#end region
#region tags based discovery
# elseif ($discoveryType -eq 'tags') {
#     Write-Host "Use provided workbook to assign Servers to specific Packs." -ForegroundColor Cyan
#     # # # gets all tagged servers
#     # $allTaggedServersList=get-taggedServers -tagName $EnableTagName
#     # "Found $($allTaggedServersList.Count) servers tagged with $Monstar."
#     # if ($allTaggedServersList.Count -eq 0) {
#     #     Write-Error "No servers found with the $EnableTagName tag. Please tag the servers you want to monitor with the $EnableTagName tag."
#     #     return
#     # }
#     # else {
#         # Write-Host "Starting tag discovery."
#         # foreach ($pack in $packs)
#         # {
#         #     $ServerList=@()
#         #     Write-Output "Looking for $($pack.RequiredTag) tag."
#         #     $allTaggedServersList | ForEach-Object {
#         #         if ($pack.RequiredTag -in ($_.$EnableTagName.split(',')) -or $pack.DiscoveryType -eq 'OS')
#         #         {
#         #             $ServerList+=$_.ResourceId
#         #         }
#         #     }
#         #     if ($ServerList.Count -eq 0) {
#         #         Write-Error "No servers found with the $($pack.RoleName) role."
#         #     }
#         #     else {
#         #         $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
#         #         $foundServers=$true
#         #         Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack: $($pack.ServerList)"
#         #     }
#         # }
#     #}
# }
#read packs file looking for discovery options (roles, applications, OS, etc.)
# if discovery options are present, use LAW to find potential targets
# if no discovery options are present, use the tag to find potential targets

#endregion

# # This function will loop through all servers and install AMA if it is not installed, as well as associating the VMInsights DCR.
# # It will check for the VMInsights DCR and create it if it does not exist.
# install-amaAndDCR -serverList $allTaggedServersList `
#     -wsfriendlyname $wsfriendlyname `
#     -ws $ws `
#     -location $location `
#     -resourceGroup $solutionResourceGroup `
#     -useExistingDCR:$useExistingDCR.IsPresent `
#     -DontAutoInstallAMA:$DontautoInstallAMA.IsPresent


# If the usesameAGforAllPacks switch is used, we will ask for the AG information only once.
#if ($packs.count -gt 0 -and $foundServers -eq $true) {
if (!($skipPacksSetup)) {
    Write-Host "Found the following ENABLED packs in packs.json config file:"
    $packs=Get-Content -Path $packsFilePath | ConvertFrom-Json| Where-Object {$_.Status -eq 'Enabled'}
    $packs | ForEach-Object {Write-Host "$($_.PackName) - $($_.Status)"}

    # deploy packs if any are enabled
    if ($packs.count -gt 0) {
        if ($useSameAGforAllPacks) {
            Write-host "'useSameAGforAllPacks' flag detected. Please provide AG information to be used to all Packs, either new or existing (depending on useExistingAG switch)"
            if ([string]::IsNullOrEmpty($existingAGName)) {
                $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
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
            -resourceGroup $solutionResourceGroup `
            -AGInfo $AGinfo `
            -useExistingAG:$useExistingAG.IsPresent `
            -existingAGName $actionGroupName `
            -useSameAGforAllPacks:$useSameAGforAllPacks.IsPresent `
            -workspaceResourceId $ws.ResourceId `
            -discoveryType $discoveryType `
            -solutionTag $solutionTag `
            -solutionVersion $solutionVersion
    }
    else {
        Write-Error "No packs found in $packsFilePath or no servers identified. Please correct the error and try again."
        return
    }
}
else {
    Write-Host "Skipping Packs setup."
}
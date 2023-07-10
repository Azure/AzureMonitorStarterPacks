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
    [Parameter(Mandatory=$false)]
    [string]
    $workspaceResourceId,
    [Parameter(Mandatory=$true)]
    [string]
    $resourceGroup, # Monitor components resource Group. This is where DCRs and Log Analytics Workspace will be created.
    [Parameter()]
    [string]
    $EnableTagName='MonitorStarterPacks', #Tag that will be used to enable/disable monitoring. Values should be one of the workload tags.
    [Parameter(Mandatory=$true)]
    [string]
    $location,
    [Parameter()]
    [switch]
    $useExistingAG,
    [Parameter()]
    [string]
    $actionGroupName, #if exising AG is used, this is the name of the AG
    [Parameter()]
    [string[]]
    $emailreceivers=@(), 
    [Parameter()]
    [string[]]
    $emailreceiversEmails=@(),
    # [Parameter()]
    # [switch]
    # $DontautoInstallAMA,
    [Parameter()]
    [switch]
    $skipAMAPolicySetup,
    [Parameter()]
    [switch]
    $skipMainSolutionSetup,
    [Parameter()]
    [switch]
    $useExistingDCR=$false,
    [Parameter()]
    [string]
    $subscriptionId,
    [Parameter()]
    [switch]
    $useSameAGforAllPacks,
    [Parameter()]
    [string]
    $packsFilePath="./Packs/packs.json",
    [Parameter()]
    [string]
    $discoveryType="tags"
)
# Import the AzMPacks-Common module
# This module contains functions that are used by the script.

# How am I looking for the applist - fixed
# reverse the installama switch behaviour - fixed
# usesameag flag logic is buggy - fixed
# remove inventory from workbook

# test for az.resourcegraph module - fixed
#   - install/import if not present
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
    Select-AzSubscription -SubscriptionId $subscriptionId
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
}
#Creates the resource group if it does not exist.
if (!(Get-AzResourceGroup -name $resourceGroup -ErrorAction SilentlyContinue)) {
    try {
        New-AzResourceGroup -Name $resourceGroup -Location $location
    }
    catch {
        Write-Error "Unable to create resource group $resourceGroup. Please make sure you have the proper permissions to create a resource group in the $location location."
        return
    }
}
if ( [string]::IsNullOrEmpty($workspaceResourceId)) {
    $ws=select-workspace -location $location -resourceGroup $resourceGroup
}
else { 
    $ws=Get-AzOperationalInsightsWorkspace -Name $workspaceResourceId.split('/')[8] -ResourceGroupName $workspaceResourceId.split('/')[4] -ErrorAction SilentlyContinue
    if ($null -eq $ws) {
        Write-Error "Workspace $($workspaceResourceId.split('/')[8]) not found. "
        return
    }
}
$wsfriendlyname=$ws.ResourceId.split('/')[8]
#endregion
#region AMA policy setup
# This part should:
#   - check if the policy is assigned to the subscription (s)
#   - ask where to assign the policy (management group, subscription, resource group)
if (!$skipAMAPolicySetup) {
    "Disabled for now."
    # Check if the policy is assigned to the subscription
    # needs adjust to use AMA policies and to not depend on the defender policy.
    # $policyassignments=get-defenderAMApolicyAssignments -subscriptionId $sub.Id
    # if ($policyassignments.count -eq 0) {
    #     Write-Host "No Defender policy assignment found for subscription $($sub.Id). Please select a scope to enable the policies."
    #     Write-Host "Setup will install a custom policy to enable automatic AMA deployment"
    #     assign-amapolicy -ws $ws -location $location
    # }
    # else {
    #     Write-Host "Found $($policyassignments.count) policy assignments."
    #     $policyassignments.properties | select-object -Property DisplayName, Scope, PolicyDefinitionId, Description
    #     $option=read-host -Prompt "Assign the policy to a new scope? [Y]es or [N]o"
    #     if ($option -eq 'Y') {
    #         assign-amapolicy -ws $ws -location $location
    #     } 
    #     else {
    #         Write-Host "Skipping policy assignment."
    #     }
    # }
}
else {
    "Skipping AMA policy check and configuration, as requested."
}
#endregion
#region Main solution setup - Discovery
# Setup Workbook, function, logic app  for Tag Discovery
if (!($skipMainSolutionSetup)) {
    $randomstoragechars = -join ((97..122) | Get-Random -Count 4 | ForEach-Object { [char]$_ })
    compress-archive ./Discovery/Function/code/* ./Discovery/setup/discovery.zip -Force
    $storageaccountName = "azmonstarpacks$randomstoragechars"
    $parameters=@{
        functionname='MonitorStarterPacksDiscovery'
        location=$location
        storageAccountName=$storageAccountName
        lawresourceid=$ws.ResourceId
        appInsightsLocation=$location
        solutionTag=$EnableTagName
    }
    Write-Host "Deploying the discovery function, logic app and workbook."
    New-AzResourceGroupDeployment -name "functiondeployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $resourceGroup `
    -TemplateFile './Discovery/setup/discovery.bicep' -templateParameterObject $parameters -ErrorAction Stop  | Out-Null #-Verbose
}
#endregion

# Reads the packs.json file
# $ws=Get-AzOperationalInsightsworkspace | Where-Object {$_.Name -eq $logAnalyticsWorkspaceName}
Write-Host "Found the following ENABLED packs:"
$packs=Get-Content -Path $packsFilePath | ConvertFrom-Json| Where-Object {$_.Status -eq 'Enabled'}
$packs | ForEach-Object {Write-Host "$($_.PackName) - $($_.Status)"}
#region discovery - depending on the discovery type, it will find the servers to deploy the packs to.
# tags - uses AppList tag to find servers then further on with tag values to find workloads. 
# auto - uses the discovery function and looks for discovery info into log analytics tables (applications and roles)
#$foundServers=$false
#region PLACEHOLDER - Use LAW discovery to find potential targets for the packs.
if ($discoveryType -eq 'auto') {
    # Discovery Loop - Adds discovered servers to the packs object
    Write-Host "Starting automatic discovery using $wsfriendlyname workspace." -ForegroundColor Green
    foreach ($pack in $packs)
    {
        switch ($pack.DiscoveryType) {
            'RoleName' {
                Write-Host "Looking for servers with $($pack.RoleName) role."
                $ARGQuery="AzMonStarPacks_CL | parse RawData with Time ' ' Name ',' DisplayName ',' RoleType ',' Depth | extend Computer=tostring(split(_ResourceId,'/')[8]) | where RoleType == 'Role' and Name == '$($pack.RoleName)' | summarize by Computer, Id=_ResourceId"
                #$ServerList=Search-azgraph -Query $ARGQuery -UseTenantScope
                $ServerList=(Invoke-AzOperationalInsightsQuery -query $ARGQuery -Workspace $ws).Results.Id
                #$ServerList.Results
                if ($ServerList.Count -eq 0) {
                    Write-Error "No servers found with the $($pack.RoleName) role."
                }
                else {
                    $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
                    $foundServers=$true
                    Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
                    $ServerList | ForEach-Object {Write-Output $_.split('/')[8]}
                }
            }
            'Application' {
                Write-Host "Looking for servers with $($pack.ApplicationNames) application names."
                $applist=''
                $pack.ApplicationNames|ForEach-Object {
                        $applist+=$("'$_',")
                    $applist=$applist.TrimEnd(',')
                }
                $Query=@"
    let applicationNames = dynamic( [$applist]);
    AzMonStarPacksInventory_CL 
    | parse RawData with Time ' ' Name ',' Publisher ',' DisplayName | extend Computer=tostring(split(_ResourceId,'/')[8]) 
    | where DisplayName in (applicationNames)
    | summarize by Computer, Id=_ResourceId
"@
                #$ServerList=Search-azgraph -Query $ARGQuery -UseTenantScope
                $ServerList=(Invoke-AzOperationalInsightsQuery -query $Query -Workspace $ws).Results.Id
                #$ServerList.Results
                if ($ServerList.Count -eq 0) {
                    Write-Error "No servers found with the $($pack.ApplicationNames) application."
                }
                else {
                    $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
                    $foundServers=$true
                    Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
                    $ServerList | ForEach-Object {Write-Output $_.split('/')[8]}
                }
            }
            'OS' {
                Write-Host "Looking for servers with $($pack.osTarget) OS."
                $Query=@"
            resources
            | where subscriptionId == '$subscriptionId'
| where type =~ 'microsoft.compute/virtualmachines' | where tolower(properties.storageProfile.osDisk.osType) =~ '$($pack.osTarget)' | project id, name
| union (resources |  where type=~'Microsoft.HybridCompute/machines' and tolower(properties.osType) == tolower('$($pack.osTarget)') | project id,name)
"@
                $ServerList=Search-azgraph -Query $Query
                if ($ServerList.Count -eq 0) {
                    Write-Error "No servers found with the $($pack.osTarget) OS."
                }
                else {
                    $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value ($ServerList).id
                    $foundServers=$true
                    Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack:"
                    $ServerList | ForEach-Object {Write-Output $_.name}
                }

            }
            'Default' { "Unknown discovery type."}
        }
    }
}
#end region
#region tags based discovery
elseif ($discoveryType -eq 'tags') {
    Write-Host "Use provided workbook to assign Servers to specific Packs." -ForegroundColor Cyan
    # # # gets all tagged servers
    # $allTaggedServersList=get-taggedServers -tagName $EnableTagName
    # "Found $($allTaggedServersList.Count) servers tagged with $Monstar."
    # if ($allTaggedServersList.Count -eq 0) {
    #     Write-Error "No servers found with the $EnableTagName tag. Please tag the servers you want to monitor with the $EnableTagName tag."
    #     return
    # }
    # else {
        # Write-Host "Starting tag discovery."
        # foreach ($pack in $packs)
        # {
        #     $ServerList=@()
        #     Write-Output "Looking for $($pack.RequiredTag) tag."
        #     $allTaggedServersList | ForEach-Object {
        #         if ($pack.RequiredTag -in ($_.$EnableTagName.split(',')) -or $pack.DiscoveryType -eq 'OS')
        #         {
        #             $ServerList+=$_.ResourceId
        #         }
        #     }
        #     if ($ServerList.Count -eq 0) {
        #         Write-Error "No servers found with the $($pack.RoleName) role."
        #     }
        #     else {
        #         $pack | Add-Member -MemberType NoteProperty -Name ServerList -Value $ServerList
        #         $foundServers=$true
        #         Write-Output "Found $($ServerList.Count) servers for $($pack.PackName) pack: $($pack.ServerList)"
        #     }
        # }
    #}
}
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
#     -resourceGroup $resourceGroup `
#     -useExistingDCR:$useExistingDCR.IsPresent `
#     -DontAutoInstallAMA:$DontautoInstallAMA.IsPresent


# If the usesameAGforAllPacks switch is used, we will ask for the AG information only once.
#if ($packs.count -gt 0 -and $foundServers -eq $true) {
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
                "Action Group $existingAGName not found or more than one found. Please select AG:"
                $AGinfo=get-AGInfo -useExistingAG $useExistingAG.IsPresent
            }
        }
    }
    install-packs -packinfo $packs `
        -resourceGroup $resourceGroup `
        -AGInfo $AGinfo `
        -useExistingAG:$useExistingAG.IsPresent `
        -existingAGName $actionGroupName `
        -useSameAGforAllPacks:$useSameAGforAllPacks.IsPresent `
        -workspaceResourceId $ws.ResourceId `
        -discoveryType $discoveryType `
        -solutionTag $EnableTagName
}
else {
    Write-Error "No packs found in $packsFilePath or no servers identified. Please correct the error and try again."
    return
}
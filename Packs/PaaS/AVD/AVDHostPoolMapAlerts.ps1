

[Cmdletbinding()]
Param(
    [parameter(Mandatory)]
    [string]
    $Environment,

    [parameter(Mandatory)]
    [string]
    $TenantId,

    [parameter(Mandatory)]
    [string]
    $resourceGroup,

    [parameter(Mandatory)]
    [string]
    $avdLogAlertsUri,

    [parameter(Mandatory)]
    [string]
    $templateUri,

    [parameter(Mandatory)]
    [string]
    $AGId,

    [parameter(Mandatory)]
    [string]
    $alertList,
    
    [parameter(Mandatory)]
    [string]
    $location,

    [parameter(Mandatory)]
    [string]
    $moduleprefix,

    [parameter(Mandatory)]
    [string]
    $packtag,

    [parameter(Mandatory)]
    [string]
    $workspaceId,

    [parameter(Mandatory)]
    [object]
    $Tags
)

$ErrorActionPreference = 'Stop'
$WarningPreference = 'SilentlyContinue'

Install-Module -Name Az.ResourceGraph -Force
Import-Module -Name Az.ResourceGraph -Force

[object]$Tags = $Tags.Replace("'", '"')
$Tags = ConvertFrom-Json $Tags -AsHashtable

$alertList = (Invoke-WebRequest -Uri $avdLogAlertsUri).Content | ConvertFrom-Json
$query = @"
resources
| where type =~ "microsoft.desktopvirtualization/hostpools"
| extend HostPoolName = tostring(name)
| extend HostPoolRG = tostring(split(id, '/')[4])
| extend AppGroup = tostring(split(properties.applicationGroupReferences[0], '/')[8])
| extend HostPoolId = tostring(id)
| join (
    desktopvirtualizationresources
    | where type == "microsoft.desktopvirtualization/hostpools/sessionhosts"
    | extend HostPoolName = tostring(split(name, '/')[0])
    | extend SessionHosts = tostring(split(name, '/')[1])
    | extend VMResGroup = tostring(split(properties.resourceId, '/')[4])
    | extend VMResGroupId = tostring(split(properties.resourceId, '/providers')[0])
) on HostPoolName
| summarize SessionHosts = make_list(SessionHosts) by HostPoolName,VMResGroup,HostPoolRG,HostPoolId,VMResGroupId,AppGroup
"@

try {
   # Connect-AzAccount -Environment $Environment -Tenant $TenantId -Identity | Out-Null
  
    function ConvertTo-Hashtable {
        <#
    .Synopsis
        Converts an object to a hashtable
    .DESCRIPTION
        PowerShell v4 seems to have trouble casting some objects to Hashtable.
        This function is a workaround to convert PS Objects to [Hashtable]
    .LINK
        https://github.com/alainQtec/.files/blob/main/src/scripts/Converters/ConvertTo-Hashtable.ps1
    .NOTES
        Base ref: https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/turning-objects-into-hash-tables-2
    #>
        PARAM(
            # The object to convert to a hashtable
            [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
            $InputObject,

            # Forces the values to be strings and converts them by running them through Out-String
            [switch]$AsString,

            # If set, empty properties are Included
            [switch]$AllowNulls,

            # Make each hashtable to have it's own set of properties, otherwise,
            # (default) each InputObject is normalized to the properties on the first object in the pipeline
            [switch]$DontNormalize
        )
        BEGIN {
            $headers = @()
        }
        PROCESS {
            if (!$headers -or $DontNormalize) {
                $headers = $InputObject | Get-Member -type Properties | Select-Object -expand name
            }
            $OutputHash = @{}
            if ($AsString) {
                foreach ($col in $headers) {
                    if ($AllowNulls -or ($InputObject.$col -is [bool] -or ($InputObject.$col))) {
                        $OutputHash.$col = $InputObject.$col | Out-String -Width 9999 | ForEach-Object { $_.Trim() }
                    }
                }
            }
            else {
                foreach ($col in $headers) {
                    if ($AllowNulls -or ($InputObject.$col -is [bool] -or ($InputObject.$col))) {
                        $OutputHash.$col = $InputObject.$col
                    }
                }
            }
        }
        END {
            return $OutputHash
        }
    }

    $Mapping = Search-AzGraph -Query $query

    $params = @{
        'alertlist'    = $alertList
        'location'     = $location
        'workspaceId'  = $workspaceId
        'AGId'         = $AGId
        'packtag'      = $packTag
        'Tags'         = $Tags
        'moduleprefix' = $modulePrefix
    }

    Foreach ($hostPool in $Mapping) {
        $deployname = "Alerts-AVD-" + $hostpool.HostPoolName
        $hostpoolname = $hostpool.HostPoolName
        $alertListHP = $alertList

    
        #replace alert list items with xHostPoolNamex 
        $alertListHP | ForEach-Object { $_.alertRuleDescription = $_.alertRuleDescription -replace "xHostPoolNamex", $hostpoolname }
        $alertListHP | ForEach-Object { $_.alertRuleName = $_.alertRuleName -replace "xHostPoolNamex", $hostpoolname }
        $alertListHP | ForEach-Object { $_.alertRuleDisplayName = $_.alertRuleDisplayName -replace "xHostPoolNamex", $hostpoolname }
        $alertListHP | ForEach-Object { $_.query = $_.query -replace "xHostPoolNamex", $hostpoolname }
    
        #Convert each dimension within an alert and the alert to a Hashtable vs PSObject
        $i = 0
        $j = 0
        foreach ($alert in $alertListHP) {
            foreach ($dimension in $alert.dimensions) { $alert.dimensions[$j] = $alert.dimensions[$j] | ConvertTo-Hashtable; $j++ }
            $alertListHP[$i] = $alert | ConvertTo-Hashtable
            $i++
            $j = 0
        }
        $params.alertlist = $alertListHP
                     
        New-AzResourceGroupDeployment -Name $deployname -ResourceGroupName $resourceGroup -TemplateUri $templateUri -TemplateParameterObject $params
        $params.alertlist = $null
        $alertListHP = $null
    }
    $DeploymentScriptOutputs = @{}
    $DeploymentScriptOutputs['AVDHostMap'] = $Mapping
}
catch {
    throw
}
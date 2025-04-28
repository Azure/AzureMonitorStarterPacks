function new-pack {
    param (
        # Parameter help description
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the package to be created.")]
        [string]$packtag,
        #location
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the location.")]
        [string]$location,
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the instance.")]
        [string]$instanceName = $env:InstanceName,
        #resource group
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the resource group.")]
        [string]$resourceGroup = $env:ResourceGroupName,
        #dceId
        [Parameter(Mandatory=$false, HelpMessage="Enter the name of the dceId.")]
        [string]$dceId = $env:dceId,
        #workspaceId
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the workspaceId.")]
        [string]$workspaceId,
        #agId
        [Parameter(Mandatory=$true, HelpMessage="Enter the name of the agId.")]
        [string]$AGId = $env:AGId
    )
    $modulesRoot = "./modules"
    $packlist=get-content ./packs/packsdef.json | ConvertFrom-Json -Depth 15
    $packlist.Packs | Where-Object { $_.Tag -eq $packtag }
    $packlist.Packs | Where-Object { $_.Tag -eq $packtag } | ForEach-Object {
        $pack = $_
        $packName = $pack.Name
        $packTag = $pack.Tag
        $packOS = $pack.OS
        $TagsToUse=@{ # MonitorStarterPacks and instanceName are mandatory tags
            MonitorStarterPacks = $packtag
            InstanceName = $instanceName
        }
        Write-Host "Creating pack for tag: $($packTag)"
        Write-Host "Pack Name: $($packName)"
        Write-Host "Pack OS: $($packOS)"
        Write-Host "Pack Location: $($location)"
        # Create the required DCRs based on configuration
        foreach ($rule in $pack.Rules) {
            $ruleName = "AMP-$instanceName-$packtag"
            $ruleTag = $packTag
            $ruleOS = $pack.OS
            Write-Host "Creating rule for tag: $($ruleTag)"
            Write-Host "Rule Name: $($ruleName)"
            Write-Host "Rule OS: $($ruleOS)"
            # based on the rule type, create the required DCRs
            switch ($rule.RuleType) {
                'EventPerformance' {
                    # use bicep file to create the DCR. It will need to be available in the SA or repository
                    # Local test for now
                    $dcrname=$ruleOS -eq "Windows" ? "dcr-basicWinVM.bicep" : "dcr-basicLinuxVM.bicep"
                    $templateFile = "$modulesRoot/DCRs/$dcrname"
                    # test if DCR already exists
                    $dcr = Get-AzDataCollectionRule -ResourceGroupName $resourceGroup -Name $ruleName -ErrorAction SilentlyContinue
                    if ($dcr) {
                        Write-Host "DCR $($ruleName) already exists. Skipping creation."
                    }
                    else {
                        # Create the DCR using the bicep template
                        Write-Host "Creating DCR $($ruleName)..."
                        New-AzResourceGroupDeployment -name "dcr-$packtag-$instanceName-$location" `
                                                    -TemplateFile $templateFile `
                                                    -ResourceGroupName $resourceGroup `
                                                    -Location $location `
                                                    -rulename $ruleName `
                                                    -workspaceId $WorkspaceId `
                                                    -kind $rule.Kind `
                                                    -xPathQueries $rule.XPathQueries `
                                                    -Tags $TagsToUse `
                                                    -dceId $dceId
                        Write-Host "DCR $($ruleName) created successfully."
                    }
                }
            }
        }
        # Now deploy alerts based on the pack configuration
        
        if ($pack.Alerts.Count -ne 0) {
            # Convert to json and remove square brackets from the start and end of the string
            $alertlistT = $pack.Alerts# | ConvertTo-Json -Depth 15 -Compress #| Out-String | ForEach-Object { $_ -replace '\"', '"' }
            # $alertlist = $alertlist.TrimStart('["').TrimEnd('"]')
            $alertlist=ConvertPSObjectToHashtable $alertlistT
            $alertTemplateFile = "$modulesRoot/Alerts/alerts.bicep"
            $modulePrefix="AMP-$instanceName-$packtag"
            New-AzResourceGroupDeployment -name "alerts-$packtag-$instanceName-$location" `
                -TemplateFile $alertTemplateFile `
                -ResourceGroupName $resourceGroup `
                -Location $location `
                -TemplateParameterObject @{
                    alertlist = $alertlist
                    AGId = $AGId
                    moduleprefix = $modulePrefix
                    packtag = $packtag
                    Tags = $TagsToUse # Add any tags you want to pass here
                    workspaceId = $workspaceId
                    location = $location
                }
        }
        else {
            Write-Host "No alerts to create for pack $($packtag). "
        }
        # Now deploy the pack based on the pack configuration
    }
}
function ConvertPSObjectToHashtable
{
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )

    process
    {
        if ($null -eq $InputObject) { return $null }

        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string])
        {
            $collection = @(
                foreach ($object in $InputObject) { ConvertPSObjectToHashtable $object }
            )

            Write-Output -NoEnumerate $collection
        }
        elseif ($InputObject -is [psobject])
        {
            $hash = @{}

            foreach ($property in $InputObject.PSObject.Properties)
            {
                $hash[$property.Name] = (ConvertPSObjectToHashtable $property.Value).PSObject.BaseObject
            }

            $hash
        }
        else
        {
            $InputObject
        }
    }
}
new-pack -packtag "VMI" `
    -location "canadacentral" `
    -instanceName "mcp2" `
    -resourceGroup "rg-monstarpacks2" `
    -dceId "/subscriptions/e315fe54-eae5-464d-8266-0f41a0908da8/resourceGroups/rg-MonstarPacks2/providers/Microsoft.Insights/dataCollectionEndpoints/AMP-mcp2-DCE-canadacentral" `
    -workspaceId "/subscriptions/e315fe54-eae5-464d-8266-0f41a0908da8/resourcegroups/rg-monstarpacks/providers/microsoft.operationalinsights/workspaces/monster-law" `
    -AGId "/subscriptions/e315fe54-eae5-464d-8266-0f41a0908da8/resourceGroups/rg-Hub/providers/microsoft.insights/actiongroups/Jose"
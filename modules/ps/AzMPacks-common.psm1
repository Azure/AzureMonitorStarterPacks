function get-defenderAMApolicyAssignments {
    param (
        [string] $subscriptionId
    )
    #Get assignments for each sub
    if ([string]::IsNullOrEmpty($subscriptionId)) {
        
        # TODO:rewrite to use resource graph instead of iterating subscriptions  -mtb
        $subs=Get-AzSubscription
        $assignments=@()
        foreach ($sub in $subs) {
            $assignments+=$(Get-AzPolicyAssignment -Scope "/subscriptions/$($sub.id)" -ErrorAction SilentlyContinue  | Where-Object {$_.ResourceName -eq 'Custom Defender for Cloud provisioning Azure Monitor agent'})
        }
    }
    else {
        <# Action when all if and elseif conditions are false #>
        $assignments=$(Get-AzPolicyAssignment -Scope "/subscriptions/$($subscriptionId)" -ErrorAction SilentlyContinue  | Where-Object {$_.ResourceName -eq 'Custom Defender for Cloud provisioning Azure Monitor agent'})
    }
    return $assignments
}
# function assign-amapolicy {
#     param (
#         [object]
#         $ws,
#         [string]
#         $location
#     )

#         # creating lists of possible scopes for assigning the AMA deployment Policy
#         $rgs=Get-AzResourceGroup | select-object -Property @{Name='DisplayName';Expression={$_.ResourceGroupName}},@{Name='Name';Expression={$_.ResourceGroupName}},@{Name='Id';Expression={$_.ResourceId}}, @{Name='Type';Expression={'ResourceGroup'}}
#         if ($rgs.Count -gt 5) {
#             #TODO too many resource groups for what? -mtb
#             Write-Host "Too many resource groups ($($rgs.Count)). Please select a scope to enable the policies. Do you want to include Resource Groups in the list?"
#             $rgoption=read-host -Prompt "Include Resource Groups in the list? [Y]es or [N]o"
#         }
#         else {
#             $rgoption='Y'
#         }
#         #get management groups and subscriptions. Could potentially work with RGs but... not sure it's worth it.
#         $mg=Get-AzManagementGroup -ErrorAction SilentlyContinue | Select-Object -Property DisplayName,@{Name='Id';Expression={($_.Id).Split('/')[4]}}, @{Name='Type';Expression={'ManagementGroup'}}
#         $sub=Get-AzSubscription -ErrorAction SilentlyContinue | select-object @{N='DisplayName';E={$_.Name}}, Id, @{Name='Type';Expression={'Subscription'}}
#         if ($rgoption -eq 'N') {
#             $allobjs=$mg+$sub
#         }
#         else {
#             $allobjs=$mg+$sub+$rgs
#         }
#         $selection=new-list -objectlist $allobjs -type 'scope' -fieldName1 'DisplayName' -fieldName2 'Type'
#         # Select Managed Identity
#         # ask if new or existing MI
#         $mioption=read-host -Prompt "Use [N]ew or [E]xisting User Assigned Managed Identity?"
#         if ($mioption -eq 'N') {
#             "Using System Managed identity"
#         }
#         else {
#             $mi=get-azadservicePrincipal | Where-Object {$_.ServicePrincipalType -eq 'ManagedIdentity'} | Sort-Object DisplayName
#             $miselection=new-list -objectlist $mi -type 'managedIdentity' -fieldName1 'DisplayName' -fieldName2 'ApplicationId'
#         }
#         # $mi=get-azadservicePrincipal | ? {$_.ServicePrincipalType -eq 'ManagedIdentity'}
#         # $miselection=new-list -objectlist $mi -type 'managedIdentity' -fieldName1 'DisplayName' -fieldName2 'ApplicationId'
#         switch ($selection.Type) {
#             'ManagementGroup' {
#                 $scope=Get-AzManagementGroup -GroupName $selection.Id
#                 #
#                 set-defenderAMApolicy -scope "/managementgroups/$($scope.Id)" `
#                                     -workspaceResourceId $ws.ResourceId `
#                                     -MIId $miselection.AppId `
#                                     -Location $location
#             }
#             'Subscription' {
#                 $scope=Get-AzSubscription -SubscriptionId $selection.Id
#                 set-defenderAMApolicy -scope "/subscriptions/$($scope.Id)" `
#                     -workspaceResourceId $ws.ResourceId `
#                     -location $location

#             }
#             'ResourceGroup' {
#                 $scope=Get-AzResourceGroup -ResourceGroupName $selection.Name
#                 set-defenderAMApolicy -scope $scope.ResourceId `
#                 -workspaceResourceId $ws.ResourceId `
#                 -location $location
#             }
#         }
#     }
    
# function set-defenderAMApolicy {
#     param (
#         [string] $scope,
#         [string] $workspaceResourceId,
#         [string] $MIId,
#         [string] $location
#     )

#     # get defender AMA built-in policy
#     $policy=Get-AzPolicySetDefinition -Id '/providers/Microsoft.Authorization/policySetDefinitions/500ab3a2-f1bd-4a5a-8e47-3e09d9a294c3'

#     if ($policy) {
#         if ([string]::IsNullOrEmpty($MIId)) {
#             Write-Host "Using System Assigned Identity"
#             New-AzPolicyAssignment -Name 'Custom Monstar Packs provisioning Azure Monitor agent' `
#                             -DisplayName 'Custom Monstar Packs provisioning Azure Monitor agent' `
#                             -Scope $scope `
#                             -PolicySetDefinition $policy `
#                             -PolicyParameterObject @{'userWorkspaceResourceId'=$workspaceResourceId;'workspaceRegion'=$location}`
#                             -IdentityType SystemAssigned `
#                             -Location $location
#         }
#         else {
#             Write-Host "Using User Assigned Identity - $MIId"
#             New-AzPolicyAssignment -Name 'Custom Monstar Packs provisioning Azure Monitor agent' `
#             -DisplayName 'Custom Monstar Packs provisioning Azure Monitor agent' `
#             -Scope $scope `
#             -PolicySetDefinition $policy `
#             -PolicyParameterObject @{'userWorkspaceResourceId'=$workspaceResourceId;'workspaceRegion'=$location}`
#             -IdentityType UserAssigned `
#             -Location $location
#         }
#     }
#     else {
#         Write-Error "Policy not found."
#     }
# }
function get-tagValue {
    param (
        [string] $tagKey,
        [System.Object] $object
    )
    $tagString = get-tagstring($object)
    $tagslist = $tagString.split(";")
    foreach ($tag in $tagslist) {
        if ($tag.split("=")[0] -eq $tagKey) {
            return $tag.split("=")[1]
        }
    }
    return ""
}
function get-tagstring ($object) {
    if ($object.Tags.Count -eq 0 -and $object.Tag.Count -eq 0) {
        $tagstring = "None"
    }
    else {
        $tagstring = ""
        if ('Tags' -in ($object|get-member).Name) {
            $tKeys = $object.Tags | Select-Object -ExpandProperty keys
            $tValues = $object.Tags | Select-Object -ExpandProperty values
        }
        else {
            $tKeys = $object.Tag | Select-Object -ExpandProperty keys
            $tValues = $object.Tag | Select-Object -ExpandProperty values
        }
        # $tKeys = $object.tags | Select-Object -ExpandProperty keys
        # $tValues = $object.Tags | Select-Object -ExpandProperty values
        $index = 0
        if ($tKeys.Count -eq 1) {
            $tagstring = "$tKeys=$tValues"
        }
        else {
            foreach ($tkey in $tkeys) {
                $tagstring += "$tkey=$($tValues[$index]);"
                $index++
            }
        }
    }
    return $tagstring.Trim(";")
}
function select-subscription {
    $subList=Get-AzSubscription
    return new-list -objectList $subList -type "Subscription" -fieldName2 "Id"
}
function select-ag {
    param (
        [string] $moduleName
    )
    if (!([string]::IsNullOrEmpty($moduleName))) {
        Write-host "Selecting action group for $moduleName." -ForegroundColor Green
    }
    $AGList=Get-AzActionGroup
    return new-list -objectList $AGList -type "Action Group"
}
function get-newAGInformation {
    $emailreceivers=Read-Host "Enter contact name to receive alerts."
    $emailreceiversEmails = Read-Host "Enter contact email to receive alerts."
    $agsizegood=$false
    do {
        $AGName=Read-Host "Enter Action Group Name (Max 12 characters)."
        if ($AGName.Length -gt 12) {
            Write-Error "Action Group Name cannot be more than 12 characters."
        }
        else {
            <# Action when all if and elseif conditions are false #>
            $agsizegood=$true
        }
    } while ($agsizegood -eq $false)
    
    $Agifo=@{
        emailReceivers=$emailreceivers
        emailReceiversEmails=$emailreceiversEmails
        Name=$AGName
    }
    return $Agifo
}
function select-workspace {
    param (
        [string] $resourceGroup,
        [string] $location,
        [string] $solutionTag
    )
    #$wslist=Get-AzOperationalInsightsWorkspace

    $wslist=Search-AzGraph -Query "resources | where type == 'microsoft.operationalinsights/workspaces' | project name, resourceGroup, subscriptionId, id"
    $wslist.Add(@{name="Create New..."})
    
    $selection=new-list -objectList $wslist -type "Workspace" -fieldName1 "name" -fieldName2 "resourceGroup"
    if ($null -ne $selection) {
        if ($selection.name -eq "Create New...") {
            $wsName=Read-Host "Enter new Workspace name:"
            $parameters=@{
                logAnalyticsWorkspaceName=$wsName
                location=$location
                solutionTag=$solutionTag
            }
            New-AzResourceGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $resourceGroup `
                -TemplateFile "./modules/LAW/law.bicep" -templateParameterObject $parameters -ErrorAction Stop | Out-Null #-Verbose
            
            # TODO: why wait for ARG? wait for deployment instead with -AsJob? -mtb
                Write-host "Sleeping 30 seconds to allow workspace to show up in ARG."
            Start-Sleep -Seconds 30
            $wslist=Search-AzGraph -Query "resources | where type == 'microsoft.operationalinsights/workspaces' and name=='$wsName' | project name, resourceGroup, subscriptionId, id"
            if ($wslist.count -eq 1) {
                return $wslist
            }
            else {
                Write-error "Workspace not found."
                return $null
            }
            else {
                Write-error "Workspace not found."
                return $null
            }
        }
        else {
            return $selection
        }
    }
    # if ($wslist.count -gt 1)
    # {
    #     Write-Verbose "More than one WorkSpace detected."
    #     Write-output "Please select WS for deployment:"
    #     $i=1
    #     $wslist | ForEach-Object {
    #         Write-Host "$i - $($_.Name) - $($_.resourceGroup)";$i++
    #     }
    #     [int]$selection=Read-Host "Select WS number: (1 - $($i-1))"
    #     if ($selection -gt 0 -and $selection -le ($i-1))  { 
    #         $selectedWS=$wslist[$selection-1]
    #         return $selectedWS
    #     }
    #     else {
    #         Write-error "Invalid selection. ($selection)"
    #         return $null
    #     }
    # }
    # else {
    #     "No exisitng WS found."
    #     return $null
    # }
}
function select-dcr {
    $objList=Search-AzGraph -Query "resources | where type == 'microsoft.insights/datacollectionrules'" -UseTenantScope
    $selectedObj=new-list -objectList $objList -fieldName1 "name" -fieldName2 "resourceGroup" -type "Data Collection Rule"
    return $selectedObj.id
}
function new-list {
    param (
        [object] $objectList,
        [string] $type,
        [string] $fieldName1="Name",
        [string] $fieldName2="ResourceGroupName"
    )
    if ($objectList.count -gt 0)
    {
        Write-Verbose "More than one $type detected."
        Write-Host "Please select $type." -ForegroundColor Green
        Write-Host "$fieldName1 `t`t $fieldName2" -ForegroundColor Blue
        Write-Host "----------------------------------------"
        $i=1
        #$global:counter=1
        #$objectList | Select-Object @{ Name="Option";Expression={$global:counter;$global:counter++}},"$fieldName1", "$fieldName2" | Format-Table -AutoSize
        #$options
        $objectList | ForEach-Object {
             Write-Host "$i - $($_."$fieldName1") `t`t $($_."$fieldName2")";$i++
        }
        [int]$selection=Read-Host "Select $type number: (1 - $($i-1))"
        if ($selection -gt 0 -and $selection -le ($i-1))  { 
            $selectedObject=$objectList[$selection-1]
            return $selectedObject
        }
        else {
            Write-error "Invalid selection. ($selection)"
            return $null
        }
    }
    else {
        "No item found."
        return $null
    }
}
function get-amaEnabledServer {
    $amaServersquery=@'
    resources
    | where (type contains "microsoft.compute/virtualmachines/extensions" or type contains "Microsoft.HybridCompute/machines/extensions") and (name == "AzureMonitorWindowsAgent" or name == "AzureMonitorLinuxAgent")
    | extend ComputerName = split(id, "/")[8],resourceId=split(id,"/extensions")[0]
    | extend extensionType = properties.type, 
        status = properties.provisioningState,
        version = properties.typeHandlerVersion
    | where status == 'Succeeded'
    | project ComputerName, resourceId
'@

    # TODO: write search-azgraph wrapper function to handle paging -mtb
    $amaServers=Search-azgraph -Query $amaServersquery -UseTenantScope
    return $amaServers
}
function get-allServers {
    $allServersQuery=@'
        resources
        | where (type == "microsoft.compute/virtualmachines" or type == "microsoft.hybridcompute/machines")
        | project name, id, resourceGroup,type
'@

    $allServersList=Search-azgraph -Query $allServersQuery -UseTenantScope
    return $allServersList
}
function get-serverswithoutAMA {
    param (
        [System.Object] $allServersList,
        [System.Object] $amaServers
    )

    $noAMAlist=@()
    $allServersList | ForEach-Object {
        if ($_.id -notin $amaServers.resourceId)
        {
            $noAMAlist+=$_
        }
    }
    Write-Host "Found $($noAMAlist.Count) Servers without AMA installed."
    return $noAMAlist
}
# function get-taggedServers {
# param (
#     [string]$tagName
# )
# # Tag based Discovery. VMs or ARC servers containing the tag specified tag will be monitored.
# $allTaggedServersQuery=@"
#     resources
#         | where type == 'microsoft.compute/virtualmachines' and isnotempty(tags.$tagname)
#         | project name, id, type, resourceGroup, Applist=tags.$tagname, os=properties.storageProfile.osDisk.osType
#         | union (
#             resources
#             | where type == 'microsoft.hybridcompute/machines' and isnotempty(tags.$tagname)
#             | project name, id, type, resourceGroup, Applist=tags.$tagname, os=properties.osType)
#             | extend serverType=iff(type=='microsoft.compute/virtualmachines','vm','arc')
#             | where isnotnull(Applist)
# "@
#     $allTaggedServersList=Search-azgraph -Query $allTaggedServersQuery -UseTenantScope
#     return $allTaggedServersList
# }
function install-ama {
    param (
        [System.Object] $server,
        [string] $location
    )
    Write-Host "Installing AMA."
    $parameters=@{
        serverId=$server.id
        serverOS=$server.os
        serverType=$server.serverType
        location=$location
    }
    select-azsubscription -subscriptionId $($server.id).split('/')[2] | Out-Null
    New-AzResourceGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $server.resourceGroup `
        -TemplateFile "./modules/ama/ama.bicep" -templateParameterObject $parameters -ErrorAction Stop | Out-Null #-Verbose
    
    Write-Host "AMA installed."
}
function get-defaultVMI_DCR {
    param ( 
        [string] $wsfriendlyname)
    $VMInsightsdcrQuery=@"
        resources
        | where type == "microsoft.insights/datacollectionrules"
        | where name =~ 'MSVMI-$wsfriendlyname'
"@
    $defaultVMI_DCR=Search-azgraph -Query $VMInsightsdcrQuery -UseTenantScope
    return $defaultVMI_DCR.id
}
# function associate-dcr {
#     param (
#         [System.Object] $server,
#         [string] $DCRRuleId,
#         [string] $osTarget
#     )
#     if ($DCRRuleId -in (Get-AzDataCollectionRuleAssociation -TargetResourceId $server.id).DataCollectionRuleId) {
#         Write-Warning "DCR already associated. Skipping deployment"
#     }
#     else {
#         $parameters=@{
#             vmId=$server.id
#             associationName="$($server.name)-DCR-Association-$(get-date -format "ddmmyyHHmmss")"
#             dataCollectionRuleId=$DCRRuleId
#             osTarget=$osTarget
#             vmOS=$server.os
#         }

#         Write-Host "Associating DCR."
#         select-azsubscription -subscriptionId $($server.id).split('/')[2] | Out-Null
#         New-AzResourceGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $server.resourceGroup `
#             -TemplateFile "./modules/DCRs/dcrassociation.bicep" -templateParameterObject $parameters -ErrorAction Stop | Out-Null #-Verbose
#     }
# }
# function create-VMIdcr {
#     param (
#         [string] $workspaceResourceId,
#         [string] $location
#     )
#     $parameters = @{
#         workspaceResourceId = $workspaceResourceId
#         location = $location
#     }
#     $workspaceResourceGroup = $workspaceResourceId.Split('/')[4]
#     select-azsubscription -subscriptionId $($workspaceResourceId).split('/')[2] | Out-Null
#     $output=New-AzResourceGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ResourceGroupName $workspaceResourceGroup `
#     -TemplateFile "./modules/DCRs/DefaultVMI-rule.bicep" -templateParameterObject $parameters -ErrorAction Stop | Out-Null #-Verbose
#     return $output.Outputs.vmiRuleId.value
# }
function deploy-pack {
    param (
        #[object] $serverList,
        [object] $packinfo,
        [string] $workspaceResourceId,
        [bool] $useExistingAG,
        [object] $AGInfo,
        [bool] $enableBasicVMPlatformAlerts=$false,
        [string] $resourceGroupId,
        [string] $discoveryType,
        [string] $solutionTag,
        [string] $solutionVersion,
        [bool] $azAvailable,
        [string] $location,
        [string] $dceId,
        [string] $userManagedIdentityResourceId,
        [string] $assignmentlevel,
        [string] $managementGroupName,
        [string] $subscriptionId
        #,
        #[string] $osTarget # Windows, Linux or All
    )
    # if ($discoveryType -eq 'auto') {
    #     $serverListLocal = New-Object -TypeName System.Collections.Generic.List[String]
    #     $serverListLocal+=$packinfo.ServerList
    # }
    # else {
    #     $serverListLocal=$serverList
    # }
    # if ($serverListLocal.Count) {
    #     # Use Existing Action Group 
    #     #$useExistingAG=$true
        $parameters=@{
            location=$location
            rulename=$packinfo.ruleName
            workspaceId=$workspaceResourceId
            useExistingAG=$useExistingAG
            packtag=$packinfo.RequiredTag
            solutionTag=$solutionTag
            solutionVersion=$solutionVersion
            dceId=$dceId
            userManagedIdentityResourceId=$userManagedIdentityResourceId
            mgname=$managementGroupName
            #assignmentlevel=$assignmentlevel
        }
        if ($useExistingAG) {
            $parameters+=@{
                actionGroupName=$AGInfo.Name
                existingAGRG=$AGInfo.ResourceGroupName
            }
        }
        else {
            $parameters+=@{
                actionGroupName=$AGInfo.Name
                emailreceivers=@($AGInfo.emailreceivers)
                emailreiceversemails=@($AGInfo.emailreceiversEmails)
            }
        }
        #deal with custom deployment parameters. 
        #This will read the packinfo.ModuleParameters and if any is present, they will be added to the $parameters object
        if ($null -ne $packinfo.moduleParameters) {
            $packinfo.moduleParameters | ForEach-Object {
                #$parameters | Add-Member -MemberType NoteProperty -Name $_.Name -Value $_.Value
                if (!([string]::IsNullOrEmpty($_.Value))) {
                    $parameters+=@{"$($_.Name)"=$null}
                }
                else {
                    $newValue=Read-Host "Enter value for $($_.Name)"
                    $parameters+=@{"$($_.Name)"=$newValue}
                }
            }
        }
        if ($null -ne $packinfo.GrafanaDashboard) {
            "Deploying Grafana Dashboard."
        }
        if ($assignmentlevel -ne 'managementgroup') { #assignments at subscription level for policies.
            Write-Host "Deploying pack $($packinfo.PackName) in $($resourceGroup) resource group and assigning policies at subscription level."
            $parameters+=@{
                resourceGroupId=$resourceGroupId
                subscriptionId=$($resourceGroupId.split('/')[2])
                assignmentlevel='subscription'
            }
            try {
                New-AzManagementGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ManagementGroupId $managementGroupName -Location $location `
                -TemplateFile $packinfo.TemplateLocation -templateParameterObject $parameters -WarningAction SilentlyContinue -ErrorAction Stop # | out-null
                return $true
            }
            catch {
                Write-Error $_.Exception.Message
                return $false
            }
        }
        else {
            Write-Host "Deploying pack $($packinfo.PackName) at management group level (policies) in $($resourceGroup) resource group."
            $parameters+=@{
                resourceGroupId=$resourceGroupId
                subscriptionId=$($resourceGroupId.split('/')[2])
                assignmentlevel='managementGroup'
            }
            try {
                New-AzManagementGroupDeployment -Name "deployment$(get-date -format "ddmmyyHHmmss")" -ManagementGroupId $managementGroupName -Location $location `
                -TemplateFile $packinfo.TemplateLocation -templateParameterObject $parameters -WarningAction SilentlyContinue -ErrorAction Stop # | out-null
                return $true
            }
            catch {
                Write-Error $_.Exception.Message
                return $false
            }
        }
}

function install-packs {
    param (
        [object]$packinfo,
        [string]$workspaceResourceId,
        [bool]$useExistingAG,
        [string]$existingAGName="",
        [bool]$useSameAGforAllPacks,
        [object]$AGInfo,
        [string]$resourceGroupId,
        [string]$discoveryType,
        [string]$solutionTag,
        [string]$solutionVersion,
        [bool]$confirmEachPack,
        [string]$location,
        [string]$dceId,
        [bool]$azAvailable,
        [string]$userManagedIdentityResourceId,
        [string]$grafanaName,
        [string]$assignmentlevel,
        [string]$managementGroupName,
        [string]$subscriptionId
    )
    if (!($useSameAGforAllPacks)) {
        $AGinfo=get-AGInfo -useExistingAG $useExistingAG
    }
    foreach ($pack in $packinfo | Where-Object {$_.Status -eq 'Enabled'})
    {
        if ($confirmEachPack) {
            $confirm=Read-Host "Do you want to deploy pack $($pack.PackName)? (Y/N)"
            if ($confirm -ne 'Y') {
                $deployPack=$false
            }
            else {
                $deployPack=$true
            }
        }
        else {
            $deployPack=$true
        }
        if ($deployPack) {
            $status=deploy-pack -packinfo $pack `
                -workspaceResourceId $workspaceResourceId `
                -useExistingAG $useExistingAG `
                -AGInfo $AGinfo `
                -resourceGroupId $resourceGroupId `
                -discoveryType $discoveryType `
                -solutionTag $solutionTag `
                -solutionVersion $solutionVersion `
                -location $location `
                -dceId $dceId `
                -userManagedIdentityResourceId $userManagedIdentityResourceId `
                -assignmentlevel $assignmentlevel `
                -managementGroupName $managementGroupName `
                -subscriptionId $subscriptionId
            $resourceGroup=$resourceGroupId.split('/')[4]
            if (!([string]::IsNullOrEmpty($pack.GrafanaDashboard))) {
                if ($azAvailable) {
                    "Installing Grafana dashboard for $($pack.PackName)"
                    $temppath=$pack.GrafanaDashboard
                    if (get-item $temppath -ErrorAction SilentlyContinue) {
                        "Importing $($pack.GrafanaDashboard) dashboard."
                        az grafana dashboard import -g $resourceGroup -n $grafanaName --definition $temppath --overwrite true
                    }
                    else {
                        "Dashboard $($pack.GrafanaDashboard) not found."
                    }
                }
                else {
                    "Azure CLI not available. Skipping Grafana dashboard deployment."
                }
            }
        }
    }
}
function get-AGInfo {
    param (
        [bool] $useExistingAG
    )
    if ($useExistingAG) {
        $AG=select-ag
    }
    else {
        Write-host "Please provide information for the NEW alert group for all packs." -ForegroundColor Yellow
        $aginfo=get-newAGInformation
        $AG=@{
            name=$Aginfo.name
            emailReceivers=$Aginfo.emailReceivers
            emailReceiversEmails=$Aginfo.emailReceiversEmails
            resourceGroup=$resourceGroup
        }
    }
    return $AG
}

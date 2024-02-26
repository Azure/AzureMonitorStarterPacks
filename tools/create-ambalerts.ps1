param (
    # [Parameter(Mandatory=$true)]
    # [string] 
    # $alertsFileURL,
    [Parameter(Mandatory=$true)]
    [string]
    $packTag,
    [Parameter(Mandatory=$true)]
    [string]
    $packType,
    [Parameter(Mandatory=$true)]
    [string]$TagName,
    [Parameter(Mandatory=$true)]
    [string]$resourceId,
    [Parameter(Mandatory=$true)]
    [string]$actionGroupId,
    [Parameter(Mandatory=$true)]
    [string]$resourceGroupName,
    [Parameter(Mandatory=$true)]
    [string]$serviceFolder,
    [Parameter(Mandatory=$true)]
    [string]$instanceName
    # IaaS, PaaS, Platform,   
)

$resourceName=($resourceId -split '/')[8]
##############################
#Testing
################################
# $actionGroupId='/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/AMonStarterPacks/providers/Microsoft.Insights/actiongroups/VMAdmins'
$servicesBaseURL='https://raw.githubusercontent.com/Azure/azure-monitor-baseline-alerts/main/services'
$serviceFolder='/KeyVault/vaults'
$alertfile='/alerts.yaml'
$alertsFileURL="$servicesBaseURL$serviceFolder$alertfile"
# $resourceGroupName='rg-Monstarpacks'
$location='global'
$alertsFile=Invoke-WebRequest -Uri $alertsFileURL | Select-Object -ExpandProperty Content | Out-String
$alertst=ConvertFrom-Yaml $alertsFile
$alerts=ConvertTo-Yaml -JsonCompatible $alertst | ConvertFrom-Json

if ($alerts.Count -gt 1) {
  $initiativeMember='true'
}
else {
  $initiativeMember='false'
}

$i=1
if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
  Write-Host "No visible alerts found in the file"
  exit
}
foreach ($alert in ($alerts | Where-Object {$_.visible -eq $true}) ) {
  if ($alert.type -eq 'metric') {
    if ($i -eq 1) {
      $metricNamespace=$alert.Properties.metricNameSpace
    }
    $alertType=$alert.Properties.criterionType
    switch ($alertType) {
      'StaticThresholdCriterion' {
        $condition=New-AzMetricAlertRuleV2Criteria -MetricName $alert.Properties.metricName `
                                                  -MetricNamespace $alert.Properties.metricNameSpace `
                                                  -Operator $alert.Properties.operator `
                                                  -Threshold $alert.Properties.threshold `
                                                  -TimeAggregation $alert.Properties.timeAggregation
        
        $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
                                -ResourceGroupName $resourceGroupName `
                                -TargetResourceId $resourceId `
                                -Description $alert.description `
                                -Severity $alert.Properties.severity `
                                -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                -Condition $condition `
                                -AutoMitigate $alert.Properties.autoMitigate `
                                -WindowSize ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
                                -ActionGroupId $actionGroupId `
                                -Verbose
                                $tag = @{$tagName=$packtag}
                                Update-AzTag -ResourceId $newRule.Id -Tag $tag -Operation Replace

      }
      'DynamicThresholdCriterion' {
        $condition=New-AzMetricAlertRuleV2Criteria  -MetricName $alert.Properties.metricName `
                                                    -MetricNamespace $alert.Properties.metricNameSpace `
                                                    -Operator $alert.Properties.operator `
                                                    -DynamicThreshold `
                                                    -TimeAggregation $alert.Properties.timeAggregation `
                                                    -ViolationCount $alert.properties.failingPeriods.minFailingPeriodsToAlert `
                                                    -ThresholdSensitivity $alert.Properties.alertSensitivity 
                    $newRule=Add-AzMetricAlertRuleV2 -Name "AMP-$instanceName-$resourceName-$($alert.Properties.metricName )-$($alert.Properties.metricNameSpace.Replace("/","-"))" `
                                                    -ResourceGroupName $resourceGroupName `
                                                    -TargetResourceId $resourceId `
                                                    -Description $alert.description `
                                                    -Severity $alert.Properties.severity `
                                                    -Frequency ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.evaluationFrequency)) `
                                                    -Condition $condition `
                                                    -AutoMitigate $alert.Properties.autoMitigate `
                                                    -WindowSize ([System.Xml.XmlConvert]::ToTimeSpan($alert.Properties.windowSize)) `
                                                    -ActionGroupId $actionGroupId 

                   #update rule with new tags
                   $tag = @{$tagName=$packTag}
                   Update-AzTag -ResourceId $newRule.Id -Tag $tag  -Operation Replace
}
      default {
        Write-Host "Unknown criterion type"
      }
    }
  }
  #Activity Log
  if ($alert.type -eq 'ActivityLog') {
    $alert

    
    $condition1=New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -Equal Administrative -Field category
    $any1=New-AzActivityLogAlertAlertRuleLeafConditionObject -Field properties.status -Equal "$($alert.properties.status)"
    $any2=New-AzActivityLogAlertAlertRuleLeafConditionObject -Equal "$($alert.properties.operationName)" -Field operationName
    $condition2=New-AzActivityLogAlertAlertRuleAnyOfOrLeafConditionObject -AnyOf $any1,$any2
    $actiongroup=New-AzActivityLogAlertActionGroupObject -Id $actionGroupId
    New-AzActivityLogAlert -Name "AMP-$instanceName-$resourceName-$($alert.Name)" `
                          -ResourceGroupName $resourceGroupName `
                          -Description $alert.description `
                          -Scope $resourceId `
                          -Action $actiongroup `
                          -Condition @($condition1,$condition2) `
                          -Tag @{$tagName=$packTag} `
                          -Location $location

                          
  }
    
}

# if ($_.Properties.criterionType -eq 'StaticThresholdCriterion') {
#   # Create StaticThresholdCriterion alert rule



  


#     }
# if ($_.Properties.criterionType -eq 'DynamicThresholdCriterion') {
#   $packContent+=@"

#     module Alert${i}  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
#     name: '`${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
#     params: {
#     assignmentLevel: assignmentLevel
#       policyLocation: policyLocation
#       mgname: mgname
#       packTag: packTag
#       resourceType: resourceType
#       solutionTag: solutionTag
#       subscriptionId: subscriptionId
#       userManagedIdentityResourceId: userManagedIdentityResourceId
#       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
#       alertname: '$($_.Name) - $($_.Properties.metricNameSpace.split("/")[1].replace("/", "-"))'
#       alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
#       alertDescription: '$($_.description)'
#       metricNamespace: '$($_.Properties.metricNameSpace)'
#       parAlertSeverity: '$($_.Properties.severity)'
#       metricName: '$($_.Properties.metricName)'
#       operator: '$($_.Properties.operator)'
#       parEvaluationFrequency: '$($_.Properties.evaluationFrequency)'   
#       parWindowSize: '$($_.Properties.windowSize)'
#       alertSensitivity: '$($_.Properties.alertSensitivity)'
#       minFailingPeriodsToAlert: '$($_.properties.failingPeriods.minFailingPeriodsToAlert)'
#       numberOfEvaluationPeriods: '$($_.properties.failingPeriods.numberOfEvaluationPeriods)'
#       assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])${i}'
#       parAutoMitigate: '$($_.Properties.autoMitigate ? 'true' : 'false')'
#       parPolicyEffect: 'deployIfNotExists'
#       AGId: AGId
#       parAlertState: parAlertState
#       initiativeMember: $initiativeMember
#       packtype: '$packType'
#       instanceName: instanceName
#       timeAggregation: '$($_.Properties.timeAggregation)'
#     }
#   }
# "@
# }
# if ($_.type -eq 'ActivityLog') {
#   $operation=($_.Properties.operationName).split('/')[-1]
#   $resourceType=($_.Properties.operationName).replace($operation,"").trim('/')
#   $packContent+=@"
#   module Alert${i} '../../../modules/alerts/PaaS/activityLogAlert.bicep' = {
#     name: '${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
#     params: {
#         assignmentLevel: assignmentLevel
#         policyLocation: policyLocation
#         mgname: mgname
#         packTag: packTag
#         parResourceGroupName: parResourceGroupName
#         resourceType: resourceType
#         solutionTag: solutionTag
#         subscriptionId: subscriptionId
#         userManagedIdentityResourceId: userManagedIdentityResourceId
#         deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
#         alertname: '$($_.Name)'
#         alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
#         alertDescription: '$($_.description)'
#         assignmentSuffix: 'Act$($resourceType.split("/")[1])${i}'
#         AGId: AGId
#         initiativeMember: $initiativeMember
#         operationName: '$operation'
#         packtype: '$packType'
#         instanceName: instanceName
#     }
# }
# "@
# }
# $i++    
# }
# if ([string]::IsNullOrEmpty($metricNamespace)) {
#   $metricNamespace=$resourceType
# }
# $alertconfig=@"
# module $packTag '$packfolder' = {
#   name: '$($packTag)Alerts'
#   params: {
#     assignmentLevel: assignmentLevel
#     //location: location
#     mgname: mgname
#     //resourceGroupId: resourceGroupId
#     solutionTag: solutionTag
#     subscriptionId: subscriptionId
#     //actionGroupResourceId: actionGroupResourceId
#     userManagedIdentityResourceId: userManagedIdentityResourceId
#     //workspaceId: workspaceId
#     packTag: '$packTag'
#     //grafanaName: grafanaName
#     //dceId: dceId
#     //customerTags: customerTags
#     instanceName: instanceName
#     //solutionVersion: solutionVersion
#     AGId: actionGroupResourceId
#     policyLocation: location
#     parResourceGroupName: resourceGroupId
#     resourceType: '$metricNamespace'
#   }
# }
# "@

# # Adds initiative block if more than one alert is present
# if ($initiativeMember) {
#   $packContent+=@'

#   module policySet '../../../modules/policies/mg/policySetGeneric.bicep' = {
#     name: '${packTag}-PolicySet'
#     params: {
#         initiativeDescription: 'AMP-Policy Set to deploy ${resourceType} monitoring policies'
#         initiativeDisplayName: 'AMP-${resourceType} monitoring policies'
#         initiativeName: '${packTag}-PolicySet'
#         solutionTag: solutionTag
#         category: 'Monitoring'
#         version: solutionVersion
#         assignmentLevel: assignmentLevel
#         location: policyLocation
#         subscriptionId: subscriptionId
#         packtag: packTag
#         userManagedIdentityResourceId: userManagedIdentityResourceId
#         instanceName: instanceName
#         policyDefinitions: [
# '@
# foreach ($i in 1..($alerts | Where-Object {$_.visible -eq $true} ).Count) {
#   $packContent+=@"

#           {
#               policyDefinitionId: Alert$i.outputs.policyId
#           }
# "@
# }
# $packContent+=@"

#         ]
#     }
#   }
# "@
  
# }


# if (!(Test-Path -Path $pathFileFolder)) {
#   New-Item -Path $pathFileFolder -ItemType Directory 
# }
# $packContent | out-file -FilePath "$pathFileFolder/alerts.bicep" -Encoding utf8
# $alertconfig | out-file "./Packs/$packType/All$($packType)Packs.bicep" -Encoding utf8 -Append




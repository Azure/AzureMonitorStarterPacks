param (
    [Parameter(Mandatory=$true)]
    [string] 
    $alertsFileURL,
    [Parameter(Mandatory=$true)]
    [string]
    $packTag,
    [Parameter(Mandatory=$true)]
    [string]
    $packType, # IaaS, PaaS, Platform,
    # [Parameter(Mandatory=$true)]
    # [string]
    # $outputPackPath,
    [Parameter(Mandatory=$false)]
    [string]
    $subfolder # optional subfolder to store the pack at the top level under the PackType folder

)
if ([string]::IsNullOrEmpty($subfolder)) {
  $pathFileFolder="./$packType/$packTag"
  $packFolder="./$packtag/alerts.bicep"
}
else {
  $pathFileFolder="./Packs/$packType/$subfolder/$packTag"
  $packFolder="./$subfolder/$packtag/alerts.bicep"
}
#$alertsFile=Get-Content -Path $alertsFilePath | Out-String #/home/jofehse/git/azure-monitor-baseline-alerts/services/Web/sites/alerts.yaml | out-string
$alertsFile=Invoke-WebRequest -Uri $alertsFileURL | Select-Object -ExpandProperty Content | Out-String
$alertst=ConvertFrom-Yaml $alertsFile
$alerts=ConvertTo-Yaml -JsonCompatible $alertst | ConvertFrom-Json

$packContent=@"
targetScope = 'managementGroup'
param solutionTag string
param packTag string
param subscriptionId string
param mgname string
param resourceType string
param policyLocation string
param parResourceGroupName string
param assignmentLevel string
param userManagedIdentityResourceId string
param AGId string
param instanceName string

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
// param parResourceGroupTags object = {
//     environment: 'test'
// }
param parAlertState string = 'true'

"@


$i=1
if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
  Write-Host "No visible alerts found in the file"
  exit
}
$alerts | Where-Object {$_.visible -eq $true} | ForEach-Object {
if ($i -eq 1) {
  $metricNamespace=$_.Properties.metricNameSpace
}
if ($_.Properties.criterionType -eq 'StaticThresholdCriterion') {
$packContent+=@"

module Alert${i} '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '`${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: '$($_.Name) - $($_.Properties.metricNameSpace.split("/")[1].replace("/", "-"))'
      alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
      alertDescription: '$($_.description)'
      metricNamespace: '$($_.Properties.metricNameSpace)'
      parAlertSeverity: '$($_.Properties.severity)'
      metricName: '$($_.Properties.metricName)'
      operator: '$($_.Properties.operator)'
      parEvaluationFrequency: '$($_.Properties.evaluationFrequency)'   
      parWindowSize: '$($_.Properties.windowSize)'
      parThreshold: '$($_.Properties.threshold)'
      assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])${i}'
      parAutoMitigate: '$($_.Properties.autoMitigate)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: '$packType'
      instanceName: instanceName
      timeAggregation: '$($_.Properties.timeAggregation)'
    }
  }
"@        

    }
if ($_.Properties.criterionType -eq 'DynamicThresholdCriterion') {
  $packContent+=@"

    module Alert${i}  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '`${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
    params: {
    assignmentLevel: assignmentLevel
      policyLocation: policyLocation
      mgname: mgname
      packTag: packTag
      resourceType: resourceType
      solutionTag: solutionTag
      subscriptionId: subscriptionId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
      alertname: '$($_.Name) - $($_.Properties.metricNameSpace.split("/")[1].replace("/", "-"))'
      alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
      alertDescription: '$($_.description)'
      metricNamespace: '$($_.Properties.metricNameSpace)'
      parAlertSeverity: '$($_.Properties.severity)'
      metricName: '$($_.Properties.metricName)'
      operator: '$($_.Properties.operator)'
      parEvaluationFrequency: '$($_.Properties.evaluationFrequency)'   
      parWindowSize: '$($_.Properties.windowSize)'
      alertSensitivity: '$($_.Properties.alertSensitivity)'
      minFailingPeriodsToAlert: '$($_.properties.failingPeriods.minFailingPeriodsToAlert)'
      numberOfEvaluationPeriods: '$($_.properties.failingPeriods.numberOfEvaluationPeriods)'
      assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])${i}'
      parAutoMitigate: '$($_.Properties.autoMitigate)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: '$packType'
      instanceName: instanceName
      timeAggregation: '$($_.Properties.timeAggregation)'
    }
  }
"@
}
if ($_.type -eq 'ActivityLog') {
  $operation=($_.Properties.operationName).split('/')[-1]
  $resourceType=($_.Properties.operationName).replace($operation,"").trim('/')
  $packContent+=@"
  module Alert${i} '../../../modules/alerts/PaaS/activityLogAlert.bicep' = {
    name: '${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
    params: {
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        parResourceGroupName: parResourceGroupName
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
        alertname: '$($_.Name) '
        alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
        alertDescription: '$($_.description)'
        assignmentSuffix: 'Act$($resourceType.split("/")[1])${i}'
        AGId: AGId
        initiativeMember: true
        operationName: '$operation'
        packtype: '$packType'
        instanceName: instanceName
    }
}
"@
}
$i++    
}
if ([string]::IsNullOrEmpty($metricNamespace)) {
  $metricNamespace=$resourceType
}
$alertconfig=@"
module $packTag '$packfolder' = {
  name: '$($packTag)Alerts'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: '$packTag'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    //solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: '$metricNamespace'
  }
}
"@
if (!(Test-Path -Path $pathFileFolder)) {
  New-Item -Path $pathFileFolder -ItemType Directory 
}
$packContent | out-file -FilePath "$pathFileFolder/alerts.bicep" -Encoding utf8
$alertconfig | out-file "./Packs/$packType/All$($packType)Packs.bicep" -Encoding utf8 -Append




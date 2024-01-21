param (
    [Parameter(Mandatory=$true)]
    [string] 
    $alertsFilePath
)

$alertsFile=Get-Content -Path $alertsFilePath | Out-String #/home/jofehse/git/azure-monitor-baseline-alerts/services/Web/sites/alerts.yaml | out-string
$alertst=ConvertFrom-Yaml $alertsFile
$alerts=ConvertTo-Yaml -JsonCompatible $alertst | ConvertFrom-Json


@"
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
$alerts |ForEach-Object {
#$($_.Properties.criterionType)
    if ($_.Properties.criterionType -eq 'StaticThresholdCriterion') {

@"
module Alert${i} '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '`${uniqueString(deployment().name)}-$($_.name)'
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
      alertname: '$($_.Name) - $($_.Properties.metricNameSpace)'
      alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
      alertDescription: '$($_.description)'
      metricNamespace: '$($_.Properties.metricNameSpace)'
      parAlertSeverity: '$($_.Properties.severity)'
      metricName: '$($_.Properties.metricName)'
      operator: '$($_.Properties.operator)'
      parEvaluationFrequency: '$($_.Properties.evaluationFrequency)'   
      parWindowSize: '$($_.Properties.windowSize)'
      parThreshold: '$($_.Properties.threshold)'
      assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])$($_.properties.metricName.Substring(0,4))'
      parAutoMitigate: '$($_.Properties.autoMitigate)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: '$($_.Properties.timeAggregation)'
    }
  }
  
"@        

    }
    if ($_.Properties.criterionType -eq 'DynamicThresholdCriterion') {  
@"
module Alert${i}  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '`${uniqueString(deployment().name)}-$($_.Name)'
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
      alertname: '$($_.Name) - $($_.Properties.metricNameSpace).replace("/", "-")'
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
      assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])$($_.properties.metricName.Substring(0,4))'
      parAutoMitigate: '$($_.Properties.autoMitigate)'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: '$($_.Properties.timeAggregation)'
    }
  }
"@
}
$i++    
}




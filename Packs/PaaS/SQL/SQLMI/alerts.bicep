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
module Alert1 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-avg_cpu_percent'
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
      alertname: 'avg_cpu_percent - managedInstances'
      alertDisplayName: 'avg_cpu_percent - Microsoft.Sql/managedInstances'
      alertDescription: 'Average CPU percentage'
      metricNamespace: 'Microsoft.Sql/managedInstances'
      parAlertSeverity: '2'
      metricName: 'avg_cpu_percent'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '80'
      assignmentSuffix: 'MetmanagedInstances1'
      parAutoMitigate: 'False'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
  
module Alert2 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-storage_space_used_mb'
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
      alertname: 'storage_space_used_mb - managedInstances'
      alertDisplayName: 'storage_space_used_mb - Microsoft.Sql/managedInstances'
      alertDescription: 'Storage space used'
      metricNamespace: 'Microsoft.Sql/managedInstances'
      parAlertSeverity: '3'
      metricName: 'storage_space_used_mb'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '80'
      assignmentSuffix: 'MetmanagedInstances2'
      parAutoMitigate: 'False'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
  

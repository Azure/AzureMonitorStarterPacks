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
    name: '${uniqueString(deployment().name)}-BackendHealthPercentage'
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
      alertname: 'Backend Health Percentage - frontdoors'
      alertDisplayName: 'Backend Health Percentage - Microsoft.Network/frontdoors'
      alertDescription: 'The percentage of successful health probes from the HTTP/S proxy to backends'
      metricNamespace: 'Microsoft.Network/frontdoors'
      parAlertSeverity: '1'
      metricName: 'BackendHealthPercentage'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '80'
      assignmentSuffix: 'Metfrontdoors1'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert2 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RequestCount'
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
      alertname: 'Request Count - frontdoors'
      alertDisplayName: 'Request Count - Microsoft.Network/frontdoors'
      alertDescription: 'The number of client requests served by the HTTP/S proxy'
      metricNamespace: 'Microsoft.Network/frontdoors'
      parAlertSeverity: '3'
      metricName: 'RequestCount'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '10'
      assignmentSuffix: 'Metfrontdoors2'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert3 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalLatency'
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
      alertname: 'Total Latency - frontdoors'
      alertDisplayName: 'Total Latency - Microsoft.Network/frontdoors'
      alertDescription: 'The time calculated from when the client request was received by the HTTP/S proxy until the client acknowledged the last response byte from the HTTP/S proxy'
      metricNamespace: 'Microsoft.Network/frontdoors'
      parAlertSeverity: '3'
      metricName: 'TotalLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '25000'
      assignmentSuffix: 'Metfrontdoors3'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }

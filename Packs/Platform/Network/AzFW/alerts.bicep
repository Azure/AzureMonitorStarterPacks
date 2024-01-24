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

module Alert2 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-FirewallHealth'
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
      alertname: 'Firewall Health - azureFirewalls'
      alertDisplayName: 'Firewall Health - Microsoft.Network/azureFirewalls'
      alertDescription: 'Indicates the overall health of this firewall'
      metricNamespace: 'Microsoft.Network/azureFirewalls'
      parAlertSeverity: '0'
      metricName: 'FirewallHealth'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '90'
      assignmentSuffix: 'MetazureFirewalls2'
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
module Alert3 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-SNATPortUtilization'
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
      alertname: 'SNAT Port Utilization - azureFirewalls'
      alertDisplayName: 'SNAT Port Utilization - Microsoft.Network/azureFirewalls'
      alertDescription: 'Percentage of outbound SNAT ports currently in use'
      metricNamespace: 'Microsoft.Network/azureFirewalls'
      parAlertSeverity: '1'
      metricName: 'SNATPortUtilization'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '80'
      assignmentSuffix: 'MetazureFirewalls3'
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

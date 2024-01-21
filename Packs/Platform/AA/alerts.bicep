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
module Alert1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalJob'
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
      alertname: 'TotalJob - Microsoft.Automation-automationAccounts'
      alertDisplayName: 'TotalJob - Microsoft.Automation-automationAccounts'
      alertDescription: 'The total number of jobs'
      metricNamespace: 'Microsoft.Automation-automationAccounts'
      parAlertSeverity: '2'
      metricName: 'TotalJob'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetautomationAccountsTota'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
  
module Alert2 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalJob'
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
      alertname: 'TotalJob - Microsoft.Automation-automationAccounts'
      alertDisplayName: 'TotalJob - Microsoft.Automation-automationAccounts'
      alertDescription: 'The total number of jobs'
      metricNamespace: 'Microsoft.Automation-automationAccounts'
      parAlertSeverity: '3'
      metricName: 'TotalJob'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetautomationAccountsTota'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
  
module Alert3 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalUpdateDeploymentMachineRuns'
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
      alertname: 'TotalUpdateDeploymentMachineRuns - Microsoft.Automation-automationAccounts'
      alertDisplayName: 'TotalUpdateDeploymentMachineRuns - Microsoft.Automation-automationAccounts'
      alertDescription: 'Total software update deployment machine runs in a software update deployment run'
      metricNamespace: 'Microsoft.Automation-automationAccounts'
      parAlertSeverity: '2'
      metricName: 'TotalUpdateDeploymentMachineRuns'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetautomationAccountsTota'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
  
module Alert4 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalUpdateDeploymentRuns'
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
      alertname: 'TotalUpdateDeploymentRuns - Microsoft.Automation-automationAccounts'
      alertDisplayName: 'TotalUpdateDeploymentRuns - Microsoft.Automation-automationAccounts'
      alertDescription: 'Total software update deployment runs'
      metricNamespace: 'Microsoft.Automation-automationAccounts'
      parAlertSeverity: '3'
      metricName: 'TotalUpdateDeploymentRuns'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetautomationAccountsTota'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: false
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
  

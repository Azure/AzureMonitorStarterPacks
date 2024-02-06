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
param solutionVersion string

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
// param parResourceGroupTags object = {
//     environment: 'test'
// }
param parAlertState string = 'true'
  
module Alert1  '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-ApplicationGatewayTotalTime'
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
      alertname: 'Application Gateway Total Time - applicationGateways'
      alertDisplayName: 'Application Gateway Total Time - Microsoft.Network/applicationGateways'
      alertDescription: 'Time that it takes for a request to be processed and its response to be sent. This is the interval from the time when Application Gateway receives the first byte of an HTTP request to the time when the response send operation finishes. It\'s important to note that this usually includes the Application Gateway processing time, time that the request and response packets are traveling over the network and the time the backend server took to respond.'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'ApplicationGatewayTotalTime'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: '2'
      numberOfEvaluationPeriods: 2
      assignmentSuffix: 'MetapplicationGateways1'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }  
module Alert2  '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-BackendLastByteResponseTime'
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
      alertname: 'Backend Last Byte Response Time - applicationGateways'
      alertDisplayName: 'Backend Last Byte Response Time - Microsoft.Network/applicationGateways'
      alertDescription: 'Time interval between start of establishing a connection to backend server and receiving the last byte of the response body'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'BackendLastByteResponseTime'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: '2'
      numberOfEvaluationPeriods: 2
      assignmentSuffix: 'MetapplicationGateways2'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert3 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-CapacityUnits'
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
      alertname: 'Capacity Units - applicationGateways'
      alertDisplayName: 'Capacity Units - Microsoft.Network/applicationGateways'
      alertDescription: 'Capacity Units consumed'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'CapacityUnits'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '75'
      assignmentSuffix: 'MetapplicationGateways3'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert4 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ComputeUnits'
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
      alertname: 'Compute Units - applicationGateways'
      alertDisplayName: 'Compute Units - Microsoft.Network/applicationGateways'
      alertDescription: 'Compute Units consumed'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'ComputeUnits'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '75'
      assignmentSuffix: 'MetapplicationGateways4'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
module Alert5 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-CpuUtilization'
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
      alertname: 'Cpu Utilization - applicationGateways'
      alertDisplayName: 'Cpu Utilization - Microsoft.Network/applicationGateways'
      alertDescription: 'Current CPU utilization of the Application Gateway'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'CpuUtilization'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '80'
      assignmentSuffix: 'MetapplicationGateways5'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }  
module Alert6  '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-FailedRequests'
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
      alertname: 'Failed Requests - applicationGateways'
      alertDisplayName: 'Failed Requests - Microsoft.Network/applicationGateways'
      alertDescription: 'Count of failed requests that Application Gateway has served'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'FailedRequests'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: '2'
      numberOfEvaluationPeriods: 2
      assignmentSuffix: 'MetapplicationGateways6'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }  
module Alert7  '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-ResponseStatus'
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
      alertname: 'Response Status - applicationGateways'
      alertDisplayName: 'Response Status - Microsoft.Network/applicationGateways'
      alertDescription: 'Http response status returned by Application Gateway'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'ResponseStatus'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: '2'
      numberOfEvaluationPeriods: 2
      assignmentSuffix: 'MetapplicationGateways7'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert8 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-UnhealthyHostCount'
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
      alertname: 'Unhealthy Host Count - applicationGateways'
      alertDisplayName: 'Unhealthy Host Count - Microsoft.Network/applicationGateways'
      alertDescription: 'Number of unhealthy backend hosts'
      metricNamespace: 'Microsoft.Network/applicationGateways'
      parAlertSeverity: '2'
      metricName: 'UnhealthyHostCount'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '20'
      assignmentSuffix: 'MetapplicationGateways8'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
    }
  }
  module policySet '../../../../modules/policies/mg/policySetGeneric.bicep' = {
    name: '${packTag}-PolicySet'
    params: {
        initiativeDescription: 'AMP-Policy Set to deploy ${resourceType} monitoring policies'
        initiativeDisplayName: 'AMP-${resourceType} monitoring policies'
        initiativeName: '${packTag}-PolicySet'
        solutionTag: solutionTag
        category: 'Monitoring'
        version: solutionVersion
        assignmentLevel: assignmentLevel
        location: policyLocation
        subscriptionId: subscriptionId
        packtag: packTag
        userManagedIdentityResourceId: userManagedIdentityResourceId
        instanceName: instanceName
        policyDefinitions: [
            {
                policyDefinitionId: Alert1.outputs.policyId
            }
            {
              policyDefinitionId: Alert2.outputs.policyId
            }
            {
                policyDefinitionId: Alert3.outputs.policyId
            }
            {
              policyDefinitionId: Alert4.outputs.policyId
            }
            {
              policyDefinitionId: Alert5.outputs.policyId
            }
            {
              policyDefinitionId: Alert6.outputs.policyId
            }
            {
              policyDefinitionId: Alert7.outputs.policyId
            }
            {
              policyDefinitionId: Alert8.outputs.policyId
            }
        ]
    }
}

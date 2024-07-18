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

module Alert1 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-BytesInDDoS'
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
      alertname: 'Bytes In DDoS - publicIPAddresses'
      alertDisplayName: 'Bytes In DDoS - Microsoft.Network/publicIPAddresses'
      alertDescription: 'Metric Alert for Public IP Address Bytes IN DDOS'
      metricNamespace: 'Microsoft.Network/publicIPAddresses'
      parAlertSeverity: '4'
      metricName: 'bytesinddos'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '8000000'
      assignmentSuffix: 'MetpublicIPAddresses1'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Maximum'
    }
  }
module Alert2 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-IfUnderDDoSAttack'
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
      alertname: 'If Under DDoS Attack - publicIPAddresses'
      alertDisplayName: 'If Under DDoS Attack - Microsoft.Network/publicIPAddresses'
      alertDescription: 'Metric Alert for Public IP Address Under Attack'
      metricNamespace: 'Microsoft.Network/publicIPAddresses'
      parAlertSeverity: '1'
      metricName: 'ifunderddosattack'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetpublicIPAddresses2'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Maximum'
    }
  }
module Alert3 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-PacketsInDDoS'
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
      alertname: 'Packets In DDoS - publicIPAddresses'
      alertDisplayName: 'Packets In DDoS - Microsoft.Network/publicIPAddresses'
      alertDescription: 'Inbound packets DDoS'
      metricNamespace: 'Microsoft.Network/publicIPAddresses'
      parAlertSeverity: '4'
      metricName: 'PacketsInDDoS'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '40000'
      assignmentSuffix: 'MetpublicIPAddresses3'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Total'
    }
  }
module Alert4 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-VIPAvailability'
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
      alertname: 'VIP Availability - publicIPAddresses'
      alertDisplayName: 'VIP Availability - Microsoft.Network/publicIPAddresses'
      alertDescription: 'Average IP Address availability per time duration'
      metricNamespace: 'Microsoft.Network/publicIPAddresses'
      parAlertSeverity: '1'
      metricName: 'VipAvailability'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '90'
      assignmentSuffix: 'MetpublicIPAddresses4'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
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
        ]
    }
}

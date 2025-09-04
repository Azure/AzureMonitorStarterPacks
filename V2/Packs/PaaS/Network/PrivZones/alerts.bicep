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
    name: 'VnetkLinkCapacityUtilization'
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
      alertname: 'VNet Link Capacity Utilization - privateDnsZones'
      alertDisplayName: 'Virtual Network Link Capacity Utilization - Microsoft.Network/privateDnsZones'
      alertDescription: 'Percent of Virtual Network Link capacity utilized by a Private DNS zone'
      metricNamespace: 'Microsoft.Network/privateDnsZones'
      parAlertSeverity: '2'
      metricName: 'VirtualNetworkLinkCapacityUtilization'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '80'
      assignmentSuffix: 'MetprivateDnsZones1'
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
    name: '${uniqueString(deployment().name)}-QueryVolume'
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
      alertname: 'Query Volume - privateDnsZones'
      alertDisplayName: 'Query Volume - Microsoft.Network/privateDnsZones'
      alertDescription: 'Number of queries served for a Private DNS zone'
      metricNamespace: 'Microsoft.Network/privateDnsZones'
      parAlertSeverity: '4'
      metricName: 'QueryVolume'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '500'
      assignmentSuffix: 'MetprivateDnsZones2'
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
module Alert3 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RecordSetCapacityUtilization'
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
      alertname: 'Record Set Capacity Utilization - privateDnsZones'
      alertDisplayName: 'Record Set Capacity Utilization - Microsoft.Network/privateDnsZones'
      alertDescription: 'Percent of Record Set capacity utilized by a Private DNS zone'
      metricNamespace: 'Microsoft.Network/privateDnsZones'
      parAlertSeverity: '2'
      metricName: 'RecordSetCapacityUtilization'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '80'
      assignmentSuffix: 'MetprivateDnsZones3'
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
module Alert4 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: 'VnetWithRegistrationCapacityUtilization'
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
      alertname: 'VNet With Registration Capacity Util. - privateDnsZones'
      alertDisplayName: 'Virtual Network With Registration Capacity Utilization - Microsoft.Network/privateDnsZones'
      alertDescription: 'Percent of Virtual Network Link with auto-registration capacity utilized by a Private DNS zone'
      metricNamespace: 'Microsoft.Network/privateDnsZones'
      parAlertSeverity: '2'
      metricName: 'VirtualNetworkWithRegistrationCapacityUtilization'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '80'
      assignmentSuffix: 'MetprivateDnsZones4'
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

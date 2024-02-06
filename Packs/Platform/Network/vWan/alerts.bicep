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
@secure()
param instanceName string
param deploymentRoleDefinitionIds array = [
  '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
param parResourceGroupTags object = {
  environment: 'test'
}
param parAlertState string = 'true'
param location string
param workspaceId string
param solutionVersion string

param moduleprefix string = 'vWan'

// LAW based diagnostic settings alerts

// Alert list - used for log analytics alerts.
var alertlist = [
  {
      alertRuleDescription: 'Tunnel disconnect'
      alertRuleDisplayName: 'Tunnel disconnect'
      alertRuleName:'vWan-TunnelDisconnect'
      alertRuleSeverity:1
      autoMitigate: false
      evaluationFrequency: 'PT5M'
      windowSize: 'PT5M'
      alertType: 'rows'
      query: 'AzureDiagnostics | where Category == "TunnelDiagnosticLog" | where OperationName == "TunnelDisconnected"'
  }
]
// // Implements LA based alerts.
// module loganalyticsalerts '../../../../modules/alerts/alerts.bicep' = {
//   name: '${moduleprefix}-Alerts'
//   scope: resourceGroup(subscriptionId, parResourceGroupName)
//   params: {
//     alertlist: alertlist
//     AGId: AGId
//     location: location
//     moduleprefix: moduleprefix
//     packtag: packTag
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion
//     workspaceId: workspaceId
//   }
// }
// Metric alerts
module vWanPacketEgressDropCountAlert '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
  name: '${uniqueString(deployment().name)}-vWanPacketDrop'
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
      alertname: 'VPNGW_EgDropCount_Alert'
      alertDisplayName: 'VPN Gateway Egress Packet Drop Count Alert'
      alertDescription: 'VPN Gateway Egress Packet Drop Count Alert'
      metricNamespace: 'microsoft.network/vpngateways'
      parAlertSeverity: '2'
      parAlertState: parAlertState
      parAutoMitigate: 'false'
      parEvaluationFrequency: 'PT15M'
      parPolicyEffect: 'deployIfNotExists'
      parWindowSize: 'PT15M'
      minFailingPeriodsToAlert: '4'
      numberOfEvaluationPeriods: 4
      alertSensitivity: 'Medium'
      assignmentSuffix: 'ActVPNGWEDC'
      AGId: AGId
      metricName: 'TunnelEgressPacketDropCount'
      operator: 'GreaterThan'
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
      timeAggregation: 'Average'
  }
}

module vWanTunnelIngressBytes '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
  name: '${uniqueString(deployment().name)}-vWanTunnetIgBytes'
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
      alertname: 'Deploy_VPNGW_TunnelIgBytes_Alert'
      alertDisplayName: 'Metric Alert for VPN Gateway tunnel ingress bytes'
      alertDescription: 'Policy to audit/deploy Metric Alert for VPN Gateway tunnel ingress bytes'
      metricNamespace: 'microsoft.network/vpngateways'
      parAlertSeverity: '0'
      parAlertState: parAlertState
      parAutoMitigate: 'false'
      parEvaluationFrequency: 'PT5M'
      parPolicyEffect: 'deployIfNotExists'
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'ActVPTunIBytes'
      AGId: AGId
      metricName: 'tunnelingressbytes'
      operator: 'LessThan'
      initiativeMember: true
      packtype: 'Platform'
instanceName: instanceName
  }
}

module TunnelEgressBytes '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
  name: '${uniqueString(deployment().name)}-TunnelEgressBytes'
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
      alertname: 'Tunnel_Egress_Bytes_Alert'
      alertDisplayName: 'Metric Alert for VPN Gateway tunnel egress bytes'
      alertDescription: 'Metric Alert for VPN Gateway tunnel egress bytes'
      metricNamespace: 'microsoft.network/vpngateways'
      parAlertSeverity: '0'
      parAlertState: parAlertState
      parAutoMitigate: 'false'
      parEvaluationFrequency: 'PT5M'
      parPolicyEffect: 'deployIfNotExists'
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'TunEgressBytes'
      AGId: AGId
      metricName: 'tunnelegressbytes'
      operator: 'LessThan'
      initiativeMember: true
      packtype: 'Platform'
instanceName: instanceName
  }
}
module TunnelAverageBandwidthAlert '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
  name: '${uniqueString(deployment().name)}-TunnelAverageBandwidth'
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
      alertname: 'Tunnel Average Bandwidth'
      alertDisplayName: 'Tunnel Average Bandwidth'
      alertDescription: 'Metric Alert for VPN Gateway Bandwidth Utilization'
      metricNamespace: 'microsoft.network/vpngateways'
      parAlertSeverity: '0'
      parAlertState: parAlertState
      parAutoMitigate: 'false'
      parEvaluationFrequency: 'PT1M'
      parPolicyEffect: 'deployIfNotExists'
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'TunAvgBW'
      AGId: AGId
      metricName: 'tunnelaveragebandwidth'
      operator: 'LessThan'
      initiativeMember: true
      packtype: 'Platform'
instanceName: instanceName
  }
}
module BGPPeerStatus '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
  name: '${uniqueString(deployment().name)}-BGPPeerStatus'
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
      alertname: 'BGP_Peer_Status_Alert'
      alertDisplayName: 'Metric Alert for VPN Gateway BGP peer status'
      alertDescription: 'Metric Alert for VPN Gateway BGP peer status'
      metricNamespace: 'microsoft.network/vpngateways'
      parAlertSeverity: '0'
      parAlertState: parAlertState
      parAutoMitigate: 'false'
      parEvaluationFrequency: 'PT1M'
      parPolicyEffect: 'deployIfNotExists'
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'TunBpgStatus'
      AGId: AGId
      metricName: 'bgppeerstatus'
      operator: 'LessThan'
      initiativeMember: true
      packtype: 'Platform'
      instanceName: instanceName
  }
}

module policySet '../../../../modules/policies/mg/policySetGeneric.bicep' = {
  name: 'vWan-PolicySet'
  params: {
      initiativeDescription: 'Policy to deploy vWan policies'
      initiativeDisplayName: 'vWan policies'
      initiativeName: 'vWan-PolicySet'
      solutionTag: solutionTag
      category: 'Monitoring'
      version: solutionVersion
      assignmentLevel: assignmentLevel
      location: location
      subscriptionId: subscriptionId
      packtag: packTag
      userManagedIdentityResourceId: userManagedIdentityResourceId
      instanceName: instanceName
      policyDefinitions: [
          {
              policyDefinitionId: BGPPeerStatus.outputs.policyId
          }
          {
              policyDefinitionId: TunnelAverageBandwidthAlert.outputs.policyId
          }
          {
              policyDefinitionId: TunnelEgressBytes.outputs.policyId
          }
          {
              policyDefinitionId: vWanTunnelIngressBytes.outputs.policyId
          }
      ]
  }
}



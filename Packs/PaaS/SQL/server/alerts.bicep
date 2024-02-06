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
    name: '${uniqueString(deployment().name)}-connection_failed'
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
      alertname: 'connection_failed - servers'
      alertDisplayName: 'connection_failed - Microsoft.Sql/servers/databases'
      alertDescription: 'Failed Connections'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '1'
      metricName: 'connection_failed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'Metservers1'
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
  
module Alert2 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-deadlock'
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
      alertname: 'deadlock - servers'
      alertDisplayName: 'deadlock - Microsoft.Sql/servers/databases'
      alertDescription: 'Deadlocks. Not applicable to data warehouses.'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '3'
      metricName: 'deadlock'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'Metservers2'
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
    name: '${uniqueString(deployment().name)}-blocked_by_firewall'
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
      alertname: 'blocked_by_firewall - servers'
      alertDisplayName: 'blocked_by_firewall - Microsoft.Sql/servers/databases'
      alertDescription: 'Blocked by Firewall'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '2'
      metricName: 'blocked_by_firewall'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '5'
      assignmentSuffix: 'Metservers3'
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
    name: '${uniqueString(deployment().name)}-storage'
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
      alertname: 'storage - servers'
      alertDisplayName: 'storage - Microsoft.Sql/servers/databases'
      alertDescription: 'Data space used. Not applicable to data warehouses.'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '3'
      metricName: 'storage'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '934584883610'
      assignmentSuffix: 'Metservers4'
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
  
module Alert5  '../../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-connection_successful'
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
      alertname: 'connection_successful - servers'
      alertDisplayName: 'connection_successful - Microsoft.Sql/servers/databases'
      alertDescription: 'Successful Connections'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '4'
      metricName: 'connection_successful'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Low'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 5
      assignmentSuffix: 'Metservers5'
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
module Alert6 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-connection_failed_user_error'
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
      alertname: 'connection_failed_user_error - servers'
      alertDisplayName: 'connection_failed_user_error - Microsoft.Sql/servers/databases'
      alertDescription: 'Failed Connections : User Errors'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '2'
      metricName: 'connection_failed_user_error'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '10'
      assignmentSuffix: 'Metservers6'
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
  
module Alert7 '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-dtu_used'
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
      alertname: 'dtu_used - servers'
      alertDisplayName: 'dtu_used - Microsoft.Sql/servers/databases'
      alertDescription: 'DTU used. Applies to DTU-based databases.'
      metricNamespace: 'Microsoft.Sql/servers/databases'
      parAlertSeverity: '3'
      metricName: 'dtu_used'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '85'
      assignmentSuffix: 'Metservers7'
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
            {
              policyDefinitionId: Alert5.outputs.policyId
            }
            {
              policyDefinitionId: Alert6.outputs.policyId
            }
            {
              policyDefinitionId: Alert7.outputs.policyId
            }
           
        ]
    }
  }
  
  

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
module Alert1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsFailed'
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
      alertname: 'RunsFailed - Microsoft.Logic-workflows'
      alertDisplayName: 'RunsFailed - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow runs failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsRuns'
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
  
module Alert2 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionsFailed'
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
      alertname: 'ActionsFailed - Microsoft.Logic-workflows'
      alertDisplayName: 'ActionsFailed - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow actions failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionsFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsActi1'
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
  
module Alert3 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggersFailed'
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
      alertname: 'TriggersFailed - Microsoft.Logic-workflows'
      alertDisplayName: 'TriggersFailed - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow triggers failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggersFailed'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsTrig'
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
  
module Alert4 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunLatency'
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
      alertname: 'RunLatency - Microsoft.Logic-workflows'
      alertDisplayName: 'RunLatency - Microsoft.Logic-workflows'
      alertDescription: 'Latency of completed workflow runs.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '99999'
      assignmentSuffix: 'MetworkflowsRunL'
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
  
module Alert5 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunFailurePercentage'
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
      alertname: 'RunFailurePercentage - Microsoft.Logic-workflows'
      alertDisplayName: 'RunFailurePercentage - Microsoft.Logic-workflows'
      alertDescription: 'Percentage of workflow runs failed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '2'
      metricName: 'RunFailurePercentage'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT15M'   
      parWindowSize: 'PT1H'
      parThreshold: '50'
      assignmentSuffix: 'MetworkflowsRunF'
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
  
module Alert6 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsStarted'
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
      alertname: 'RunsStarted - Microsoft.Logic-workflows'
      alertDisplayName: 'RunsStarted - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow runs started.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsStarted'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsRuns4'
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
  
module Alert7 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsSucceeded'
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
      alertname: 'RunsSucceeded - Microsoft.Logic-workflows'
      alertDisplayName: 'RunsSucceeded - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow runs succeeded.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsSucceeded'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsRuns2'
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
  
module Alert8  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsCompleted'
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
      alertname: 'RunsCompleted'
      alertDisplayName: 'RunsCompleted'
      alertDescription: 'Number of workflow runs completed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsCompleted'
      operator: 'LessThan'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetworkflowsRuns3'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Count'
    }
  }
module Alert9 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionLatency'
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
      alertname: 'ActionLatency - Microsoft.Logic-workflows'
      alertDisplayName: 'ActionLatency - Microsoft.Logic-workflows'
      alertDescription: 'Latency of completed workflow actions.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '15'
      assignmentSuffix: 'MetworkflowsActi2'
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
  
module Alert10 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggerLatency'
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
      alertname: 'TriggerLatency - Microsoft.Logic-workflows'
      alertDisplayName: 'TriggerLatency - Microsoft.Logic-workflows'
      alertDescription: 'Latency of completed workflow triggers.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggerLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '15'
      assignmentSuffix: 'MetworkflowsTrig4'
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
  
module Alert11 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggerThrottledEvents'
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
      alertname: 'TriggerThrottledEvents - Microsoft.Logic-workflows'
      alertDisplayName: 'TriggerThrottledEvents - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow trigger throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TriggerThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsTrig2'
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
  
module Alert12 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionThrottledEvents'
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
      alertname: 'ActionThrottledEvents - Microsoft.Logic-workflows'
      alertDisplayName: 'ActionThrottledEvents - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow action throttled events..'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsActi3'
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
  
module Alert13 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TriggersSkipped'
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
      alertname: 'TriggersSkipped - Microsoft.Logic-workflows'
      alertDisplayName: 'TriggersSkipped - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow triggers skipped.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '2'
      metricName: 'TriggersSkipped'
      operator: 'GreaterThanOrEqual'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '5'
      assignmentSuffix: 'MetworkflowsTrig3'
      parAutoMitigate: 'false'
      parPolicyEffect: 'deployIfNotExists'
      AGId: AGId
      parAlertState: parAlertState
      initiativeMember: true
      packtype: 'PaaS'
      instanceName: instanceName
      timeAggregation: 'Count'
    }
  }
  
module Alert14 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunStartThrottledEvents'
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
      alertname: 'RunStartThrottledEvents - Microsoft.Logic-workflows'
      alertDisplayName: 'RunStartThrottledEvents - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow run start throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunStartThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT1M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsRunS6'
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
  
module Alert15 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunThrottledEvents'
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
      alertname: 'RunThrottledEvents - Microsoft.Logic-workflows'
      alertDisplayName: 'RunThrottledEvents - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow action or trigger throttled events.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunThrottledEvents'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '1'
      assignmentSuffix: 'MetworkflowsRunT'
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
  
module Alert16 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-TotalBillableExecutions'
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
      alertname: 'TotalBillableExecutions - Microsoft.Logic-workflows'
      alertDisplayName: 'TotalBillableExecutions - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow executions getting billed.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'TotalBillableExecutions'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'P1D'
      parThreshold: '20000'
      assignmentSuffix: 'MetworkflowsTota'
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
  
module Alert17 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunSuccessLatency'
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
      alertname: 'RunSuccessLatency - Microsoft.Logic-workflows'
      alertDisplayName: 'RunSuccessLatency - Microsoft.Logic/workflows'
      alertDescription: 'Latency of succeeded workflow runs.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '1'
      metricName: 'RunSuccessLatency'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '100'
      assignmentSuffix: 'MetworkflowsRunS7'
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
  
module Alert18 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ActionsSkipped'
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
      alertname: 'ActionsSkipped - Microsoft.Logic-workflows'
      alertDisplayName: 'ActionsSkipped - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow actions skipped.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'ActionsSkipped'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT1H'
      parThreshold: '10'
      assignmentSuffix: 'MetworkflowsActi4'
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
  
module Alert19 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RunsCancelled'
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
      alertname: 'RunsCancelled - Microsoft.Logic-workflows'
      alertDisplayName: 'RunsCancelled - Microsoft.Logic-workflows'
      alertDescription: 'Number of workflow runs cancelled.'
      metricNamespace: 'Microsoft.Logic/workflows'
      parAlertSeverity: '3'
      metricName: 'RunsCancelled'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetworkflowsRuns5'
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
  
  module policySet '../../../modules/policies/mg/policySetGeneric.bicep' = {
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
            {
              policyDefinitionId: Alert9.outputs.policyId
          }
          {
            policyDefinitionId: Alert10.outputs.policyId
          }
          {
              policyDefinitionId: Alert11.outputs.policyId
          }
          {
            policyDefinitionId: Alert12.outputs.policyId
          }
          {
            policyDefinitionId: Alert13.outputs.policyId
          }
          {
            policyDefinitionId: Alert14.outputs.policyId
          }
          {
            policyDefinitionId: Alert15.outputs.policyId
          }
          {
            policyDefinitionId: Alert16.outputs.policyId
          }
          {
            policyDefinitionId: Alert17.outputs.policyId
        }
        {
          policyDefinitionId: Alert18.outputs.policyId
        }
        {
            policyDefinitionId: Alert19.outputs.policyId
        }
        ]
    }
  }
  

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
    name: '${uniqueString(deployment().name)}-AverageResponseTime'
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
      alertname: 'AverageResponseTime - Microsoft.Web-sites'
      alertDisplayName: 'AverageResponseTime - Microsoft.Web-sites'
      alertDescription: 'The average time taken for the app to serve requests, in seconds. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'AverageResponseTime'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT15M'   
      parWindowSize: 'PT15M'
      parThreshold: '30'
      assignmentSuffix: 'MetsitesAver'
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
  
module Alert2 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-CpuTime'
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
      alertname: 'CpuTime - Microsoft.Web-sites'
      alertDisplayName: 'CpuTime - Microsoft.Web-sites'
      alertDescription: 'The amount of CPU consumed by the app, in seconds. For more information about this metric. Please see https://aka.ms/website-monitor-cpu-time-vs-cpu-percentage (CPU time vs CPU percentage). For WebApps only.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'CpuTime'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '120'
      assignmentSuffix: 'MetsitesCpuT'
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
    name: '${uniqueString(deployment().name)}-PrivateBytes'
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
      alertname: 'PrivateBytes - Microsoft.Web-sites'
      alertDisplayName: 'PrivateBytes - Microsoft.Web-sites'
      alertDescription: 'Private Bytes is the current size, in bytes, of memory that the app process has allocated that can`t be shared with other processes. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'PrivateBytes'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '1200000000'
      assignmentSuffix: 'MetsitesPriv'
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
  
module Alert4 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-RequestsInApplicationQueue'
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
      alertname: 'RequestsInApplicationQueue - Microsoft.Web-sites'
      alertDisplayName: 'RequestsInApplicationQueue - Microsoft.Web-sites'
      alertDescription: 'The number of requests in the application request queue. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'RequestsInApplicationQueue'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT15M'
      parThreshold: '10'
      assignmentSuffix: 'MetsitesRequ'
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
  
module Alert5 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-Connections'
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
      alertname: 'Connections - Microsoft.Web-sites'
      alertDisplayName: 'Connections - Microsoft.Web-sites'
      alertDescription: 'The number of bound sockets existing in the sandbox (w3wp.exe and its child processes). A bound socket is created by calling bind()/connect() APIs and remains until said socket is closed with CloseHandle()/closesocket(). For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'AppConnections'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT15M'
      parThreshold: '6000'
      assignmentSuffix: 'MetsitesAppC'
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
  
module Alert6 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-Http401'
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
      alertname: 'Http401 - Microsoft.Web-sites'
      alertDisplayName: 'Http401 - Microsoft.Web-sites'
      alertDescription: 'The count of requests resulting in HTTP 401 status code. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Http401'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '20'
      assignmentSuffix: 'MetsitesHttp1'
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
    name: '${uniqueString(deployment().name)}-Http404'
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
      alertname: 'Http404 - Microsoft.Web-sites'
      alertDisplayName: 'Http404 - Microsoft.Web-sites'
      alertDescription: 'The count of requests resulting in HTTP 404 status code. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'Http404'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT15M'
      parThreshold: '10'
      assignmentSuffix: 'MetsitesHttp2'
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
  
module Alert8 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-FileSystemUsage'
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
      alertname: 'FileSystemUsage - Microsoft.Web-sites'
      alertDisplayName: 'FileSystemUsage - Microsoft.Web-sites'
      alertDescription: 'Percentage of filesystem quota consumed by the app. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'FileSystemUsage'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1H'   
      parWindowSize: 'PT6H'
      parThreshold: '400000000'
      assignmentSuffix: 'MetsitesFile'
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
  
module Alert9 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-MemoryWorkingSet'
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
      alertname: 'MemoryWorkingSet - Microsoft.Web-sites'
      alertDisplayName: 'MemoryWorkingSet - Microsoft.Web-sites'
      alertDescription: 'The current amount of memory used by the app, in MiB. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'MemoryWorkingSet'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '1500000000'
      assignmentSuffix: 'MetsitesMemo'
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
    name: '${uniqueString(deployment().name)}-FunctionExecutionCount'
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
      alertname: 'FunctionExecutionCount - Microsoft.Web-sites'
      alertDisplayName: 'FunctionExecutionCount - Microsoft.Web-sites'
      alertDescription: 'Function Execution Count. For FunctionApps only.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '1'
      metricName: 'FunctionExecutionCount'
      operator: 'LessThanOrEqual'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetsitesFunc'
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
  
module Alert11 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ThreadCount'
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
      alertname: 'Thread Count - Microsoft.Web-sites'
      alertDisplayName: 'Thread Count - Microsoft.Web-sites'
      alertDescription: 'The number of threads currently active in the app process. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Threads'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '100'
      assignmentSuffix: 'MetsitesThre'
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
  
module Alert12  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-DataOut'
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
      alertname: 'Data Out'
      alertDisplayName: 'Data Out'
      alertDescription: 'The amount of outgoing bandwidth consumed by the app, in MiB. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'BytesSent'
      operator: 'GreaterOrLessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Low'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetsitesByte'
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
module Alert13 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-Http406'
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
      alertname: 'Http406 - Microsoft.Web-sites'
      alertDisplayName: 'Http406 - Microsoft.Web-sites'
      alertDescription: 'The count of requests resulting in HTTP 406 status code. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '1'
      metricName: 'Http406'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT15M'   
      parWindowSize: 'PT15M'
      parThreshold: '1'
      assignmentSuffix: 'MetsitesHttp3'
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
  
module Alert14 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-DataIn'
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
      alertname: 'Data In - Microsoft.Web-sites'
      alertDisplayName: 'Data In - Microsoft.Web-sites'
      alertDescription: 'The amount of incoming bandwidth consumed by the app, in MiB. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'BytesReceived'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '2048000000'
      assignmentSuffix: 'MetsitesByte2'
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
    name: '${uniqueString(deployment().name)}-Http3xx'
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
      alertname: 'Http3xx - Microsoft.Web-sites'
      alertDisplayName: 'Http3xx - Microsoft.Web-sites'
      alertDescription: 'The count of requests resulting in an HTTP status code >= 300 but < 400. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'Http3xx'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '15'
      assignmentSuffix: 'MetsitesHttp4'
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
  
module Alert16  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-HandleCount'
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
      alertname: 'Handle Count'
      alertDisplayName: 'Handle Count'
      alertDescription: 'The total number of handles currently open by the app process. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Handles'
      operator: 'GreaterOrLessThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Low'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetsitesHand'
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
module Alert17 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-FunctionExecutionUnits'
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
      alertname: 'FunctionExecutionUnits - Microsoft.Web-sites'
      alertDisplayName: 'FunctionExecutionUnits - Microsoft.Web-sites'
      alertDescription: 'Function Execution Units. For FunctionApps only.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'FunctionExecutionUnits'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT1M'   
      parWindowSize: 'PT5M'
      parThreshold: '13000000000'
      assignmentSuffix: 'MetsitesFunc2'
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
    name: '${uniqueString(deployment().name)}-Http2xx'
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
      alertname: 'Http2xx - Microsoft.Web-sites'
      alertDisplayName: 'Http2xx - Microsoft.Web-sites'
      alertDescription: 'The count of requests resulting in an HTTP status code >= 200 but < 300. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '3'
      metricName: 'Http2xx'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '15'
      assignmentSuffix: 'MetsitesHttp5'
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
    name: '${uniqueString(deployment().name)}-WorkflowRunsFailureRate'
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
      alertname: 'WorkflowRunsFailureRate - Microsoft.Web-sites'
      alertDisplayName: 'WorkflowRunsFailureRate - Microsoft.Web-sites'
      alertDescription: 'Workflow Runs Failure Rate. For LogicApps only.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '1'
      metricName: 'WorkflowRunsFailureRate'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      parThreshold: '0'
      assignmentSuffix: 'MetsitesWork'
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
  
module Alert20  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-Gen2GarbageCollections'
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
      alertname: 'Gen2GarbageCollections'
      alertDisplayName: 'Gen2GarbageCollections'
      alertDescription: 'The number of times the generation 2 objects are garbage collected since the start of the app process. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Gen2Collections'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetsitesGen2'
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
module Alert21  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-Gen0GarbageCollections'
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
      alertname: 'Gen0GarbageCollections'
      alertDisplayName: 'Gen0GarbageCollections'
      alertDescription: 'The number of times the generation 0 objects are garbage collected since the start of the app process. Higher generation GCs include all lower generation GCs. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Gen0Collections'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetsitesGen0'
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
module Alert22  '../../../modules/alerts/PaaS/metricAlertDynamic.bicep' = {
    name: '${uniqueString(deployment().name)}-Gen1GarbageCollections'
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
      alertname: 'Gen1GarbageCollections'
      alertDisplayName: 'Gen1GarbageCollections'
      alertDescription: 'The number of times the generation 1 objects are garbage collected since the start of the app process. Higher generation GCs include all lower generation GCs. For WebApps and FunctionApps.'
      metricNamespace: 'Microsoft.Web/sites'
      parAlertSeverity: '2'
      metricName: 'Gen1Collections'
      operator: 'GreaterThan'
      parEvaluationFrequency: 'PT5M'   
      parWindowSize: 'PT5M'
      alertSensitivity: 'Medium'
      minFailingPeriodsToAlert: 'minFailingPeriodsToAlert'
      numberOfEvaluationPeriods: 4
      assignmentSuffix: 'MetsitesGen1'
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
// module Alert23 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-HttpServerErrors'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'HttpServerErrors - Microsoft.Web-sites-slots'
//       alertDisplayName: 'HttpServerErrors - Microsoft.Web-sites-slots'
//       alertDescription: 'The count of requests resulting in an HTTP status code >= 500 but < 600. For Web and Function Apps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '1'
//       metricName: 'Http5xx'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT5M'   
//       parWindowSize: 'PT15M'
//       parThreshold: '10'
//       assignmentSuffix: 'MetsitesHttp6'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Total'
//     }
//   }
  
// module Alert24 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-ResponseTime'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'ResponseTime - Microsoft.Web-sites-slots'
//       alertDisplayName: 'ResponseTime - Microsoft.Web-sites/slots'
//       alertDescription: 'The time taken for the app to serve requests, in seconds. For WebApps and FunctionApps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '1'
//       metricName: 'HttpResponseTime'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT15M'   
//       parWindowSize: 'PT30M'
//       parThreshold: '5'
//       assignmentSuffix: 'MetsitesHttp7'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Average'
//     }
//   }
  
// module Alert25 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-Http4xx'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'Http4xx - Microsoft.Web-sites-slots'
//       alertDisplayName: 'Http4xx - Microsoft.Web/sites/slots'
//       alertDescription: 'The count of requests resulting in an HTTP status code >= 400 but < 500. For WebApps and FunctionApps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '1'
//       metricName: 'Http4xx'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT15M'   
//       parWindowSize: 'PT30M'
//       parThreshold: '5'
//       assignmentSuffix: 'MetsitesHttp8'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Average'
//     }
//   }
  
// module Alert26 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-AverageMemoryWorkingSet'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'AverageMemoryWorkingSet - Microsoft.Web-sites-slots'
//       alertDisplayName: 'AverageMemoryWorkingSet - Microsoft.Web-sites-slots'
//       alertDescription: 'The average amount of memory used by the app, in megabytes (MiB). For WebApps and FunctionApps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '3'
//       metricName: 'AverageMemoryWorkingSet'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT5M'   
//       parWindowSize: 'PT5M'
//       parThreshold: '800000000'
//       assignmentSuffix: 'MetsitesAver'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Average'
//     }
//   }
  
// module Alert27 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-Requests'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'Requests - Microsoft.Web-sites-slots'
//       alertDisplayName: 'Requests - Microsoft.Web-sites-slots'
//       alertDescription: 'The total number of requests regardless of their resulting HTTP status. For WebApps and FunctionApps. code.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '2'
//       metricName: 'Requests'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT1M'   
//       parWindowSize: 'PT5M'
//       parThreshold: '2000'
//       assignmentSuffix: 'MetsitesRequ'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Total'
//     }
//   }
  
// module Alert28 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-HealthCheckStatus'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'HealthCheckStatus - Microsoft.Web-sites-slots'
//       alertDisplayName: 'HealthCheckStatus - Microsoft.Web-sites-slots'
//       alertDescription: 'Health check status.  For WebApps and FunctionApps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '3'
//       metricName: 'HealthCheckStatus'
//       operator: 'LessThan'
//       parEvaluationFrequency: 'PT1M'   
//       parWindowSize: 'PT5M'
//       parThreshold: '100'
//       assignmentSuffix: 'MetsitesHeal'
//       parAutoMitigate: ''
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Average'
//     }
//   }
  
// module Alert29 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-Http403'
//     params: {
//     assignmentLevel: assignmentLevel
//       policyLocation: policyLocation
//       mgname: mgname
//       packTag: packTag
//       resourceType: resourceType
//       solutionTag: solutionTag
//       subscriptionId: subscriptionId
//       userManagedIdentityResourceId: userManagedIdentityResourceId
//       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//       alertname: 'Http403 - Microsoft.Web-sites-slots'
//       alertDisplayName: 'Http403 - Microsoft.Web-sites-slots'
//       alertDescription: 'The count of requests resulting in HTTP 403 status code. For WebApps and FunctionApps.'
//       metricNamespace: 'Microsoft.Web/sites/slots'
//       parAlertSeverity: '0'
//       metricName: 'Http403'
//       operator: 'GreaterThan'
//       parEvaluationFrequency: 'PT15M'   
//       parWindowSize: 'PT30M'
//       parThreshold: '5'
//       assignmentSuffix: 'MetsitesHttp9'
//       parAutoMitigate: 'false'
//       parPolicyEffect: 'deployIfNotExists'
//       AGId: AGId
//       parAlertState: parAlertState
//       initiativeMember: true
//       packtype: 'PaaS'
//       instanceName: instanceName
//       timeAggregation: 'Total'
//     }
//   }
  
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
      {
        policyDefinitionId: Alert20.outputs.policyId
      }
      {
        policyDefinitionId: Alert21.outputs.policyId
      }
      {
        policyDefinitionId: Alert22.outputs.policyId
      }
      ]
  }
}

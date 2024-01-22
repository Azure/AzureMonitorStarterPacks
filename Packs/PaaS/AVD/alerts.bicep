targetScope = 'managementGroup'
param avdLogAlertsUri string
param solutionTag string
param packtag string
param primaryScriptUri string
param subscriptionId string
param Tags object
//param mgname string
//param resourceType string
//param policyLocation string
param parResourceGroupName string
param templateUri string
//param assignmentLevel string
param userManagedIdentityResourceId string
param AGId string
//param instanceName string
param location string
param workspaceId string



module dsAVDHostPoolMapAlerts 'dsAVDHostMapping.bicep' = {
    name: 'linked_ds-AVDHostMapping-${uniqueString(deployment().name)}'
    scope: resourceGroup(subscriptionId, parResourceGroupName)
    params: {
      avdLogAlertsUri: avdLogAlertsUri
      AGId: AGId
      location: location
      solutionTag: solutionTag
      packtag: packtag
      primaryScriptUri: primaryScriptUri
      templateUri: templateUri
      workspaceId: workspaceId
      userManagedIdentityResourceId: userManagedIdentityResourceId
      Tags: Tags
    }
  }

/* module avdmetric1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-avd'
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
        alertname: 'Deploy_Storage_Availability_Alert'
        alertDisplayName: 'Deploy Storage Availability Alert'
        alertDescription: 'Deploy Storage Availability Alert'
        metricNamespace: 'Microsoft.DesktopVirtualization/hostpools'
        parAlertSeverity: '1'
        parAlertState: parAlertState
        parAutoMitigate: 'true'
        parEvaluationFrequency: 'PT15M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT15M'
        parThreshold: '50'
        assignmentSuffix: 'MetStoAvail'
        AGId: AGId
        metricName: 'Availability'
        operator: 'GreaterThanOrEqual'
        initiativeMember: false // if true, the alert won't be assigned individually.
        packtype: 'PaaS'
        instanceName: instanceName
    }
} */

output dsAVDHostPoolMapAlerts object = dsAVDHostPoolMapAlerts.outputs


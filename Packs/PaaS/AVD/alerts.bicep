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

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
// param parResourceGroupTags object = {
//     environment: 'test'
// }
param parAlertState string = 'true'

module avdmetric1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
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
        alertDisplayName: '[AMSP] Deploy Storage Availability Alert'
        alertDescription: 'AMSP Deploy Storage Availability Alert'
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
    }
}


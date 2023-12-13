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

// module KeyVaultLatencyAlert '../../../modules/alerts/PaaS/activityLogAlert.bicep' = {
//     name: '${uniqueString(deployment().name)}-PercentAvailability'
//     params: {
//         assignmentLevel: assignmentLevel
//         policyLocation: policyLocation
//         mgname: mgname
//         packTag: packTag
//         resourceType: resourceType
//         solutionTag: solutionTag
//         subscriptionId: subscriptionId
//         userManagedIdentityResourceId: userManagedIdentityResourceId
//         deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//         alertname: 'AMSP_Deploy_SA_Latency_Alert'
//         alertDisplayName: '[AMSP] Storage Account Availability Alert'
//         alertDescription: 'Metric Alert for Storage Account Availability'
//         metricNamespace: 'Microsoft.Storage/storageAccounts'
//         parAlertSeverity: '1'
//         parAlertState: parAlertState
//         parAutoMitigate: 'true'
//         parEvaluationFrequency: 'PT5M'
//         parPolicyEffect: 'deployIfNotExists'
//         parWindowSize: 'PT5M'
//         parThreshold: '90'
//         assignmentSuffix: 'AvailSA'
//         AGId: AGId
//         metricName: 'Availability'
//         operator: 'LessThan'
//         initiativeMember: false
//     }
// }


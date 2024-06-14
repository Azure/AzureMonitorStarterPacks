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

module Alert1 '../../../../modules/alerts/PaaS/activityLogAlert.bicep' = {
    name: 'ActivityLogNSGDelete'
    params: {
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        parResourceGroupName: parResourceGroupName
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
        alertname: 'Activity Log NSG Delete'
        alertDisplayName: 'Activity Log NSG Delete'
        alertDescription: 'Activity Log Alert for NSG Delete'
        assignmentSuffix: 'ActnetworkSecurityGroups1'
        AGId: AGId
        initiativeMember: false
        operationName: 'delete'
        packtype: 'PaaS'
        instanceName: instanceName
    }
}

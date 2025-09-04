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

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
param parResourceGroupTags object = {
    environment: 'test'
}
param parAlertState string = 'true'

module Alert1 '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-OAIClErrors-${instanceName}'
    params: {
        alertname: 'Alert on Client Errors over threshold'
        alertDisplayName: 'Alert on Client Errors over threshold'
        alertDescription: 'Policy to deploy Alert on Client Errors over threshold'
        metricNamespace: 'Microsoft.CognitiveServices/accounts'
        metricName: 'ClientErrors'
        operator: 'GreaterThan'
        parAlertSeverity: '3'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT15M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT15M'
        parThreshold: '20'
        assignmentSuffix: 'ActOAIClErr'
        timeAggregation: 'Total'
        AGId: AGId
        parAlertState: parAlertState
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
        initiativeMember: false
        packtype: 'PaaS'
        instanceName: instanceName
        
    }
}

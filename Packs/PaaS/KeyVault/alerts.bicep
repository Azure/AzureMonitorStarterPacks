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
param location string
param solutionVersion string
param instanceName string
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
param parResourceGroupTags object = {
    environment: 'test'
}
param parAlertState string = 'true'

module ActivityLogKeyVaultDeleteAlert '../../../modules/alerts/PaaS/activityLogAlert.bicep' = {
    name: '${uniqueString(deployment().name)}-KeyVault_Delete'
    params: {
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        parResourceGroupName: parResourceGroupName
        parResourceGroupTags: parResourceGroupTags
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
        alertname: 'Activitylog_KeyVault_Delete'
        alertDisplayName: 'Activity Log Key Vault Delete Alert'
        alertDescription: 'Activity Log Key Vault Delete Alert'
        assignmentSuffix: 'ActKVDel'
        AGId: AGId
        initiativeMember: true
        operationName: 'delete'
        packtype: 'PaaS'
        instanceName: instanceName
    }
}
module KeyVaultLatencyAlert '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-KeyVaultLatency'
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
        alertname: 'Deploy_KeyVault_Latency_Alert'
        alertDisplayName: 'Deploy KeyVault Latency Alert'
        alertDescription: 'Policy to audit/deploy KeyVault Latency Alert'
        metricNamespace: 'Microsoft.KeyVault/vaults'
        parAlertSeverity: '3'
        parAlertState: parAlertState
        parAutoMitigate: 'true'
        parEvaluationFrequency: 'PT15M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT15M'
        parThreshold: '1000'
        assignmentSuffix: 'ActKVLat'
        AGId: AGId
        metricName: 'ServiceApiLatency'
        operator: 'GreaterThan'
        initiativeMember: true
        packtype: 'PaaS'
        instanceName: instanceName
    }
}
module policySet '../../../modules/policies/mg/policySetGeneric.bicep' = {
    name: '${packTag}-PolicySet'
    params: {
        initiativeDescription: 'Policy Set to deploy Key Vault policies'
        initiativeDisplayName: 'Key Vault policies'
        initiativeName: 'KV-PolicySet'
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
                policyDefinitionId: KeyVaultLatencyAlert.outputs.policyId
            }
            {
                policyDefinitionId: ActivityLogKeyVaultDeleteAlert.outputs.policyId
            }
        ]
    }
}

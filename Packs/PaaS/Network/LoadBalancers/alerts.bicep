targetScope = 'managementGroup'
param solutionTag string
param solutionVersion string
param packTag string
param subscriptionId string
param mgname string
param resourceType string
param policyLocation string
param assignmentLevel string
param userManagedIdentityResourceId string
param AGId string
param location string
param instanceName string

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]

param parAlertState string = 'true'

module ALBDipPathAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBDipAvailabilityAlert'
    params: {
        alertname: 'Load Balancer Dip Availability'
        alertDisplayName: 'Load Balancer Dip Availability'
        alertDescription: 'policy to deploy Load Balancer Dip Availability'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        metricName: 'DipAvailability'
        operator: 'LessThan'
        parAlertSeverity: '0'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBDipAvl'
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
        initiativeMember: true
        packtype: 'PaaS'
        instanceName: instanceName
    }
}
module ALBUsedSNATPorts '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBUsedSNATPortsAlert'
    params: {
        alertname: 'Load Balancer Metric Alert for ALB Used SNAT Ports'
        alertDisplayName: 'Metric Alert for ALB Used SNAT Ports'
        alertDescription: 'Policy to deploy Metric Alert for ALB Used SNAT Ports'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        metricName: 'UsedSNATPorts'
        operator: 'GreaterThan'
        parAlertSeverity: '1'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT1M'
        parThreshold: '900'
        assignmentSuffix: 'ActUserSNAT'
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
        initiativeMember: true
        packtype: 'PaaS'
        instanceName: instanceName
    }
}
// module ALBGlobalBackendAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
//     name: '${uniqueString(deployment().name)}-ALBDGlobalBackendAvailAlert'
//     params: {
//         alertname: 'Load Balancer Global Backend Availability'
//         alertDisplayName: 'Global Backend Availability'
//         alertDescription: 'Policy to deploy Global Backend Availability alert'
//         metricNamespace: 'Microsoft.Network/loadBalancers'
//         metricName: 'GlobalBackendAvailability'
//         operator: 'GreaterThan'
//         parAlertSeverity: '0'
//         parAutoMitigate: 'false'
//         parEvaluationFrequency: 'PT1M'
//         parPolicyEffect: 'deployIfNotExists'
//         parWindowSize: 'PT1M'
//         parThreshold: '90'
//         assignmentSuffix: 'ActALBGlbBEAvl'
//         AGId: AGId
//         parAlertState: parAlertState
//         assignmentLevel: assignmentLevel
//         policyLocation: policyLocation
//         mgname: mgname
//         packTag: packTag
//         resourceType: resourceType
//         solutionTag: solutionTag
//         subscriptionId: subscriptionId
//         userManagedIdentityResourceId: userManagedIdentityResourceId
//         deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
//         initiativeMember: true
//         packtype: 'PaaS'
//         instanceName: instanceName
//     }
// }
module ALBBackendAvail '../../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
    name: '${uniqueString(deployment().name)}-ALBBackendAvailabilityAlert'
    params: {
        alertname: 'Load Balancer VIP Availability Alert'
        alertDisplayName: 'Deploy ALB VIP Availability Alert'
        alertDescription: 'Policy to deploy ALB VIP Availability Alert'
        metricNamespace: 'Microsoft.Network/loadBalancers'
        parAlertSeverity: '0'
        parAutoMitigate: 'false'
        parEvaluationFrequency: 'PT1M'
        parPolicyEffect: 'deployIfNotExists'
        parWindowSize: 'PT5M'
        parThreshold: '90'
        assignmentSuffix: 'ActALBAvl'
        metricName: 'VipAvailability'
        operator: 'LessThan'
        parAlertState: parAlertState
        AGId: AGId
        assignmentLevel: assignmentLevel
        policyLocation: policyLocation
        mgname: mgname
        packTag: packTag
        resourceType: resourceType
        solutionTag: solutionTag
        subscriptionId: subscriptionId
        userManagedIdentityResourceId: userManagedIdentityResourceId
        deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
        initiativeMember: true
        packtype: 'PaaS'
        instanceName: instanceName
    }
}
module policySet '../../../../modules/policies/mg/policySetGeneric.bicep' = {
    name: 'LB-PolicySet'
    params: {
        initiativeDescription: 'Initiative to deploy Load Balancer Alert Policies'
        initiativeDisplayName: 'Load Balancer Alerting policies'
        initiativeName: 'LB-PolicySet'
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
                policyDefinitionId: ALBDipPathAvail.outputs.policyId
            }
            {
                policyDefinitionId: ALBUsedSNATPorts.outputs.policyId
            }
            // {
            //     policyDefinitionId: ALBGlobalBackendAvail.outputs.policyId
            // }
            {
                policyDefinitionId: ALBBackendAvail.outputs.policyId
            }
        ]
    }
}

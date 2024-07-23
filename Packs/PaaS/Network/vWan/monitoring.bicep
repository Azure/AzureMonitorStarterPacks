targetScope = 'managementGroup'
param workspaceId string
param packtag string
param solutionTag string
param actionGroupResourceId string
param instanceName string

var resourceTypes = [
  'Microsoft.Network/vpngateways'
  'Microsoft.Network/expressRouteGateways'
]

param location string //= resourceGroup().location
param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
param solutionVersion string
param customerTags object 
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'PaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
// module ag '../../../../modules/actiongroups/ag.bicep' = {
//   name: actionGroupName
//   params: {
//     actionGroupName: actionGroupName
//     existingAGRG: existingAGRG
//     emailreceivers: emailreceivers
//     emailreiceversemails: emailreiceversemails
//     useExistingAG: useExistingAG
//     newRGresourceGroup: resourceGroupName
//     solutionTag: solutionTag
//     subscriptionId: subscriptionId
//     location: location
//   }
// }

module diagnosticsPolicy '../../../../modules/policies/mg/diagnostics/associacionpolicyDiag.bicep' = [for (rt,i) in resourceTypes: {
  name: 'associacionpolicy-${packtag}-${split(rt, '/')[1]}'
  params: {
    logAnalyticsWSResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    policyDescription: 'Policy to associate the diagnostics setting for ${split(rt, '/')[1]} resources the tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the diagnostics with the ${split(rt, '/')[1]} resources tagged with ${packtag} tag.'
    policyName: 'Associate-diagnostics-${packtag}-${split(rt, '/')[1]}'
    resourceType: rt
    initiativeMember: false
    packtype: 'PaaS'
  }
}]

module policyassignment '../../../../modules/policies/mg/policiesDiag.bicep' = [for (rt,i) in resourceTypes: {
  name: 'diagassignment-${packtag}-${split(rt, '/')[1]}'
  dependsOn: [
    diagnosticsPolicy
  ]
  params: {
    location: location
    mgname: mgname
    packtag: packtag
    policydefinitionId: diagnosticsPolicy[i].outputs.policyId
    resourceType: rt
    solutionTag: solutionTag
    subscriptionId: subscriptionId 
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    policyType: 'diag'
    instanceName: instanceName
    index: i //Index is used to create unique names for the policy assignments, mostly for Management groups since the assignment name is limited to 24 characters.
  }
}]

module vWanAlerts 'alerts.bicep' = {
  name: 'vWan-Alerts'
  params: {
    packTag: packtag
    policyLocation: location
    solutionTag: solutionTag
    parResourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    mgname: mgname
    resourceType: 'Microsoft.Network/vpngateways'
    assignmentLevel: assignmentLevel
    userManagedIdentityResourceId: userManagedIdentityResourceId
    AGId: actionGroupResourceId
    solutionVersion: solutionVersion
    location: location
    workspaceId: workspaceId
    instanceName: instanceName
  }
}

targetScope = 'managementGroup'

// Create Initiative with these policies
// VMs
// /providers/Microsoft.Authorization/policyDefinitions/ca817e41-e85a-4783-bc7f-dc532d36235e - Configure Windows virtual machines to run Azure Monitor Agent using system-assigned managed identity
// /providers/Microsoft.Authorization/policyDefinitions/a4034bc6-ae50-406d-bf76-50f4ee5a7811 - Configure Linux virtual machines to run Azure Monitor Agent with system-assigned managed identity-based authentication
// Arc Servers
// /providers/Microsoft.Authorization/policyDefinitions/845857af-0333-4c5d-bbbc-6076697da122 - Configure Linux Arc-enabled machines to run Azure Monitor Agent
// /providers/Microsoft.Authorization/policyDefinitions/94f686d6-9a24-4e19-91f1-de937dc171a4 - Configure Windows Arc-enabled machines to run Azure Monitor Agent
// Scale Sets
// /providers/Microsoft.Authorization/policyDefinitions/4efbd9d8-6bc6-45f6-9be2-7fe9dd5d89ff - Configure Windows virtual machine scale sets to run Azure Monitor Agent using system-assigned managed identity
// /providers/Microsoft.Authorization/policyDefinitions/59c3d93f-900b-4827-a8bd-562e7b956e7c - Configure Linux virtual machine scale sets to run Azure Monitor Agent with user-assigned managed identity-based authentication

// Assign initiative to subscription (for now, just one subscription)
param solutionTag string
param location string
param solutionVersion string
param subscriptionId string
param resourceGroupName string
param assignmentLevel string

//var managementgroupname= split(managementGroupId, '/')[1]

var roledefinitionIds= [
     '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // Virtual Machine Contributor
     '48b40c6e-82e0-4eb3-90d5-19e40f49b624' // Hybrid Server Resource Administrator
]
var rulename = '${solutionTag}-amaPolicy'

module amaPolicyMG '../../modules/policies/mg/policySet.bicep' = {
  name: 'amaPolicymg'
  params: {
    initiativeDescription: '[${solutionTag}] This initiative deploys the AMA policy set'
    initiativeDisplayName: '[${solutionTag}] Deploy agent with managed identity to Windows, Linux, VMs and Arc Servers and Scale Sets'
    initiativeName: '[${solutionTag}]-DeployAMA'
    category: 'Monitoring'
    version: '1.0.0'
    //initiativePoliciesID: policyIDs
    solutionTag: solutionTag
  }
}

module assignment '../../modules/policies/mg/assignment.bicep' = if (assignmentLevel == 'managementGroup'){
  name: 'assignment-${rulename}'
  dependsOn: [
    amaPolicyMG
    AMAUserManagedIdentity
  ]
  params: {
    policyDefinitionId: amaPolicyMG.outputs.policySetDefId
    location: location
    assignmentName: '[AMSP]AMA-Policies'
    solutionTag: solutionTag
    userManagedIdentityResourceId: AMAUserManagedIdentity.outputs.userManagedIdentityResourceId
    // roledefinitionIds: [
    //   '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c' 
    // ]
  }
}
module assignmentsub '../../modules/policies/subscription/assignment.bicep' = if (assignmentLevel != 'managementGroup') {
  name: 'assignment-${rulename}'
  dependsOn: [
    amaPolicyMG
    AMAUserManagedIdentity
  ]
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: amaPolicyMG.outputs.policySetDefId
    location: location
    assignmentName: 'assign-${rulename}'
    solutionTag: solutionTag
    userManagedIdentityResourceId: AMAUserManagedIdentity.outputs.userManagedIdentityResourceId
    // roledefinitionIds: [
    //   '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c' 
    // ]
  }
}
// This module creates a user managed identity for the packs to use.
module AMAUserManagedIdentity '../backend/code/modules/userManagedIdentity.bicep' = {
  name: 'AMAUserManagedIdentity'
  //scope: resourceGroup(subscriptionId,resourceGroupName)
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    roleDefinitionIds: roledefinitionIds
    userIdentityName: 'AMAUserManagedIdentity'
    mgname: managementGroup().name
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
  }
}
module userIdentityRoleAssignments '../../modules/rbac/mg/roleassignment.bicep' =  [for (roledefinitionId, i) in roledefinitionIds:  {
  name: 'AMAUserManagedIdentityRoles-${i}'
  scope: managementGroup()
  params: {
    resourcename: 'AMAUserManagedIdentity'
    principalId: AMAUserManagedIdentity.outputs.userManagedIdentityPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

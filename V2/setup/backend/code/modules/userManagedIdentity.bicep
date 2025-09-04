targetScope = 'managementGroup'
param location string
param Tags object
param roleDefinitionIds array
param userIdentityName string
param mgname string
param subscriptionId string
param resourceGroupName string
param addRGRoleAssignments bool = false
param solutionTag string
param RGroleDefinitionIds array


// resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: userIdentityName
//   location: location
//   tags: {
//     '${solutionTag}': userIdentityName
//     '${solutionTag}-Version': solutionVersion
//   }
// }

module userManagedIdentity './umidentityresource.bicep' = {
  name: userIdentityName
  scope: resourceGroup(subscriptionId,resourceGroupName)
  params: {
    location: location
    Tags: Tags
    userIdentityName: userIdentityName
  }
}
//Assign generic roles to the user managed identity
module userIdentityRoleAssignments '../../../../modules/rbac/mg/roleassignment.bicep' =  [for (roledefinitionId, i) in roleDefinitionIds:  {
  name: '${userIdentityName}-${i}'
  scope: managementGroup(mgname)
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.outputs.userManagedIdentityPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

module userIdentityRoleAssignmentRG '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = [for (roledefinitionId, i) in RGroleDefinitionIds: if (addRGRoleAssignments) {
  name: '${userIdentityName}-${i}-RG'
  scope: resourceGroup(subscriptionId,resourceGroupName)
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.outputs.userManagedIdentityPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.userManagedIdentityPrincipalId
output userManagedIdentityClientId string = userManagedIdentity.outputs.userManagedIdentityClientId
output userManagedIdentityResourceId string = userManagedIdentity.outputs.userManagedIdentityResourceId

targetScope = 'managementGroup'
param location string
param solutionTag string
param solutionVersion string
param roleDefinitionIds array
param userIdentityName string
param mgname string
param subscriptionId string
param resourceGroupName string

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
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userIdentityName: userIdentityName
  }
}

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

output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.userManagedIdentityPrincipalId
output userManagedIdentityClientId string = userManagedIdentity.outputs.userManagedIdentityClientId
output userManagedIdentityResourceId string = userManagedIdentity.outputs.userManagedIdentityResourceId

targetScope = 'managementGroup'
param location string
param solutionTag string
param solutionVersion string
param roleDefinitionIds array
param userIdentityName string
param subscriptionId string
param resourceGroupName string

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userIdentityName
  location: location
  tags: {
    '${solutionTag}': userIdentityName
    '${solutionTag}-Version': solutionVersion
  }
}

module userIdentityRoleAssignments '../../../../../modules/rbac/mg/roleassignment.bicep' = [for (roledefinitionId, i) in roleDefinitionIds:  {
  name: '${userIdentityName}-${i}'
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.properties.principalId
    solutionTag: solutionTag
    resourceGroup: resourceGroup().name
    roleDefinitionId: roledefinitionId
    roleShortName: split(roledefinitionId, '/')[4]
  }
}]
// resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roledefinitionId, i) in roleDefinitionIds:  {
//   name: guid('${userIdentityName}-${subscription().subscriptionId}-${i}')
//   properties: {
//     scope: '/subscriptions/${subscription().subscriptionId}'
//     roleDefinitionId: roledefinitionId
//     principalId: userManagedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//     description: 'Role assignment for Monstar packs with "${guid('${userIdentityName}-${subscription().subscriptionId}-${i}')}" role definition id.'
//   }
// }]

output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId
output userManagedIdentityClientId string = userManagedIdentity.properties.clientId
output userManagedIdentityResourceId string = userManagedIdentity.id

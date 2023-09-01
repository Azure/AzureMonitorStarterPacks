param location string
param solutionTag string
param solutionVersion string
param roleDefinitionIds array
param userIdentityName string
param deployToManagementGroup bool = false

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userIdentityName
  location: location
  tags: {
    '${solutionTag}': userIdentityName
    '${solutionTag}-Version': solutionVersion
  }
}

module userIdentityRoleAssignments '../../../../modules/rbac/subscription/roleassignment.bicep' =  [for (roledefinitionId, i) in roleDefinitionIds: if(deployToManagementGroup == false) {
  name: '${userIdentityName}-${i}'
  scope: subscription()
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.properties.principalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId
output userManagedIdentityClientId string = userManagedIdentity.properties.clientId
output userManagedIdentityResourceId string = userManagedIdentity.id

param location string
param solutionTag string
param solutionVersion string
param roleDefinitionIds array
param userIdentityName string

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userIdentityName
  location: location
  tags: {
    '${solutionTag}': userIdentityName
    '${solutionTag}-Version': solutionVersion
  }
}

resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roledefinitionId, i) in roleDefinitionIds:  {
  name: guid('${userIdentityName}-${subscription().subscriptionId}-${i}')
  properties: {
    roleDefinitionId: roledefinitionId
    principalId: userManagedIdentity.id
    principalType: 'ServicePrincipal'
    description: 'Role assignment for Monstar packs with "${guid('${userIdentityName}-${subscription().subscriptionId}-${i}')}" role definition id.'
  }
}]

output userManagedIdentityId string = userManagedIdentity.id

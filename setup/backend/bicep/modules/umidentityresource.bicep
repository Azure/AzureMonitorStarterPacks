param location string
param Tags object
param userIdentityName string

resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userIdentityName
  location: location
  tags: Tags
}
output userManagedIdentityPrincipalId string = userManagedIdentity.properties.principalId
output userManagedIdentityClientId string = userManagedIdentity.properties.clientId
output userManagedIdentityResourceId string = userManagedIdentity.id

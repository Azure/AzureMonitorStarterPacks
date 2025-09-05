param location string
param galleryname string
param tags object
param userManagedIdentity string
resource aig 'Microsoft.Compute/galleries@2024-03-03' = {
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity}': {}
    }
  }
  name: galleryname
  tags: tags
  properties: {
    description: 'Monitoring gallery'

  }
}

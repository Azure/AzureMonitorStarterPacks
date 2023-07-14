param dceName string
param location string
param tagsArray object

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: dceName
  location: location
  tags: tagsArray
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}

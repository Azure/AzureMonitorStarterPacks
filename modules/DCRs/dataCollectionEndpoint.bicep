param dceName string
param location string
param Tags object

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: dceName
  location: location
  tags: Tags
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}
output dceId string = dataCollectionEndpoint.id

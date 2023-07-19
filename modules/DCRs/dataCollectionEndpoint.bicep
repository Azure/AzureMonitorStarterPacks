param dceName string
param location string
param solutionTag string
param packtag string

resource dataCollectionEndpoint 'Microsoft.Insights/dataCollectionEndpoints@2021-09-01-preview' = {
  name: dceName
  location: location
  tags: {
    '${solutionTag}': packtag
  }
  properties: {
    networkAcls: {
      publicNetworkAccess: 'Enabled'
    }
  }
}
output dceId string = dataCollectionEndpoint.id

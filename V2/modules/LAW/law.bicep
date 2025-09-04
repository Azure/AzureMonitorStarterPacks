param logAnalyticsWorkspaceName string
param location string
param newLogAnalyticsWSName string = ''
param createNewLogAnalyticsWS bool = false
param Tags object

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: Tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
output customerId string = law.properties.customerId
output lawresourceid string = law.id

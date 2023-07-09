param logAnalyticsWorkspaceName string
param location string
resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: {
    MonitorStarterPacks: 'true'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
output customerId string = law.properties.customerId
output lawresourceid string = law.id

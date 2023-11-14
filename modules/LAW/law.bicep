param logAnalyticsWorkspaceName string
param location string
param solutionTag string
param newLogAnalyticsWSName string = ''
param createNewLogAnalyticsWS bool = false

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: {
    '${solutionTag}': 'Log Analytics workspace'
  }
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}
output customerId string = law.properties.customerId
output lawresourceid string = law.id

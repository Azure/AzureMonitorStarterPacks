param location string
param rulename string
param workspaceId string
param kind string = 'Windows'
param wsfriendlyname string = 'TBD'
param xPathQueries array
param windowsEventLogs array = []
param performanceCounters array = []
resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  location: location
  name: rulename
  kind: kind
  properties: {
    description: 'Data Collection Rule for ${kind}} - ${rulename}}'
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceId
          name: wsfriendlyname
      //   tableNames: [
      //     'EventLogs'
      //   ]
      // }
        }
      ]
    }
    dataSources: {
      windowsEventLogs: [
        {
            streams: [
                'Microsoft-Event'
            ]
            xPathQueries: (empty(xPathQueries) ? json('null') : xPathQueries)
            //name: dataSourceName
            name: 'EventLogsDataSource'
        }
      ]
    }
    dataFlows:[
        {
            streams: [
              'Microsoft-Event'
            ]
            destinations: [
              wsfriendlyname
            ]
            transformKql: 'source'
            outputStream: 'Microsoft-Event'
        }
    ]
  }
}
output dcrId string = dcr.id


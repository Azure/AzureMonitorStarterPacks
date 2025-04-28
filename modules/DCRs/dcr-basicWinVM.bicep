param location string
param rulename string
param workspaceId string
param kind string = 'Windows'
param wsfriendlyname string = 'TBD'
param xPathQueries array = []
param counterSpecifiers array = []
param samplingFrequencyInSeconds int = 300
param Tags object
param dceId string

/*
              "System!*[System[(Level = 1 or Level = 2 or Level = 3)]]",
              "Application!*[System[(Level = 1 or Level = 2 or Level = 3)]]"
*/
resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  location: location
  tags: Tags
  name: rulename
  
  kind: kind
  properties: {
    dataCollectionEndpointId: dceId
    description: 'Data Collection Rule for ${kind}} - ${rulename}}'
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceId
          name: wsfriendlyname
        }
      ]
    }
    dataSources: {
      windowsEventLogs: empty(xPathQueries) ? null: [
        {
            streams: [
                'Microsoft-Event'
            ]
            xPathQueries: xPathQueries
            //name: dataSourceName
            name: 'EventLogsDataSource'
        }
      ]
      performanceCounters: empty(counterSpecifiers) ? null : [
        // DCRs don't seem to support more than 5 minutes for samplingFrequencyInSeconds
        {
          streams: [
              'Microsoft-Perf'
          ]
          samplingFrequencyInSeconds: samplingFrequencyInSeconds
          //scheduledTransferPeriod: 'PT5M'
          counterSpecifiers: counterSpecifiers
          name: 'PerfCountersDataSource'
        }
      ]
    }
    dataFlows:[
        {
            streams: [
              'Microsoft-Event'
              'Microsoft-Perf'
            ]
            destinations: [
              wsfriendlyname
            ]
            // transformKql: 'source'
            // outputStream: 'Microsoft-Event'
        }
    ]
  }
}
output dcrId string = dcr.id



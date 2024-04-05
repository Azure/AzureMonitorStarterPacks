param location string
param rulename string
param workspaceId string
param kind string = 'Linux'
param wsfriendlyname string = 'TBD'
param packtag string
param counterSpecifiers array = [
]
param samplingFrequencyInSeconds int = 300
param solutionTag string
param Tags object

resource dcr 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  location: location
  tags: Tags
  name: rulename
  kind: kind
  properties: {
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
      performanceCounters: [
        {
          streams: [
              'Microsoft-Perf'
          ]
          counterSpecifiers: counterSpecifiers
          name: 'PerfCountersDataSource'
          samplingFrequencyInSeconds: samplingFrequencyInSeconds
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



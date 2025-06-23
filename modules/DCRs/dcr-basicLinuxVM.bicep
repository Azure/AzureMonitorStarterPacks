param location string
param rulename string
param workspaceResourceId string

param wsfriendlyname string = 'TBD'
param packtag string
param counterSpecifiers array = [
]
param samplingFrequencyInSeconds int = 300
param solutionTag string
param Tags object

var kind  = 'Linux'

resource dcr 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  location: location
  tags: Tags
  name: rulename
  kind: kind
  properties: {
    description: 'Data Collection Rule for ${kind}} - ${rulename}}'
    destinations: {
      logAnalytics: [
        {
          workspaceResourceId: workspaceResourceId
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



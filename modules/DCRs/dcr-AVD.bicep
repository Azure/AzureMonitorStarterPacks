param location string
param rulename string
param workspaceId string
param kind string = 'Windows'
param wsfriendlyname string = 'TBD'
param xPathQueries array = []
param counterSpecifiers30 array = []
param counterSpecifiers60 array = []
// param samplingFrequencyInSeconds int = 300
param packtag string
param solutionTag string
param dceId string

/*
              Based on AVD Insights Configuration Workbook settings  
              12/2023
*/


// =========== //
// Deployments //
// =========== //
resource dcr 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: rulename
  location: location
  tags: {
    '${solutionTag}': packtag
            instanceName: instanceName
  }
  kind: kind
  properties: {
    dataCollectionEndpointId: dceId
    dataFlows: [
      {
        streams: [
          'Microsoft-Perf'
          'Microsoft-Event'
        ]
        destinations: [
          wsfriendlyname
        ]
      }
    ]
    dataSources: {
      performanceCounters: [
        {
            streams: [
                'Microsoft-Perf'
            ]
            samplingFrequencyInSeconds: 30
            counterSpecifiers: counterSpecifiers30
            name: 'perfCounterDataSource10'
        }
        {
            streams: [
                'Microsoft-Perf'
            ]
            samplingFrequencyInSeconds: 60
            counterSpecifiers: counterSpecifiers60
            name: 'perfCounterDataSource30'
        }
    ]
    windowsEventLogs: [
        {
            streams: [
                'Microsoft-Event'
            ]
            xPathQueries: xPathQueries
            name: 'eventLogsDataSource'
        }
    ]
    }
    description: 'Data Collection Rule for ${kind}} - ${rulename}}'
    destinations: {
      logAnalytics: [
        {
          name: wsfriendlyname
          workspaceResourceId: workspaceId
        }
      ]
    }
    streamDeclarations: {}
  }
}

// =========== //
// Outputs //
// =========== //
output dcrId string = dcr.id

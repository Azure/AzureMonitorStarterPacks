param location string 
param solutionTag string
param lawResourceId string
param tableName string
param packtag string
param kind string
param filepatterns array
param OS string
param packtype string
@description('Specifies the resource id of the data collection endpoint.')
param endpointResourceId string
param instanceName string

var streamName= 'Custom-${tableName}'
var lawFriendlyName = split(lawResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'AMP-${instanceName}-FileColl-${packtag}-${OS}'
  location: location
  tags: {
    '${solutionTag}': packtag
    MonitoringPackType: packtype
  }
  kind: kind
  properties: {
    dataSources: {
      logFiles: [
        {
            streams: [
              streamName
            ]
            filePatterns: filepatterns
            format: 'text'
            settings: {
              text: {
                  recordStartTimestampFormat: 'ISO 8601'
              }
            }
            name: streamName
        }
      ]
    }
    destinations:  {
      logAnalytics : [
          {
              workspaceResourceId: lawResourceId
              name: lawFriendlyName
          }
      ]
    }
    dataFlows: [
      {
          streams: [
            streamName
          ]
          destinations: [
              lawFriendlyName
          ]
          transformKql: 'source'
          outputStream: streamName
      }
    ]
    dataCollectionEndpointId: endpointResourceId
    streamDeclarations: {
      '${streamName}': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
        ]
      }
    }
  }
}

output ruleId string = fileCollectionRule.id
output ruleName string = fileCollectionRule.name

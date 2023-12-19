param location string 
param solutionTag string
param lawResourceId string
param tableName string
param packtag string = 'discovery'
param kind string
param filepatterns array
param OS string
@description('Specifies the resource id of the data collection endpoint.')
param endpointResourceId string

var tableNameToUse = tableName
var streamName= 'Custom-${tableNameToUse}'
var lawFriendlyName = split(lawResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: 'AMSP-Disc-${OS}'
  location: location
  tags: {
    '${solutionTag}': packtag
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
            name: tableNameToUse
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

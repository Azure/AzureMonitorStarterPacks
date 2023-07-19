
@description('Specifies the name of the data collection rule to create.')
param ruleName string

@description('Specifies the resource id of the data collection endpoint.')
param endpointResourceId string

@description('Name of the table.')
param tableName string

@description('Specifies the location in which to create the data collection rule.')
param location string

param filepatterns array
param lawResourceId string
param lawFriendlyName string
param solutionTag string
param packtag string

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  name: ruleName
  location: location
  tags: {
    '${solutionTag}': packtag
  }
  kind: 'Windows'
  properties: {
    dataSources: {
      logFiles: [
      {
          streams: [
              '${tableName}'
          ]
          filePatterns: filepatterns
          format: 'text'
          settings: {
              text: {
                  recordStartTimestampFormat: 'ISO 8601'
              }
          }
          name: tableName
      }
    ]}
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
              tableName
          ]
          destinations: [
              lawFriendlyName
          ]
          transformKql: 'source'
          outputStream: tableName
      }
    ]
    dataCollectionEndpointId: endpointResourceId
    streamDeclarations: {
      '${tableName}': {
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

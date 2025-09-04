param location string 
param solutionTag string
param workspaceResourceId string
param tableName string
param packtag string
param filepatterns array
@description('Specifies the resource id of the data collection endpoint.')
param dceId string
param instanceName string
param retentionDays int = 31
param rulename string
param tags object = {}

var tableNameToUse  = '${tableName}_CL'
var streamName= 'Custom-${tableName}_CL'
var lawFriendlyName = split(workspaceResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: rulename
  dependsOn: [
    featuresTable
  ]
  location: location
  tags: {
    '${solutionTag}': packtag
      instanceName: instanceName
    MonitoringPackType: 'IaaS'
  }
  kind: 'Windows'
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
            name: tableName
        }
      ]
    }
    destinations:  {
      logAnalytics : [
          {
              workspaceResourceId: workspaceResourceId
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
    dataCollectionEndpointId: dceId
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
resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: lawFriendlyName
}
resource featuresTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  name: tableNameToUse
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: tableNameToUse
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
    retentionInDays: retentionDays
  }  
}
output ruleId string = fileCollectionRule.id
output ruleName string = fileCollectionRule.name

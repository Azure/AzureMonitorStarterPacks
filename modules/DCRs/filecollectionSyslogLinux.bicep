
@description('Specifies the name of the data collection rule to create.')
param rulename string

@description('Specifies the resource id of the data collection endpoint.')
param dceId string

@description('Name of the table.')
param tableName string

@description('Specifies the location in which to create the data collection rule.')
param Location string
param filepatterns array
param workspaceResourceId string
param Tags object
param facilityNames array
param logLevels array
param syslogDataSourceName string = 'sysLogsDataSource-1688419672'
param kqlTransformation string
param retentionDays int = 31
param createTable bool = true

var streamName= 'Custom-${tableName}'
var lawFriendlyName = split(workspaceResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: rulename
  dependsOn: [
    featuresTable
  ]
  location: Location
  tags: Tags
  kind: 'Linux'
  properties: {
    dataSources: {
      syslog: [
        {
            streams: [
                'Microsoft-Syslog'
            ]
            facilityNames: facilityNames
            logLevels: logLevels
            name: syslogDataSourceName
        }
      ]
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
            'Microsoft-Syslog'
        ]
        destinations: [
            lawFriendlyName
        ]
        transformKql: kqlTransformation
        outputStream: 'Microsoft-Syslog'
      }
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

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing = if (createTable) {
  name: lawFriendlyName
}
resource featuresTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = if (createTable) {
  name: tableName
  dependsOn: [
    law
  ]
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: tableName
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

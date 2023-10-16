
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

param solutionTag string
param packtag string
param facilityNames array
param logLevels array
param syslogDataSourceName string = 'sysLogsDataSource-1688419672'

var tableNameToUse = 'CustomAzMA${tableName}_CL'
var streamName= 'Custom-${tableNameToUse}'
var lawFriendlyName = split(lawResourceId,'/')[8]
var lawResourceGroup = split(lawResourceId,'/')[4]

module table '../LAW/table.bicep' = {
  name: tableNameToUse
  scope: resourceGroup(lawResourceGroup)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: ruleName
  location: location
  dependsOn: [
    table
  ]
  tags: {
    '${solutionTag}': packtag
  }
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
            'Microsoft-Syslog'
        ]
        destinations: [
            lawFriendlyName
        ]
        transformKql: 'source | where SyslogMessage == "Stopped A high performance web server and a reverse proxy server." or SyslogMessage == "Started A high performance web server and a reverse proxy server."'
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

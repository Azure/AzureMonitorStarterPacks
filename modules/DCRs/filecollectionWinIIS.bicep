
@description('Specifies the name of the data collection rule to create.')
param ruleName string

@description('Specifies the resource id of the data collection endpoint.')
param endpointResourceId string

// @description('Name of the table.')
// param tableName string

@description('Specifies the location in which to create the data collection rule.')
param location string

param lawResourceId string
param Tags object

// var tableNameToUse = 'CustomAzMA${tableName}_CL'
// var streamName= 'Custom-${tableNameToUse}'
var lawFriendlyName = split(lawResourceId,'/')[8]

// module table '../LAW/table.bicep' = {
//   name: tableNameToUse
//   params: {
//     parentname: lawFriendlyName
//     tableName: tableNameToUse
//     retentionDays: 31
//   }
// }

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2022-06-01' = {
  name: ruleName
  location: location
  tags: Tags
  kind: 'Windows'
  properties: {
    dataCollectionEndpointId: endpointResourceId
    dataSources: {
      iisLogs: [
        {
            streams: [
                'Microsoft-W3CIISLog'
            ]
            name: 'iisLogsDataSource'
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
            'Microsoft-W3CIISLog'
          ]
          destinations: [
              lawFriendlyName
          ]
          transformKql: 'source'
          outputStream: 'Microsoft-W3CIISLog'
      }
    ]
    
    streamDeclarations: {
      'Custom-MyTable_CL': {
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

output dcrId string = fileCollectionRule.id

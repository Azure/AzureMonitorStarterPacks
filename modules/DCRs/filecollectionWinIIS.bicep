
@description('Specifies the name of the data collection rule to create.')
param ruleName string

@description('Specifies the resource id of the data collection endpoint.')
param dceId string

@description('Specifies the location in which to create the data collection rule.')
param location string

param workspaceResourceId string
param Tags object
//Not used in this module, but required for the DCR resource
param xPathQueries array = []
param counterSpecifiers array = []

var lawFriendlyName = split(workspaceResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: ruleName
  location: location
  tags: Tags
  kind: 'Windows'
  properties: {
    dataCollectionEndpointId: dceId
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
              workspaceResourceId: workspaceResourceId
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

param location string
param workspaceResourceId string
param Tags object
param ruleName string
param dceId string
param tableName string // with the _CL suffix
// the stream name has to start with Custom-. It is convienent to use the same name as the table name, but it is not required
var streamname='Custom-${tableName}' 

var wsfriendlyname=split(workspaceResourceId, '/')[8]
// previously used this, but it's complicated when using VMInsights for Linux and Windows
//var ruleName = 'MSVMI-${wsfriendlyname}'

resource discoveryRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  location: location
  name: '${ruleName}-discovery'
  tags: Tags
  properties: {
    description: 'Data collection rule for workload discovery.'
    dataCollectionEndpointId: dceId
    streamDeclarations: {
      '${streamname}' : {
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'Tag'
                type: 'string'
            }
            {
                name: 'ResourceId'
                type: 'string'
            }
            {
                name: 'OS'
                type: 'string'
            }
            {
                name: 'Location'
                type: 'string'
            }
        ]
      
      }
    }
    destinations: {
        logAnalytics: [
            {
                workspaceResourceId: workspaceResourceId
                name: wsfriendlyname
            }
        ]
    }
    dataFlows: [
        {
            streams: [
                '${streamname}'
            ]
            destinations: [
                wsfriendlyname
            ]
            transformKql: 'source | project TimeGenerated, Tag, ResourceId, OS, Location'
            outputStream: streamname
        }
    ]
  }
}
output RuleId string = discoveryRule.id
output dcrImmutableId string = discoveryRule.properties.immutableId
output streamName string = streamname
output tableName string = discoveryRule.name

param location string
param workspaceResourceId string
param Tags object
param ruleName string
param dceId string
param xPathQueries array = []
param counterSpecifiers array = []

var wsfriendlyname=split(workspaceResourceId, '/')[8]
// previously used this, but it's complicated when using VMInsights for Linux and Windows
//var ruleName = 'MSVMI-${wsfriendlyname}'

resource SMapRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  location: location
  name: ruleName
  tags: Tags
  properties: {
    description: 'Data collection rule for VM Insights.'
    dataCollectionEndpointId: dceId
    dataSources: {
        extensions: [
        {
            streams: [
                'Microsoft-ServiceMap'
            ]
            extensionName: 'DependencyAgent'
            extensionSettings: {}
            name: 'DependencyAgentDataSource'
        }
]
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
                'Microsoft-ServiceMap'
            ]
            destinations: [
                wsfriendlyname
            ]
        }
    ]
  }
}
output RuleId string = SMapRule.id

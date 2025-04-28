param location string
param workspaceResourceId string
param Tags object
param ruleName string
param dceId string

var wsfriendlyname=split(workspaceResourceId, '/')[8]
// previously used this, but it's complicated when using VMInsights for Linux and Windows
//var ruleName = 'MSVMI-${wsfriendlyname}'

resource VMIRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  location: location
  name: '${ruleName}-VMI'
  tags: Tags
  properties: {
    description: 'Data collection rule for VM Insights.'
    dataCollectionEndpointId: dceId
    dataSources: {
        performanceCounters: [
            {
                name: 'VMInsightsPerfCounters'
                streams: [
                    'Microsoft-InsightsMetrics'
                ]
                //scheduledTransferPeriod: 'PT1M'
                samplingFrequencyInSeconds: 60
                counterSpecifiers: [
                    '\\VmInsights\\DetailedMetrics'
                ]
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
                'Microsoft-InsightsMetrics'
            ]
            destinations: [
                wsfriendlyname
            ]
        }
    ]
  }
}
output VMIRuleId string = VMIRule.id


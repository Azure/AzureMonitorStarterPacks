param location string
param workspaceResourceId string
param solutionTag string
param packtag string

var wsfriendlyname=split(workspaceResourceId, '/')[8]
var ruleName = 'MSVMI-${wsfriendlyname}'

resource VMIRule 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' = {
  location: location
  name: ruleName
  tags: {
    '${solutionTag}': packtag
  }
  properties: {
    description: 'Data collection rule for VM Insights.'
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

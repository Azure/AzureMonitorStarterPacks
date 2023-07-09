param alertrulename string
param location string = 'global'
param vmId string
param metricName string
param metricNamespace string = 'Microsoft.Compute/virtualMachines'
param threshold int
param timeAggregation string = 'Average'
param packtag string

@allowed([
  'GreaterThan'
  'GreaterThanOrEqual'
  'LessThan'
  'LessThanOrEqual'
])
param operator string = 'GreaterThan'
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param evaluationFrequency string = 'PT5M'
@allowed([
  'PT1M'
  'PT5M'
  'PT15M'
  'PT30M'
  'PT1H'
])
param windowSize string = 'PT5M'
resource metricalert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: alertrulename
  location: location
  tags: {
    MonitorStarterPacks: packtag
  }
  properties: {
    scopes: [
      vmId
    ]
    severity: 3
    enabled: true
    evaluationFrequency: evaluationFrequency
    windowSize: windowSize
    criteria: {
      allOf: [
        {
            threshold: threshold
            name: metricName
            metricNamespace: metricNamespace
            metricName: metricName
            operator: operator
            timeAggregation: timeAggregation
            criterionType: 'StaticThresholdCriterion'
        }
    ]
    'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
  }
}

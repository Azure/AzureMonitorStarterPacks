param alertlist array
param location string
param workspaceId string
param AGId string
param packtag string
param Tags object
param moduleprefix string

module Alerts './alert.bicep' = [for (alert,i) in alertlist:  {
  name: '${packtag}-Alert-${i}-${location}'
  params: {
    location: location
    actionGroupResourceId: AGId
    alertRuleDescription: alert.alertRuleDescription
    alertRuleDisplayName: '${moduleprefix}-${alert.alertRuleDisplayName}'
    alertRuleName: '${moduleprefix}-${alert.alertRuleName}'
    alertRuleSeverity: alert.alertRuleSeverity
    autoMitigate: alert.autoMitigate
    evaluationFrequency: alert.evaluationFrequency
    windowSize: alert.windowSize
    scope: workspaceId
    query: alert.query
    dimensions: contains(alert, 'dimensions') ? alert.dimensions : null
    packtag: packtag
    Tags: Tags
    alertType: alert.alertType
    metricMeasureColumn: alert.alertType == 'Aggregated' ? alert.metricMeasureColumn : null
    operator: alert.alertType == 'Aggregated' ? alert.operator : null
    threshold: alert.alertType == 'Aggregated' ? alert.threshold : null
  }
}]

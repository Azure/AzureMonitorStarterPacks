param location string
param workspaceId string
param AGId string
param packtag string
param solutionTag string
var moduleprefix = 'AMSP-Lx-DCR-Alerts'


var alertlist =  [ 
  {
  alertRuleDescription: 'Alert for CPU crash volmgr issue'
  alertRuleDisplayName: 'CPU crash volmgr issue'
  alertRuleName:'CPUcrashvolmgrissue' 
  alertRuleSeverity:3
  autoMitigate: true
  evaluationFrequency: 'PT15M'
  windowSize: 'PT15M'
  query: 'Event\n| where EventID == 46'
}
]
// This is a event log based alert
// Alerts
module vmalerts '../../../../modules/alerts/scheduledqueryrule.bicep' = [for alert in alertlist:  {
  name: '${moduleprefix}-${alert.alertRuleName}'
  params: {
    location: location
    actionGroupResourceId: AGId
    alertRuleDescription: alert.alertRuleDescription
    alertRuleDisplayName: '${moduleprefix}-${alert.alertRuleDisplayName}'
    alertRuleName: '${moduleprefix}-${alert.alertRuleName}'
    alertRuleSeverity: alert.alertRuleSeverity
    scope: workspaceId
    query: alert.query
    packtag: packtag
    solutionTag: solutionTag
  }
}]

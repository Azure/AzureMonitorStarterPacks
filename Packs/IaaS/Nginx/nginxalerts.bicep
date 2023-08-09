param location string
param workspaceId string
param AGId string
param packtag string
param solutionTag string
param solutionVersion string

var moduleprefix = 'AMSP-LxOS-Nginx'
// Alert list

var alertlist = [
  {
      alertRuleDescription: 'Nginx stopped.'
      alertRuleDisplayName:'Nginx service stopped.'
      alertRuleName:'AlertRule-Nginx-1'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Syslog | where SyslogMessage == "Stopped A high performance web server and a reverse proxy server."'
    }
]
module alertsnew '../../../modules/alerts/alerts.bicep' = {
  name: '${moduleprefix}-Alerts'
  params: {
    alertlist: alertlist
    AGId: AGId
    location: location
    moduleprefix: moduleprefix
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    workspaceId: workspaceId
  }
}
// // these are scheduled query rules that use number of rows as the metric
// module Alerts '../../../modules/alerts/scheduledqueryruleRows.bicep' = [for alert in alertlist:  {
//   name: '${moduleprefix}-${alert.alertRuleName}'
//   params: {
//     location: location
//     actionGroupResourceId: AGId
//     alertRuleDescription: alert.alertRuleDescription
//     alertRuleDisplayName: '${moduleprefix}-${alert.alertRuleDisplayName}'
//     alertRuleName: '${moduleprefix}-${alert.alertRuleName}'
//     alertRuleSeverity: alert.alertRuleSeverity
//     autoMitigate: alert.autoMitigate
//     evaluationFrequency: alert.evaluationFrequency
//     windowSize: alert.windowSize
//     scope: workspaceId
//     query: alert.query
//     packtag: packtag
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion
//   }
// }]

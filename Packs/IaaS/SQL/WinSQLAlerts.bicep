param location string
param workspaceId string
param AGId string
/*
List of Insights default metrics:
LogicalDisk WriteBytesPerSecond 15M 
LogicalDisk ReadBytesPerSecond 
LogicalDisk FreeSpaceMB 
LogicalDisk FreeSpacePercentage 
LogicalDisk ReadsPerSecond 
LogicalDisk TransfersPerSecond 
LogicalDisk WritesPerSecond 
LogicalDisk BytesPerSecond 
LogicalDisk Status 
LogicalDisk WriteLatencyMs 
LogicalDisk TransferLatencyMs 
LogicalDisk ReadLatencyMs 
Network     WriteBytesPerSecond 
Network     ReadBytesPerSecond 
Computer    Heartbeat 
Memory      AvailableMB 
Processor   UtilizationPercentage 
*/
var moduleprefix = 'AMSP-Win-SQL'
var starterPackName = 'WinSQLMonitoring'
// Alert list

var alertlist = [
  {
      alertRuleDescription: 'A server side include file has included itself or the maximum depth of server side includes has been exceeded'
      alertRuleDisplayName:'A server side include file has included itself or the maximum depth of server side includes has been exceeded'
      alertRuleName:'AlertRule-IIS-2012-1'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      query: 'Event | where  EventID in (2221) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
]

module Alerts '../../../modules/alerts/scheduledqueryrule.bicep' = [for alert in alertlist:  {
  name: '${moduleprefix}-${alert.alertRuleName}'
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
    starterPackName: starterPackName
  }
}]

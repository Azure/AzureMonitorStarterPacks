param location string
param workspaceId string
param AGId string
var moduleprefix = 'AMSP-Win-VMI'
param packtag string
// Alert list
var alertlist = [
  {
    alertRuleDescription: 'Alert for disk space under 10%'
    alertRuleDisplayName:'Disk space under 10%'
    alertRuleName:'DiskSpaceUnderPercentWarning'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    query: 'InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 10 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
  }
  {
    alertRuleDescription: 'Alert for disk space under 5%'
    alertRuleDisplayName:'Disk space under 5%'
    alertRuleName:'DiskSpaceUnderPercentCritical'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    query: 'InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 5 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
  }
  {
    alertRuleDescription: 'Heartbeat alert for VMs - 5 minutes'
    alertRuleDisplayName:'Heartbeat alert for VMs'
    alertRuleName:'HeartbeatAlert'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    query: 'InsightsMetrics| where Namespace == \'Computer\' and Name == \'Heartbeat\'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)'
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 90%'
    alertRuleDisplayName:'CPU usage over 90%'
    alertRuleName:'CPUUsageOverPercentWarning'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    query: 'InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 90 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 95%'
    alertRuleDisplayName:'CPU usage over 95%'
    alertRuleName:'CPUUsageOverPercentcritical'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    query: 'InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 95 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
  }
]

module InsightsAlerts '../../../modules/alerts/scheduledqueryrule.bicep' = [for alert in alertlist:  {
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
    packtag: packtag
  }
}]

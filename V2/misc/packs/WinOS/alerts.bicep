param location string
param workspaceId string
param AGId string
param packtag string
param Tags object
param instanceName string
//var moduleprefix = 'AMSP-Win-VMI'
var moduleprefix = 'AMP-${instanceName}-${packtag}'
// Since ARG queries from LAW is not fully cooked, we have to break the alerts into 2 parts (VMs and Arc).
// The ones in this file cover Windows VMs and Arc.
// Alert list
var alertlist = [
  {
    alertRuleDescription: 'Alert for Memory over 90%'
    alertRuleDisplayName:'Memory over 90%'
    alertRuleName:'MemoveryOverPercentWarning'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AvgMemUse'
    operator: 'GreaterThan'
    threshold: 90
    query: 'InsightsMetrics | where Namespace == "Memory" and Name == "AvailableMB" | extend memorySizeMB = todouble(parse_json(Tags).["vm.azm.ms/memorySizeMB"]) | extend PercentageBytesinUse = Val/memorySizeMB*100    | summarize AvgMemUse = avg(PercentageBytesinUse) by bin(TimeGenerated, 15m), _ResourceId,Computer'  
  }
  {
    alertRuleDescription: 'Alert for disk space under 10%'
    alertRuleDisplayName:'Disk space under 10%'
    alertRuleName:'DiskSpaceUnderPercentWarning'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
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
    alertType: 'rows'
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
    alertType: 'rows'
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
    alertType: 'rows'
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
    alertType: 'rows'
    query: 'InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 95 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
  }
]
module alertsnew '../../../modules/alerts/alerts.bicep' = {
  name: '${moduleprefix}-Alerts-${instanceName}-${location}'
  params: {
    alertlist: alertlist
    AGId: AGId
    location: location
    moduleprefix: moduleprefix
    packtag: packtag
    Tags: Tags
    workspaceId: workspaceId
  }
}

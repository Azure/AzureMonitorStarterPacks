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
    alertRuleDisplayName:'Memory over 90% - Warning - Windows VMs'
    alertRuleName:'MemoveryOverPercentWarningWinVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AvgMemUse'
    operator: 'GreaterThan'
    threshold: 90
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (InsightsMetrics | where Namespace == "Memory" and Name == "AvailableMB" | extend memorySizeMB = todouble(parse_json(Tags).["vm.azm.ms/memorySizeMB"]) | extend PercentageBytesinUse = Val/memorySizeMB*100    | summarize AvgMemUse = avg(PercentageBytesinUse) by bin(TimeGenerated, 15m), _ResourceId,Computer
    ) on Computer
    | where OS=~'Windows'
    | project-away Computer1   
    '''
  }
  {
    alertRuleDescription: 'Alert for Memory over 90%'
    alertRuleDisplayName:'Memory over 90% - Warning - Windows Arc'
    alertRuleName:'MemoveryOverPercentWarningWinArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AvgMemUse'
    operator: 'GreaterThan'
    threshold: 90
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (InsightsMetrics | where Namespace == "Memory" and Name == "AvailableMB" | extend memorySizeMB = todouble(parse_json(Tags).["vm.azm.ms/memorySizeMB"]) | extend PercentageBytesinUse = Val/memorySizeMB*100    | summarize AvgMemUse = avg(PercentageBytesinUse) by bin(TimeGenerated, 15m), _ResourceId,Computer=tolower(Computer)
    ) on Computer
    | where OS=~'windows'
    | project-away Computer1  
    '''
  }
  '''
  arg("").resources
| where type =~ 'microsoft.hybridcompute/machines'
| project Computer=tolower(name), OS=tolower(properties.osType)

'''
  {
    alertRuleDescription: 'Alert for disk space under 10% - Windows VMs'
    alertRuleDisplayName:'Disk space under 10% - Windows VMs'
    alertRuleName:'DiskSpaceUnderPercentWarningWinVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics| where Namespace == 'LogicalDisk'    and Name == 'FreeSpacePercentage'    and Origin == "vm.azm.ms"| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])| where Val < 10 //would use a low value...| summarize by _ResourceId,Computer, Disk, Val| where Disk notcontains "snap"'
      ) on Computer
    | where OS=~'Windows'
    | project-away Computer1
  '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 10% - Windows Arc'
    alertRuleDisplayName:'Disk space under 10% - Windows Arc'
    alertRuleName:'DiskSpaceUnderPercentWarningWinArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics| where Namespace == 'LogicalDisk'    and Name == 'FreeSpacePercentage'    and Origin == "vm.azm.ms"| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])| where Val < 10 //would use a low value...| summarize by _ResourceId,Computer, Disk, Val| where Disk notcontains "snap"'
      ) on Computer
    | where OS=~'Windows'
    | project-away Computer1
  '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 5% - Windows VMs'
    alertRuleDisplayName:'Disk space under 5% - Windows VMs'
    alertRuleName:'DiskSpaceUnderPercentCriticalWinVMs'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
    InsightsMetrics| where Namespace == 'LogicalDisk'    and Name == 'FreeSpacePercentage'    and Origin == "vm.azm.ms"| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])| where Val < 5 //would use a low value...| summarize by _ResourceId,Computer, Disk, Val| where Disk notcontains "snap"'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 5% - Windows Arc'
    alertRuleDisplayName:'Disk space under 5% - Windows Arc'
    alertRuleName:'DiskSpaceUnderPercentCriticalWinArc'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
    InsightsMetrics| where Namespace == 'LogicalDisk'    and Name == 'FreeSpacePercentage'    and Origin == "vm.azm.ms"| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])| where Val < 5 //would use a low value...| summarize by _ResourceId,Computer, Disk, Val| where Disk notcontains "snap"'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1
    '''
  }

  {
    alertRuleDescription: 'Heartbeat alert for Windows VMs - 5 minutes'
    alertRuleDisplayName:'Heartbeat alert for Windows VMs'
    alertRuleName:'HeartbeatAlertWinVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics| where Namespace == 'Computer' and Name == 'Heartbeat'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)
      ) on Computer  | where OS=~'Windows'  | project-away Computer1
      '''
  }
  {
    alertRuleDescription: 'Heartbeat alert for Windows Arc - 5 minutes'
    alertRuleDisplayName:'Heartbeat alert for Windows Arc'
    alertRuleName:'HeartbeatAlertWinArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics| where Namespace == 'Computer' and Name == 'Heartbeat'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)
      ) on Computer  | where OS=~'Windows'  | project-away Computer1
      '''
  }

  {
    alertRuleDescription: 'Alert for CPU usage over 90%'
    alertRuleDisplayName:'CPU usage over 90%'
    alertRuleName:'CPUUsageOverPercentWarningWinVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (InsightsMetrics| where Namespace == 'Processor'    and Name == 'UtilizationPercentage'    and Origin == "vm.azm.ms"| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])| where Val > 90 //would use a low value...| summarize by _ResourceId,Computer, Val'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1'''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 90% - Windows Arc'
    alertRuleDisplayName:'CPU usage over 90% - Windows Arc'
    alertRuleName:'CPUUsageOverPercentWarningWinArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (InsightsMetrics| where Namespace == 'Processor'    and Name == 'UtilizationPercentage'    and Origin == "vm.azm.ms"| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])| where Val > 90 //would use a low value...| summarize by _ResourceId,Computer, Val'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 95%'
    alertRuleDisplayName:'CPU usage over 95% - Windows VMs'
    alertRuleName:'CPUUsageOverPercentcriticalWinVMs'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics| where Namespace == 'Processor'    and Name == 'UtilizationPercentage'    and Origin == "vm.azm.ms"| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])| where Val > 95 //would use a low value...| summarize by _ResourceId,Computer, Val'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 95% - Windows Arc'
    alertRuleDisplayName:'CPU usage over 95% - Windows Arc'
    alertRuleName:'CPUUsageOverPercentcriticalWinArc'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    windowSize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics| where Namespace == 'Processor'    and Name == 'UtilizationPercentage'    and Origin == "vm.azm.ms"| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])| where Val > 95 //would use a low value...| summarize by _ResourceId,Computer, Val'
    ) on Computer  | where OS=~'Windows'  | project-away Computer1
    '''
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

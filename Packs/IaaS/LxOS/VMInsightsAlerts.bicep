param location string
param workspaceId string
param AGId string
param packtag string
param Tags object
param instanceName string
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
var moduleprefix = 'AMP-${instanceName}-${packtag}'

// New Arg integrated list:
var alertlist = [
  {
    alertRuleDescription: 'Alert for Memory over 90%'
    alertRuleDisplayName:'Memory over 90% - Warning - Linux VMs'
    alertRuleName:'MemoveryOverPercentWarningLxVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
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
    | where OS=~'Linux'
    | project-away Computer1   
    '''
  }
  {
    alertRuleDescription: 'Alert for Memory over 90%'
    alertRuleDisplayName:'Memory over 90% - Warning - Linux Arc'
    alertRuleName:'MemoveryOverPercentWarningLxArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
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
    | where OS=~'Linux'
    | project-away Computer1  
    '''
  }
  '''
  arg("").resources
| where type =~ 'microsoft.hybridcompute/machines'
| project Computer=tolower(name), OS=tolower(properties.osType)

'''
  {
    alertRuleDescription: 'Alert for disk space under 10% - Linux VMs'
    alertRuleDisplayName:'Disk space under 10% - Linux VMs'
    alertRuleName:'DiskSpaceUnderPercentWarningLxVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 10 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
      ) on Computer
    | where OS=~'Linux'
    | project-away Computer1
  '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 10% - Linux Arc'
    alertRuleDisplayName:'Disk space under 10% - Linux Arc'
    alertRuleName:'DiskSpaceUnderPercentWarningLxArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 10 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
      ) on Computer
    | where OS=~'Linux'
    | project-away Computer1
  '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 5% - Linux VMs'
    alertRuleDisplayName:'Disk space under 5% - Linux VMs'
    alertRuleName:'DiskSpaceUnderPercentCriticalLxVMs'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
    InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 5 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for disk space under 5% - Linux Arc'
    alertRuleDisplayName:'Disk space under 5% - Linux Arc'
    alertRuleName:'DiskSpaceUnderPercentCriticalLxArc'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
    InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 5 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }

  {
    alertRuleDescription: 'Heartbeat alert for Linux VMs - 5 minutes'
    alertRuleDisplayName:'Heartbeat alert for Linux VMs'
    alertRuleName:'HeartbeatAlertLxVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    Linuxize: 'PT5M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics| where Namespace == \'Computer\' and Name == \'Heartbeat\'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)'
      ) on Computer  | where OS=~'Linux'  | project-away Computer1
      '''
  }
  {
    alertRuleDescription: 'Heartbeat alert for Linux Arc - 5 minutes'
    alertRuleDisplayName:'Heartbeat alert for Linux Arc'
    alertRuleName:'HeartbeatAlertLxArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    Linuxize: 'PT5M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics| where Namespace == \'Computer\' and Name == \'Heartbeat\'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)'
      ) on Computer  | where OS=~'Linux'  | project-away Computer1
      '''
  }

  {
    alertRuleDescription: 'Alert for CPU usage over 90%'
    alertRuleDisplayName:'CPU usage over 90%'
    alertRuleName:'CPUUsageOverPercentWarningLxVMs'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 90 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 90% - Linux Arc'
    alertRuleDisplayName:'CPU usage over 90% - Linux Arc'
    alertRuleName:'CPUUsageOverPercentWarningLxArc'
    alertRuleSeverity:2 //warning
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query:   '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 90 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 95%'
    alertRuleDisplayName:'CPU usage over 95% - Linux VMs'
    alertRuleName:'CPUUsageOverPercentcriticalLxVMs'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.compute/virtualmachines'
    | project Computer=name, OS=properties.storageProfile.osDisk.osType
    | join (
      InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 95 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }
  {
    alertRuleDescription: 'Alert for CPU usage over 95% - Linux Arc'
    alertRuleDisplayName:'CPU usage over 95% - Linux Arc'
    alertRuleName:'CPUUsageOverPercentcriticalLxArc'
    alertRuleSeverity:1 //critical
    autoMitigate: true
    evaluationFrequency: 'PT15M'
    Linuxize: 'PT15M'
    alertType: 'rows'
    query: '''
    arg("").resources
    | where type =~ 'microsoft.hybridcompute/machines'
    | project Computer=tolower(name), OS=tolower(properties.osType)
    | join (
      InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 95 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
    ) on Computer  | where OS=~'Linux'  | project-away Computer1
    '''
  }
]


//var moduleprefix = 'AMSP-Lx-VMI'
// Alert list
// var alertlist = [
//   {
//     alertRuleDescription: 'Alert for Memory over 90%'
//     alertRuleDisplayName:'Memory over 90%'
//     alertRuleName:'MemoveryOverPercentWarning'
//     alertRuleSeverity:2 //warning
//     autoMitigate: true
//     evaluationFrequency: 'PT15M'
//     Linuxize: 'PT15M'
//     alertType: 'Aggregated'
//     metricMeasureColumn: 'AvgMemUse'
//     operator: 'GreaterThan'
//     threshold: 90
//     query: 'InsightsMetrics | where Namespace == "Memory" and Name == "AvailableMB" | extend memorySizeMB = todouble(parse_json(Tags).["vm.azm.ms/memorySizeMB"]) | extend PercentageBytesinUse = Val/memorySizeMB*100    | summarize AvgMemUse = avg(PercentageBytesinUse) by bin(TimeGenerated, 15m), _ResourceId,Computer'  
//   }
//   {
//     alertRuleDescription: 'Alert for disk space under 10%'
//     alertRuleDisplayName:'Disk space under 10%'
//     alertRuleName:'DiskSpaceUnderPercentWarning'
//     alertRuleSeverity:2 //warning
//     autoMitigate: true
//     evaluationFrequency: 'PT15M'
//     Linuxize: 'PT15M'
//     alertType: 'rows'
//     query: 'InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 10 //would use a low value...\n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
//   }
//   {
//     alertRuleDescription: 'Alert for disk space under 5%'
//     alertRuleDisplayName:'Disk space under 5%'
//     alertRuleName:'DiskSpaceUnderPercentCritical'
//     alertRuleSeverity:1 //critical
//     autoMitigate: true
//     evaluationFrequency: 'PT15M'
//     Linuxize: 'PT15M'
//     alertType: 'rows'
//     query: 'InsightsMetrics\n| where Namespace == \'LogicalDisk\'\n    and Name == \'FreeSpacePercentage\'\n    and Origin == "vm.azm.ms"\n| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])\n| where Val < 5 \n| summarize by _ResourceId,Computer, Disk, Val\n| where Disk notcontains "snap"\n\n'
//   }
//   {
//     alertRuleDescription: 'Heartbeat alert for VMs - 5 minutes'
//     alertRuleDisplayName:'Heartbeat alert for VMs'
//     alertRuleName:'HeartbeatAlert'
//     alertRuleSeverity:2 //warning
//     autoMitigate: true
//     evaluationFrequency: 'PT5M'
//     Linuxize: 'PT5M'
//     alertType: 'rows'
//     query: 'InsightsMetrics| where Namespace == \'Computer\' and Name == \'Heartbeat\'| summarize arg_max(TimeGenerated, *) by _ResourceId, Computer| where TimeGenerated < ago(5m)'
//   }
//   {
//     alertRuleDescription: 'Alert for CPU usage over 90%'
//     alertRuleDisplayName:'CPU usage over 90%'
//     alertRuleName:'CPUUsageOverPercentWarning'
//     alertRuleSeverity:2 //warning
//     autoMitigate: true
//     evaluationFrequency: 'PT15M'
//     Linuxize: 'PT15M'
//     alertType: 'rows'
//     query: 'InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 90 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
//   }
//   {
//     alertRuleDescription: 'Alert for CPU usage over 95%'
//     alertRuleDisplayName:'CPU usage over 95%'
//     alertRuleName:'CPUUsageOverPercentcritical'
//     alertRuleSeverity:1 //critical
//     autoMitigate: true
//     evaluationFrequency: 'PT15M'
//     Linuxize: 'PT15M'
//     alertType: 'rows'
//     query: 'InsightsMetrics\n| where Namespace == \'Processor\'\n    and Name == \'UtilizationPercentage\'\n    and Origin == "vm.azm.ms"\n| extend Computer=tostring(todynamic(Tags)["vm.azm.ms/computer"])\n| where Val > 95 //would use a low value...\n| summarize by _ResourceId,Computer, Val\n\n'
//   }
// ]
module alertsnew '../../../modules/alerts/alerts.bicep' = {
  name: '${moduleprefix}-Alerts'
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

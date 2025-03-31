
param location string
param workspaceId string
param AGId string
param packtag string
param Tags object
param instanceName string
//var moduleprefix = 'AMSP-Win-VMI'
var moduleprefix = 'AMP-${instanceName}-${packtag}'

var alertlist = [  
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Data Disk Read Latency (ms)'
    alertRuleDisplayName: 'Data Disk Read Latency (ms)'
    alertRuleName:'DataDiskReadLatency(ms)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 30
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk" and Name == "ReadLatencyMs"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| where Disk !in ('C:','/')
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Data Disk Free Space Percentage'
    alertRuleDisplayName: 'Data Disk Free Space Percentage'
    alertRuleName:'DataDiskFreeSpacePercentage'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'LessThan'
    threshold: 10
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk"and Name == "FreeSpacePercentage"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| where Disk !in ('C:','/')
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Data Disk Write Latency (ms)'
    alertRuleDisplayName: 'Data Disk Write Latency (ms)'
    alertRuleName:'DataDiskWriteLatency(ms)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 30
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk" and Name == "WriteLatencyMs"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| where Disk !in ('C:','/')
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated,15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Network Read (bytes-sec)'
    alertRuleDisplayName: 'Network Read (bytes-sec)'
    alertRuleName:'NetworkRead(bytes-sec)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 10000000
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Network" and Name == "ReadBytesPerSecond"
| extend NetworkInterface=tostring(todynamic(Tags)["vm.azm.ms/networkDeviceId"])
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, NetworkInterface
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Network Write (bytes-sec)'
    alertRuleDisplayName: 'Network Write (bytes-sec)'
    alertRuleName:'NetworkWrite(bytes-sec)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 10000000
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Network" and Name == "WriteBytesPerSecond"
| extend NetworkInterface=tostring(todynamic(Tags)["vm.azm.ms/networkDeviceId"])
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, NetworkInterface
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Data OS Read Latency (ms)'
    alertRuleDisplayName: 'OS Disk Read Latency (ms)'
    alertRuleName:'OSDiskReadLatency(ms)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 30
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk" and Name == "ReadLatencyMs"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine OS Disk Free Space Percentage'
    alertRuleDisplayName: 'OS Disk Free Space Percentage'
    alertRuleName:'OSDiskFreeSpacePercentage'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'LessThan'
    threshold: 10
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk" and Name == "FreeSpacePercentage"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine OS Disk Write Latency (ms)'
    alertRuleDisplayName: 'OS Disk Write Latency (ms)'
    alertRuleName:'OSDiskWriteLatency(ms)'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 50
    dimensions: [
      {
        name: 'Computer'
        operator: 'Include'
        values: [
          '*'
        ]
      }
      {
        name: 'Disk'
        operator: 'Include'
        values: [
          '*'
        ]
      }
    ]
    query: '''
    InsightsMetrics| where Origin == "vm.azm.ms"
| where Namespace == "LogicalDisk" and Name == "WriteLatencyMs"
| extend Disk=tostring(todynamic(Tags)["vm.azm.ms/mountId"])
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId, Disk
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Processor Utilization Percentage'
    alertRuleDisplayName: 'Processor Utilization Percentage'
    alertRuleName:'ProcessorUtilizationPercentage'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'GreaterThan'
    threshold: 85
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Processor" and Name == "UtilizationPercentage"
| summarize AggregatedValue = avg(Val) by bin(TimeGenerated, 15m), Computer, _ResourceId
'''
  }
  {
    alertRuleDescription: 'Log Alert for Virtual Machine Available Memory Percentage'
    alertRuleDisplayName: 'Available Memory Percentage'
    alertRuleName:'AvailableMemoryPercentage'
    alertRuleSeverity: 2
    autoMitigate: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    alertType: 'Aggregated'
    metricMeasureColumn: 'AggregatedValue'
    operator: 'LessThan'
    threshold: 10
    query: '''
    InsightsMetrics
| where Origin == "vm.azm.ms"
| where Namespace == "Memory" and Name == "AvailableMB"
| extend TotalMemory = toreal(todynamic(Tags)["vm.azm.ms/memorySizeMB"])
| extend AvailableMemoryPercentage = (toreal(Val) / TotalMemory) * 100.0
| summarize AggregatedValue = avg(AvailableMemoryPercentage) by bin(TimeGenerated, 15m), Computer, _ResourceId
'''
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
    Tags: Tags
    workspaceId: workspaceId
  }
}


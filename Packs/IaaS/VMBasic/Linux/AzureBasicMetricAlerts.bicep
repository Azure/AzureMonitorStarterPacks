param vmIDs array
var vmNames = [for (vmID, i) in vmIDs: split(vmID, '/')[8]]

// This is a metric based alert. No need for DCR
// These are the metrics recommended for all VMs in the portal
module vmmetricalertcpu '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs: if (contains(vmID, 'Microsoft.Compute/virtualMachines')){
  name: 'AzMPacks-cpualert-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-Percent_CPU_Alert-${vmNames[i]}'
    metricName: 'Percentage CPU'
    operator: 'GreaterThan' //default
    threshold: 80
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    location: 'global'
  }
}]

module vmmetricalertOSDiskIOPS '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs:if (contains(vmID, 'Microsoft.Compute/virtualMachines')) {
  name: 'AzMPacks-vmmetricalertOSDiskIOPS-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-OS Disk IOPS Consumed Percentage-${vmNames[i]}'
    metricName: 'OS Disk IOPS Consumed Percentage'
    operator: 'GreaterThan' //default
    threshold: 95
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    location: 'global'
  }
}]
module NetworkOutTotal '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs:if (contains(vmID, 'Microsoft.Compute/virtualMachines')) {
  name: 'AzMPacks-Network-Out-Total-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-Network Out Total-${vmNames[i]}'
    metricName: 'Network Out Total'
    operator: 'GreaterThan' //default
    threshold: 200000000000
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    timeAggregation: 'Total'
    location: 'global'
  }
}]
module NetworkInTotal '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs: if (contains(vmID, 'Microsoft.Compute/virtualMachines')){
  name: 'AzMPacks-Network-In-Total-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-Network In Total-${vmNames[i]}'
    metricName: 'Network In Total'
    operator: 'GreaterThan' //default
    threshold: 500000000000
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    timeAggregation: 'Total' //default is Average
    location: 'global'
  }
}]
module AvailableMemoryBytes '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs: if (contains(vmID, 'Microsoft.Compute/virtualMachines')){
  name: 'AzMPacks-Available_Memory_Bytes-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-Available Memory Bytes-${vmNames[i]}'
    metricName: 'Available Memory Bytes'
    operator: 'GreaterThan' //default
    threshold: 1000000000
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    timeAggregation: 'Average' //default is Average
    location: 'global'
  }
}]
module VMAvailability '../../../../modules/alerts/vmmetricalert.bicep' = [for (vmID, i) in vmIDs:if (contains(vmID, 'Microsoft.Compute/virtualMachines')) {
  name: 'AzMPacks-VM_Availability-${vmNames[i]}' 
  params: {
    alertrulename: 'AzMPacks-VM Availability-${vmNames[i]}'
    metricName: 'VmAvailabilityMetric'
    operator: 'LessThan' //default is GreaterThan
    threshold: 1
    vmId: vmID
    evaluationFrequency: 'PT5M' //default
    windowSize: 'PT5M' //default
    metricNamespace: 'Microsoft.Compute/virtualMachines' //default
    timeAggregation: 'Average' //default is Average
    location: 'global'
  }
}]

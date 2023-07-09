//param vmnames array
param vmIDs array = []
param vmOSs array = []
//param arcVMIDs array = []
param rulename string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
param enableBasicVMPlatformAlerts bool = false
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
param osTarget string

//var vmNames = [for (vmID, i) in vmIDs: split(vmID, '/')[8]]
//var arcVMNames = [for (vmID, i) in arcVMIDs: split(vmID, '/')[8]]

// Action Group
module ag '../../../../modules/actiongroups/ag.bicep' = {
  name: actionGroupName
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    //location: location defailt is global
  }
}

// resource age 'Microsoft.Insights/actionGroups@2018-09-01-preview' existing = if (useExistingAG) {
//   name: actionGroupName
//   scope: subscription()
// }
// Alerts - Event viewer based alerts. Depend on the event viewer logs being enabled on the VMs events are being sent to the workspace via DCRs.
module eventAlerts './eventAlerts.bicep' = {
  name: 'eventAlerts'
  params: {
    AGId: ag.outputs.actionGroupResourceId
    location: location
    workspaceId: workspaceId
  }
} 

module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'InsightsAlerts'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
  }
}

// Azure recommended Alerts for VMs
// These are the (very) basic recommeded alerts for VM, based on platform metrics
module vmrecommended 'AzureBasicMetricAlerts.bicep' = if (enableBasicVMPlatformAlerts) {
  name: 'vmrecommended'
  params: {
    vmIDs: vmIDs
  }
}
// DCR
// Example of a DCR for a Linux VM collecting eventviewer and performance counters
// This rule would be useful to add any counters that are not covered by VM Insights, as well as Event Viewer logs
module dcrbasicvmMonitoring '../../../../modules/DCRs/dcr-basicLinuxVM.bicep' = {
  name: 'dcrPerformance'
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: 'Linux'
    counterSpecifiers: [
      'Processor(*)\\% Processor Time'
      'Processor(*)\\% Idle Time'
      'Processor(*)\\% User Time'
      'Processor(*)\\% Nice Time'
      'Processor(*)\\% Privileged Time'
      'Processor(*)\\% IO Wait Time'
      'Processor(*)\\% Interrupt Time'
      'Processor(*)\\% DPC Time'
      'Memory(*)\\Available MBytes Memory'
      'Memory(*)\\% Available Memory'
      'Memory(*)\\Used Memory MBytes'
      'Memory(*)\\% Used Memory'
      'Memory(*)\\Pages/sec'
      'Memory(*)\\Page Reads/sec'
      'Memory(*)\\Page Writes/sec'
      'Memory(*)\\Available MBytes Swap'
      'Memory(*)\\% Available Swap Space'
      'Memory(*)\\Used MBytes Swap Space'
      'Memory(*)\\% Used Swap Space'
      'Logical Disk(*)\\% Free Inodes'
      'Logical Disk(*)\\% Used Inodes'
      'Logical Disk(*)\\Free Megabytes'
      'Logical Disk(*)\\% Free Space'
      'Logical Disk(*)\\% Used Space'
      'Logical Disk(*)\\Logical Disk Bytes/sec'
      'Logical Disk(*)\\Disk Read Bytes/sec'
      'Logical Disk(*)\\Disk Write Bytes/sec'
      'Logical Disk(*)\\Disk Transfers/sec'
      'Logical Disk(*)\\Disk Reads/sec'
      'Logical Disk(*)\\Disk Writes/sec'
      'Network(*)\\Total Bytes Transmitted'
      'Network(*)\\Total Bytes Received'
      'Network(*)\\Total Bytes'
      'Network(*)\\Total Packets Transmitted'
      'Network(*)\\Total Packets Received'
      'Network(*)\\Total Rx Errors'
      'Network(*)\\Total Tx Errors'
      'Network(*)\\Total Collisions'
  ]
  }
}

// This associates the rule above to the VMs
module dcrassociation '../../../../modules/DCRs/dcrassociation.bicep'  =   [for (vmID, i) in vmIDs: {
  name: 'dcrassociation-${i}'
  params: {
    osTarget: osTarget
    vmOS: vmOSs[i]
    associationName: 'dcrassociation-${i}-${split(vmID, '/')[8]}'
    dataCollectionRuleId: dcrbasicvmMonitoring.outputs.dcrId
    vmId: vmID
  }
}]



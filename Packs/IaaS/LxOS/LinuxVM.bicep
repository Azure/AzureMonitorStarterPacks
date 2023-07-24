//param vmnames array
param vmIDs array = []
//param vmOSs array = []
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
//param osTarget string
param packtag string
param solutionTag string
param solutionVersion string

// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
  name: actionGroupName
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    solutionTag: solutionTag
    //location: location defailt is global
  }
}
// resource age 'Microsoft.Insights/actionGroups@2018-09-01-preview' existing = if (useExistingAG) {
//   name: actionGroupName
//   scope: subscription()
// }
// Alerts - Event viewer based alerts. Depend on the event viewer logs being enabled on the VMs events are being sent to the workspace via DCRs.
// module eventAlerts './eventAlerts.bicep' = {
//   name: 'eventAlerts'
//   params: {
//     AGId: ag.outputs.actionGroupResourceId
//     location: location
//     workspaceId: workspaceId
//     packtag: packtag
//     solutionTag: solutionTag
//   }
// } 

// This option uses an existing VMI rule but this can be a tad problematic.
// resource vmInsightsDCR 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' existing = if(enableInsightsAlerts == 'true') {
//   name: insightsRuleName
//   scope: resourceGroup(insightsRuleRg)
// }
// So, let's create an Insights rule for the VMs that should be the same as the usual VMInsights.
module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
  name: 'vmInsightsDCR-${packtag}'
  params: {
    location: location
    workspaceResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    ruleName: rulename
  }
}
module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
// Azure recommended Alerts for VMs
// These are the (very) basic recommeded alerts for VM, based on platform metrics
// module vmrecommended '../WinOS/AzureBasicMetricAlerts.bicep' = if (enableBasicVMPlatformAlerts) {
//   name: 'vmrecommended'
//   params: {
//     vmIDs: vmIDs
//     packtag: packtag
//     solutionTag: solutionTag

//   }
// }
// DCR
// Example of a DCR for a Linux VM collecting eventviewer and performance counters
// This rule would be useful to add any counters that are not covered by VM Insights, as well as Event Viewer logs
// module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicLinuxVM.bicep' = {
//   name: 'dcrPerformance'
//   params: {
//     location: location
//     rulename: rulename
//     workspaceId: workspaceId
//     wsfriendlyname: workspaceFriendlyName
//     kind: 'Linux'
//     packtag: packtag
//     solutionTag: solutionTag
//     counterSpecifiers: [
//       'Processor(*)\\% Processor Time'
//       'Processor(*)\\% Idle Time'
//       'Processor(*)\\% User Time'
//       'Processor(*)\\% Nice Time'
//       'Processor(*)\\% Privileged Time'
//       'Processor(*)\\% IO Wait Time'
//       'Processor(*)\\% Interrupt Time'
//       'Processor(*)\\% DPC Time'
//       'Memory(*)\\Available MBytes Memory'
//       'Memory(*)\\% Available Memory'
//       'Memory(*)\\Used Memory MBytes'
//       'Memory(*)\\% Used Memory'
//       'Memory(*)\\Pages/sec'
//       'Memory(*)\\Page Reads/sec'
//       'Memory(*)\\Page Writes/sec'
//       'Memory(*)\\Available MBytes Swap'
//       'Memory(*)\\% Available Swap Space'
//       'Memory(*)\\Used MBytes Swap Space'
//       'Memory(*)\\% Used Swap Space'
//       'Logical Disk(*)\\% Free Inodes'
//       'Logical Disk(*)\\% Used Inodes'
//       'Logical Disk(*)\\Free Megabytes'
//       'Logical Disk(*)\\% Free Space'
//       'Logical Disk(*)\\% Used Space'
//       'Logical Disk(*)\\Logical Disk Bytes/sec'
//       'Logical Disk(*)\\Disk Read Bytes/sec'
//       'Logical Disk(*)\\Disk Write Bytes/sec'
//       'Logical Disk(*)\\Disk Transfers/sec'
//       'Logical Disk(*)\\Disk Reads/sec'
//       'Logical Disk(*)\\Disk Writes/sec'
//       'Network(*)\\Total Bytes Transmitted'
//       'Network(*)\\Total Bytes Received'
//       'Network(*)\\Total Bytes'
//       'Network(*)\\Total Packets Transmitted'
//       'Network(*)\\Total Packets Received'
//       'Network(*)\\Total Rx Errors'
//       'Network(*)\\Total Tx Errors'
//       'Network(*)\\Total Collisions'
//   ]
//   }
// }
module policysetup '../../../modules/policies/subscription/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: vmInsightsDCR.outputs.VMIRuleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
  }
}

// module policysetup2 '../../../modules/policies/subscription/policies.bicep' = {
//   name: 'policysetup-${packtag}'
//   params: {
//     dcrId: dcrbasicvmMonitoring.outputs.dcrId
//     packtag: packtag
//     solutionTag: solutionTag
//     rulename: rulename
//     location: location
//   }
// }



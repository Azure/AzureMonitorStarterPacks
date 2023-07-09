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
param osTarget string
param enableInsightsAlerts bool = false
param insightsRuleName string = '' // This will be used to associate the VMs to the rule, only used if enableInsightsAlerts is true
param insightsRuleRg string = ''
param packtag string
// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
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

// Alerts - Event viewer based alerts. Depend on the event viewer logs being enabled on the VMs events are being sent to the workspace via DCRs.
module eventAlerts 'eventAlerts.bicep' = {
  name: 'eventAlerts'
  params: {
    AGId: ag.outputs.actionGroupResourceId
    location: location
    workspaceId: workspaceId
    packtag: packtag
  }
} 

module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'InsightsAlerts'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
  }
}

// Azure recommended Alerts for VMs
// These are the (very) basic recommeded alerts for VM, based on platform metrics
module vmrecommended 'AzureBasicMetricAlerts.bicep' = if (enableBasicVMPlatformAlerts) {
  name: 'vmrecommended'
  params: {
    vmIDs: vmIDs
    packtag: packtag
  }
}
// DCR
// Example of a DCR for a Windows VM collecting eventviewer and performance counters
// This rule would be useful to add any counters that are not covered by VM Insights, as well as Event Viewer logs
// module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
//   name: 'dcrPerformance'
//   params: {
//     location: location
//     rulename: rulename
//     workspaceId: workspaceId
//     wsfriendlyname: workspaceFriendlyName
//     kind: 'Windows'
//     packtag: packtag
//     xPathQueries: [
//       'System!*[System[Provider[@Name=\'Microsoft-Windows-Eventlog\'] and (EventID=6000)]]'
//       'System!*[System[Provider[@Name=\'Microsoft-Windows-TCPIP\'] and (EventID=4198 or EventID=4199)]]'
//       'System!*[System[Provider[@Name=\'Microsoft-Windows-DISK\'] and (EventID=31)]]'
//       'System!*[System[Provider[@Name=\'Microsoft-Windows-DISK\' or @Name=\'Microsoft-Windows-Ntfs\'] and (EventID=11 or EventID=50)]]'
//       'System!*[System[Provider[@Name=\'Microsoft-Windows-Time-Service\'] and (Level=2) and (EventID=34]]'
//       'System!*[System[Provider[@Name=\'VSS\'] and (EventID=8194)]]'
//       'System!*[System[Provider[@Name=\'volmgr\'] and (Level=1  or Level=2) and (EventID=46)]]'
//       'System!*[System[(Level=4 or Level=0) and (EventID=7036)]]'
//     ]
//     counterSpecifiers: [
//       '\\LogicalDisk(*)\\Avg. Disk sec/Transfer'
//       '\\LogicalDisk(*)\\Current Disk Queue Length'
//       '\\LogicalDisk(*)\\% Idle Time'
//       '\\Network Adapter(*)\\Bytes Total/sec'
//       '\\Memory\\Pages/sec'
//       '\\System\\Processor Queue Length'
//       '\\Processor Information(*)\\% Processor Time'
//       '\\PhysicalDisk(*)\\Avg. Disk sec/Transfer'
//       '\\PhysicalDisk(*)\\Current Disk Queue Length'
//       '\\Processor(*)\\% Processor Time'
//       '\\LogicalDisk(*)\\Free Megabytes'
//       '\\LogicalDisk(*)\\% Free Space'
//       '\\Memory\\Available MBytes'
//       '\\Memory\\Pool Nonpaged Bytes'
//       '\\Memory\\Pool Paged Bytes'
//       '\\Memory\\Free System Page Table Entries'
//   ]
//   }
// }
resource vmInsightsDCR 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' existing = if(enableInsightsAlerts) {
  name: insightsRuleName
  scope: resourceGroup(insightsRuleRg)
}
// This associates the rule above to the VMs
// module dcrassociation '../../../modules/DCRs/dcrassociation.bicep'  =   [for (vmID, i) in vmIDs: if(enableInsightsAlerts) {
//   name: 'dcrassociation-${i}'
//   params: {
//     osTarget: osTarget
//     vmOS: osTarget
//     associationName: 'dcrassociation-${i}-${split(vmID, '/')[8]}'
//     dataCollectionRuleId: vmInsightsDCR.id
//     vmId: vmID
//   }
// }]
module policy '../../../modules/policies/subscription/associacionpolicy.bicep' = {
  name: 'associationpolicy'
  scope: subscription()
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${insightsRuleName} DCR with the VMs tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${insightsRuleName} DCR with the VMs tagged with ${packtag} tag.'
    policyName: 'associate-${insightsRuleName}-${packtag}'
    DCRId: vmInsightsDCR.id
  }
}
// module vmInsightsAssociation '../../../modules/DCRs/dcrassociation.bicep'  =   [for (vmID, i) in vmIDs: {
//   name: 'vmidcrassociation-${i}'
//   params: {
//     osTarget: osTarget
//     vmOS: osTarget
//     associationName: 'dcrassociation-${i}-${split(vmID, '/')[8]}'
//     dataCollectionRuleId: vmInsightsDCR.id
//     vmId: vmID
//   }
// }]


param rulename string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
//param enableBasicVMPlatformAlerts bool = false
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
//param osTarget string
param packtag string
param solutionTag string
param solutionVersion string

var facilityNames = [
  'daemon'
]
var logLevels =[
  'Debug'
  'Info'
  'Notice'
  'Warning'
  'Error'
  'Critical'
  'Alert'
  'Emergency'
]

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

module dataCollectionEndpoint '../../../modules/DCRs/dataCollectionEndpoint.bicep' = {
 name: 'dataCollectionEndpoint-${solutionTag}'
 params: {
   location: location
   packtag: packtag
   solutionTag: solutionTag
   dceName: 'dataCollectionEndpoint-${solutionTag}'
 }
}

module fileCollectionRule '../../../modules/DCRs/filecollectionSyslogLinux.bicep' = {
  name: 'filecollectionrule-${packtag}'
  params: {
    location: location
    endpointResourceId: dataCollectionEndpoint.outputs.dceId
    packtag: packtag
    solutionTag: solutionTag
    ruleName: rulename
    filepatterns: [
      '/var/log/nginx/access.log'
      '/var/log/nginx/error.log'
    ]
    lawResourceId:workspaceId
    tableName: 'NginxLogs'
    facilityNames: facilityNames
    logLevels: logLevels
    syslogDataSourceName: 'NginxLogs-1238219'
  }
}
module Alerts './nginxalerts.bicep' = {
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
    dcrId: fileCollectionRule.outputs.ruleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
  }
}

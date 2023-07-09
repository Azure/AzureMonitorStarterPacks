param vmIDs array = []
param rulename string
param actionGroupName string = ''
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
param osTarget string
var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  
]
// The performance counters define which counters are collected
var performanceCounters=[
  '\\SQLServer:Databases(_Total)\\Transactions/sec'
  '\\SQLServer:Locks(_Total)\\Average Wait Time (ms)'
  '\\SQLServer:Buffer Manager(_Total)\\Buffer cache hit ratio'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. Bytes/Read'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. Bytes/Transfer'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. Bytes/Write'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. microsec/Read'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. microsec/Read Comp'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. microsec/Transfer'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. microsec/Write'
  // '\\SQLServer:HTTP Storage(_Total)\\Avg. microsec/Write Comp'
  // '\\SQLServer:HTTP Storage(_Total)\\HTTP Storage IO failed/sec'
  // '\\SQLServer:HTTP Storage(_Total)\\HTTP Storage IO retry/sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Outstanding HTTP Storage IO'
  // '\\SQLServer:HTTP Storage(_Total)\\Read Bytes/Sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Reads/Sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Total Bytes/Sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Transfers/Sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Write Bytes/Sec'
  // '\\SQLServer:HTTP Storage(_Total)\\Writes/Sec'
  '\\SQLServer:Locks(_Total)\\Lock Requests/sec'
  '\\SQLServer:Locks(_Total)\\Lock Timeouts/sec'
  '\\SQLServer:Locks(_Total)\\Lock Waits/sec'
  '\\SQLServer:General Statistics(_Total)\\Logins/sec'
  // '\\SQLServer:Locks(_Total)\\Number of Deadlocks/sec'
  // '\\SQLServer:Buffer Manager(_Total)\\Page life expectancy'
  // '\\SQLServer:Broker Activation(_Total)\\Stored Procedures Invoked/sec'
  // '\\SQLServer:Broker Activation(_Total)\\Task Limit Reached'
  // '\\SQLServer:Broker Activation(_Total)\\Task Limit Reached/sec'
  // '\\SQLServer:Broker Activation(_Total)\\Tasks Aborted/sec'
  // '\\SQLServer:Broker Activation(_Total)\\Tasks Running'
  // '\\SQLServer:Broker Activation(_Total)\\Tasks Started/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Current Bytes for Recv I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Current Bytes for Send I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Current Msg Frags for Send I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P10 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P1 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P2 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P3 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P4 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P5 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P6 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P7 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P8 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment P9 Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment Receives/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Message Fragment Sends/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Msg Fragment Recv Size Avg'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Msg Fragment Send Size Avg'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Open Connection Count'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Pending Bytes for Recv I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Pending Bytes for Send I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Pending Msg Frags for Recv I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Pending Msg Frags for Send I/O'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Receive I/O bytes/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Receive I/O Len Avg'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Receive I/Os/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Recv I/O Buffer Copies bytes/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Recv I/O Buffer Copies Count'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Send I/O bytes/sec'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Send I/O Len Avg'
  // '\\SQLServer:Broker/DBM Transport(_Total)\\Send I/Os/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Activation Errors Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Broker Transaction Rollbacks'
  // '\\SQLServer:Broker Statistics(_Total)\\Corrupted Messages Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Dequeued TransmissionQ Msgs/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Dialog Timer Event Count'
  // '\\SQLServer:Broker Statistics(_Total)\\Dropped Messages Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Local Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Local Messages Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Messages Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P10 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P1 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P2 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P3 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P4 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P5 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P6 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P7 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P8 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued P9 Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued TransmissionQ Msgs/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Transport Msg Frags/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Transport Msg Frag Tot'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Transport Msgs/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Enqueued Transport Msgs Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Messages/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Messages Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Msg Bytes/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Msg Byte Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Msg Discarded Total'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Msgs Discarded/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Pending Msg Bytes'
  // '\\SQLServer:Broker Statistics(_Total)\\Forwarded Pending Msg Count'
  // '\\SQLServer:Broker Statistics(_Total)\\SQL RECEIVEs/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\SQL RECEIVE Total'
  // '\\SQLServer:Broker Statistics(_Total)\\SQL SENDs/sec'
  // '\\SQLServer:Broker Statistics(_Total)\\SQL SEND Total'
  // '\\SQLServer:SQL Statistics(_Total)\\SQL Compilations/sec'
  // '\\SQLServer:SQL Statistics(_Total)\\SQL Re-Compilations/sec'
   '\\SQLServer:General Statistics(_Total)\\User Connections'
  // '\\SQLServer:Databases(_Total)\\XTP Controller DLC Latency/Fetch'
  // '\\SQLServer:Databases(_Total)\\XTP Controller DLC Peak Latency'
  // '\\SQLServer:Databases(_Total)\\XTP Controller Log Processed/sec'
  // '\\SQLServer:Databases(_Total)\\XTP Memory Used (KB)'
   '\\SQLServer:Resource Pool Stats(_Total)\\Active Memory grant amount (KB)'
   '\\SQLServer:Resource Pool Stats(_Total)\\Active memory grants count'
   '\\SQLServer:Resource Pool Stats(_Total)\\Cache memory target (KB)'
   '\\SQLServer:Resource Pool Stats(_Total)\\Compile Memory Target (KB)'
   '\\SQLServer:Resource Pool Stats(_Total)\\Max memory (KB)'
   '\\SQLServer:Resource Pool Stats(_Total)\\Memory grants/sec'
  // '\\SQLServer:Resource Pool Stats(_Total)\\Memory grant timeouts/sec'
  // '\\SQLServer:Resource Pool Stats(_Total)\\Pending memory grants count'
  // '\\SQLServer:Resource Pool Stats(_Total)\\Query exec memory target (KB)'
  // '\\SQLServer:Resource Pool Stats(_Total)\\Target memory (KB)'
  // '\\SQLServer:Resource Pool Stats(_Total)\\Used memory (KB)'
  // '\\SQLServer:Availability Replica(_Total)\\Bytes Received from Replica/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Bytes Sent to Replica/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Bytes Sent to Transport/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Flow Control/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Flow Control Time (ms/sec)'
  // '\\SQLServer:Availability Replica(_Total)\\Receives from Replica/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Resent Messages/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Sends to Replica/sec'
  // '\\SQLServer:Availability Replica(_Total)\\Sends to Transport/sec'
  // '\\SQLServer:Database Replica(_Total)\\File Bytes Received/sec'
  // '\\SQLServer:Database Replica(_Total)\\Log Apply Pending Queue'
  // '\\SQLServer:Database Replica(_Total)\\Log Apply Ready Queue'
  // '\\SQLServer:Database Replica(_Total)\\Log Bytes Received/sec'
  // '\\SQLServer:Database Replica(_Total)\\Log remaining for undo'
  // '\\SQLServer:Database Replica(_Total)\\Log Send Queue'
  // '\\SQLServer:Database Replica(_Total)\\Mirrored Write Transactions/sec'
  // '\\SQLServer:Database Replica(_Total)\\Recovery Queue'
  // '\\SQLServer:Database Replica(_Total)\\Redo blocked/sec'
  // '\\SQLServer:Database Replica(_Total)\\Redo Bytes Remaining'
  // '\\SQLServer:Database Replica(_Total)\\Redone Bytes/sec'
  // '\\SQLServer:Database Replica(_Total)\\Total Log requiring undo'
  // '\\SQLServer:Database Replica(_Total)\\Transaction Delay'
]

// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
module ag '../../../modules/actiongroups/ag.bicep' = {
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
// // Alerts - the module below creates the alerts and associates them with the action group
module Alerts './WinSQLAlerts.bicep' = {
  name: 'SQLAlerts'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId  
  }
}
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance'
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers: performanceCounters
  }
}
// DCR Association - the module below associates the DCR with the VMs
module dcrassociation '../../../modules/DCRs/dcrassociation.bicep'  =   [for (vmID, i) in vmIDs: {
  name: 'dcrassociation-${i}-${split(vmID, '/')[8]}-SQL'
  params: {
    osTarget: osTarget
    vmOS: osTarget //was previously the array of OSes but for each pack, it will only be applied for a specific OS, no generic cross-OS packs in sight for now.
    associationName: 'dcrassociation-${i}-${split(vmID, '/')[8]}-SQL'
    dataCollectionRuleId: dcrbasicvmMonitoring.outputs.dcrId
    vmId: vmID
  }
}]

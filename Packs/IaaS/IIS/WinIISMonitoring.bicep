//param vmIDs array = []
//param vmOSs array = []
param rulename string
param actionGroupName string = ''
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
//param osTarget string = 'Windows'
param packtag string
param solutionTag string

var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2216)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2221)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5152)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5010 or EventID=5011 or EventID=5012 or EventID=5013)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5009)]]'
  'Application!*[Application[Provider[@Name=\'Active Server Pages\'] and (EventID=500 or EventID=499 or EventID=23 or EventID=22 or EventID=21 or EventID=20 or EventID=19 or EventID=18 or EventID=17 or EventID=16 or EventID=9 or EventID=8 or EventID=7 or EventID=6 or EventID=5)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC\'] and (EventID=1037)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2208)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2206)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2201)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2203)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2204)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2274 or EventID=2268 or EventID=2220 or EventID=2219 or EventID=2214)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5088 or EventID=5061 or EventID=5060)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2296)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2295)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2293)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC\'] and (EventID=1133)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2261)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5036)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2264)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2298)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2218)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2258)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2227)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2233)]]'
  'Application!*[Application[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2226 or EventID=2230 or EventID=2231 or EventID=2232)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5174 or EventID=5179 or EventID=5180)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5085)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5054 or EventID=5091)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5063)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5058)]]'
]
// The performance counters define which counters are collected
var performanceCounters=[
  '\\Web Service(_Total)\\Bytes Received/sec'
  '\\Web Service(_Total)\\Bytes Sent/sec'
  '\\Web Service(_Total)\\Bytes Total/sec'
  '\\Web Service(_Total)\\Connection Attempts/sec'
  '\\Web Service(_Total)\\Current Connections'
  '\\Web Service(_Total)\\Total Method Requests/sec'
  '\\Microsoft FTP Service(_Total)\\Bytes Total/sec'
  '\\Microsoft FTP Service(_Total)\\Current Connections'
  '\\SMTP Server(_Total)\\Bytes Received/sec'
  '\\SMTP Server(_Total)\\Bytes Sent/sec'
  '\\SMTP Server(_Total)\\Bytes Total/sec'
  '\\SMTP Server(_Total)\\Inbound Connections Current'
  '\\SMTP Server(_Total)\\Message Bytes Received/sec'
  '\\SMTP Server(_Total)\\Message Bytes Sent/sec'
  '\\SMTP Server(_Total)\\Messages Delivered/sec'
  '\\SMTP Server(_Total)\\Messages Received/sec'
  '\\SMTP Server(_Total)\\Messages Sent/sec'
  '\\SMTP Server(_Total)\\Outbound Connections Current'
  '\\SMTP Server(_Total)\\Total Messages Submitted'
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
    solutionTag: solutionTag
    //location: location defailt is global
  }
}
// // Alerts - the module below creates the alerts and associates them with the action group
module Alerts './WinIISAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
  }
}
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance-${packtag}'
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers: performanceCounters
    packtag: packtag
    solutionTag: solutionTag
  }
}
// // DCR Association - the module below associates the DCR with the VMs
// Associtation REMOVE FOR NOW. Done by policy
// module dcrassociation '../../../modules/DCRs/dcrassociation.bicep'  =   [for (vmID, i) in vmIDs: {
//   name: 'dcrassociation-${i}-${split(vmID, '/')[8]}-IIS'
//   dependsOn: [
//     dcrbasicvmMonitoring
//   ]
//   params: {
//     osTarget: osTarget
//     vmOS: osTarget //was previously the array of OSes but for each pack, it will only be applied for a specific OS, no generic cross-OS packs in sight for now.
//     associationName: 'dcrassociation-${i}-${split(vmID, '/')[8]}-IIS'
//     dataCollectionRuleId: dcrbasicvmMonitoring.outputs.dcrId
//     vmId: vmID
//   }
// }]

module policysetup '../../../modules/policies/subscription/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: dcrbasicvmMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
  }
}
// module policyVM '../../../modules/policies/subscription/associacionpolicyVM.bicep' = {
//   name: 'associationpolicyVM'
//   scope: subscription()
//   params: {
//     packtag: packtag
//     policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
//     policyDisplayName: 'Associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
//     policyName: 'associate-${rulename}-${packtag}-vms'
//     DCRId: dcrbasicvmMonitoring.outputs.dcrId
//     solutionTag: solutionTag
//   }
// }
// module policyARC '../../../modules/policies/subscription/associacionpolicyARC.bicep' = {
//   name: 'associationpolicyARC'
//   scope: subscription()
//   params: {
//     packtag: packtag
//     policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
//     policyDisplayName: 'Associate the ${rulename} DCR with the ARC Servers tagged with ${packtag} tag.'
//     policyName: 'associate-${rulename}-${packtag}-arc'
//     DCRId: dcrbasicvmMonitoring.outputs.dcrId
//     solutionTag: solutionTag
//   }
// }
// //module policyAssignment {}
// // param policyAssignmentName string = 'audit-vm-manageddisks'
// // param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
// module arcassignment '../../../modules/policies/subscription/assignment.bicep' = {
//   name: 'arcassignment'
//   scope: subscription()
//   params: {
//     policyDefinitionId: policyARC.outputs.policyId
//     location: location
//     assignmentName: 'associate-${rulename}-${packtag}-arc'
//   }
// }
// module vmassignment '../../../modules/policies/subscription/assignment.bicep' = {
//   name: 'vmassignment'
//   scope: subscription()
//   params: {
//     policyDefinitionId: policyVM.outputs.policyId
//     assignmentName: 'associate-${rulename}-${packtag}-vm'
//     location: location
//   }
// }
// output assignmentId string = assignment.id

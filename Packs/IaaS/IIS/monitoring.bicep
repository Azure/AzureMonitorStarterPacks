targetScope='managementGroup'

@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-IIS-Server'
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'IIS'
param solutionTag string
param solutionVersion string
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string
param grafanaName string

var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'IIS1'
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2216)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2221)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5152)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5010 or EventID=5011 or EventID=5012 or EventID=5013)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5009)]]'
  'Application!*[System[Provider[@Name=\'Active Server Pages\'] and (EventID=500 or EventID=499 or EventID=23 or EventID=22 or EventID=21 or EventID=20 or EventID=19 or EventID=18 or EventID=17 or EventID=16 or EventID=9 or EventID=8 or EventID=7 or EventID=6 or EventID=5)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC\'] and (EventID=1037)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2208)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2206)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2201)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2203)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2204)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2274 or EventID=2268 or EventID=2220 or EventID=2219 or EventID=2214)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5088 or EventID=5061 or EventID=5060)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2296)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2295)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2293)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC\'] and (EventID=1133)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2261)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-WAS\'] and (EventID=5036)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2264)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2298)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2218)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2258)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2227)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2233)]]'
  'Application!*[System[Provider[@Name=\'Microsoft-Windows-IIS-W3SVC-WP\'] and (EventID=2226 or EventID=2230 or EventID=2231 or EventID=2232)]]'
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
  '\\SMTP Server(SMTP 1)\\Bytes Received/sec'
  '\\SMTP Server(SMTP 1)\\Bytes Sent/sec'
  '\\SMTP Server(SMTP 1)\\Bytes Total/sec'
  '\\SMTP Server(SMTP 1)\\Inbound Connections Current'
  '\\SMTP Server(SMTP 1)\\Message Bytes Received/sec'
  '\\SMTP Server(SMTP 1)\\Message Bytes Sent/sec'
  '\\SMTP Server(SMTP 1)\\Messages Delivered/sec'
  '\\SMTP Server(SMTP 1)\\Messages Received/sec'
  '\\SMTP Server(SMTP 1)\\Messages Sent/sec'
  '\\SMTP Server(SMTP 1)\\Outbound Connections Current'
  '\\SMTP Server(SMTP 1)\\Total Messages Submitted'
]

// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
module ag '../../../modules/actiongroups/ag.bicep' = {
  name: 'actionGroupName-deployment'
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    newRGresourceGroup: resourceGroupName
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    location: location
  }
}

// Alerts - the module below creates the alerts and associates them with the action group

module Alerts './WinIISAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
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
    dceId: dceId
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: dcrbasicvmMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: '${ruleshortname}-1'
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}

module dcrIISLogsMonitoring '../../../modules/DCRs/filecollectionWinIIS.bicep' = {
  name: 'dcrIISLogs-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    ruleName: '${rulename}-IISLogs'
    lawResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    endpointResourceId: dceId
    tableName: 'IISLogs'
  }
}
module policysetupIISLogs '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}-IISLogs'
  scope: managementGroup(mgname)
  params: {
    dcrId: dcrIISLogsMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: '${rulename}-IISLogs'
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: '${ruleshortname}-2'
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}

// // Grafana upload and install
// module grafana 'ds.bicep' = {
//   name: 'grafana'
//   scope: resourceGroup(subscriptionId, resourceGroupName)
//   params: {
//     fileName: 'grafana.json'
//     grafanaName: grafanaName
//     location: location
//     resourceGroupName: resourceGroupName
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion
//     packsManagedIdentityResourceId: userManagedIdentityResourceId
//   }
// }

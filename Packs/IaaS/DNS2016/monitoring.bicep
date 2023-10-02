targetScope='managementGroup'

param rulename string
param actionGroupName string = ''
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
param location string //= resourceGroup().location
param workspaceId string
param packtag string
param solutionTag string
param solutionVersion string
param dceId string
param userManagedIdentityResourceId string
var workspaceFriendlyName = split(workspaceId, '/')[8]

param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string

var ruleshortname = 'DNS1'
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=10)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1000)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1004)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1200)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1201)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1203)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=131)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=140)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=150)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1540)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4000)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4006)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4007)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4010)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4011)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4012)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4014)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4015)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4016)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4017)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=408)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=409)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=410)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=414)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4510)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4511)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4512)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=501)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=502)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=503)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=504)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=5051)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=6527)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=6702)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=706)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7060)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7616)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7636)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7642)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7644)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=777)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=111 or EventID=6533)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4018 or EventID=4019)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4513 or EventID=4514)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=4520 or EventID=4521)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=707 or EventID=1003)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7692 or EventID=790)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=796 or EventID=799)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=2200 or EventID=2202 or EventID=2203)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=7502 or EventID=7503 or EventID=7504)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=792 or EventID=795 or EventID=797)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=1001 or EventID=1008 or EventID=3151 or EventID=3152 or EventID=3153)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=403 or EventID=404 or EventID=405 or EventID=406 or EventID=407)]]'
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=500 or EventID=505 or EventID=506 or EventID=507 or EventID=2204)]]'
]

// The performance counters define which counters are collected
var performanceCounters=[
  '\\DNS\\AXFR Request Received'
  '\\DNS\\AXFR Request Sent'
  '\\DNS\\AXFR Response Received'
  '\\DNS\\AXFR Success Received'
  '\\DNS\\AXFR Success Sent'
  '\\DNS\\Caching Memory'
  '\\DNS\\Data Flush Pages/sec'
  '\\DNS\\Data Flushes/sec'
  '\\DNS\\Database Node Memory'
  '\\DNS\\Dynamic Update NoOperation'
  '\\DNS\\Dynamic Update NoOperation/sec'
  '\\DNS\\Dynamic Update Queued'
  '\\DNS\\Dynamic Update Received'
  '\\DNS\\Dynamic Update Received/sec'
  '\\DNS\\Dynamic Update Rejected'
  '\\DNS\\Dynamic Update TimeOuts'
  '\\DNS\\Dynamic Update Written to Database'
  '\\DNS\\Dynamic Update Written to Database/sec'
  '\\DNS\\IXFR Request Received'
  '\\DNS\\IXFR Request Sent'
  '\\DNS\\IXFR Response Received'
  '\\DNS\\IXFR Success Received'
  '\\DNS\\IXFR Success Sent'
  '\\DNS\\IXFR TCP Success Received'
  '\\DNS\\IXFR UDP Success Received'
  '\\DNS\\Nbstat Memory'
  '\\DNS\\Notify Received'
  '\\DNS\\Notify Sent'
  '\\DNS\\Query Dropped Bad Socket'
  '\\DNS\\Query Dropped Bad Socket/sec'
  '\\DNS\\Query Dropped By Policy'
  '\\DNS\\Query Dropped By Policy/sec'
  '\\DNS\\Query Dropped By Response Rate Limiting'
  '\\DNS\\Query Dropped By Response Rate Limiting/sec'
  '\\DNS\\Query Dropped Send'
  '\\DNS\\Query Dropped Send/sec'
  '\\DNS\\Query Dropped Total'
  '\\DNS\\Query Dropped Total/sec'
  '\\DNS\\Record Flow Memory'
  '\\DNS\\Recursive Queries'
  '\\DNS\\Recursive Queries/sec'
  '\\DNS\\Recursive Query Failure'
  '\\DNS\\Recursive Query Failure/sec'
  '\\DNS\\Recursive Send TimeOuts'
  '\\DNS\\Recursive TimeOut/sec'
  '\\DNS\\Responses Suppressed'
  '\\DNS\\Responses Suppressed/sec'
  '\\DNS\\Secure Update Failure'
  '\\DNS\\Secure Update Received'
  '\\DNS\\Secure Update Received/sec'
  '\\DNS\\TCP Message Memory'
  '\\DNS\\TCP Query Received'
  '\\DNS\\TCP Query Received/sec'
  '\\DNS\\TCP Response Sent'
  '\\DNS\\TCP Response Sent/sec'
  '\\DNS\\Total Query Received'
  '\\DNS\\Total Query Received/sec'
  '\\DNS\\Total Remote Inflight Queries'
  '\\DNS\\Total Response Sent'
  '\\DNS\\Total Response Sent/sec'
  '\\DNS\\UDP Message Memory'
  '\\DNS\\UDP Query Received'
  '\\DNS\\UDP Query Received/sec'
  '\\DNS\\UDP Response Sent'
  '\\DNS\\UDP Response Sent/sec'
  '\\DNS\\Unmatched Responses Received'
  '\\DNS\\WINS Lookup Received'
  '\\DNS\\WINS Lookup Received/sec'
  '\\DNS\\WINS Response Sent'
  '\\DNS\\WINS Response Sent/sec'
  '\\DNS\\WINS Reverse Lookup Received'
  '\\DNS\\WINS Reverse Lookup Received/sec'
  '\\DNS\\WINS Reverse Response Sent'
  '\\DNS\\WINS Reverse Response Sent/sec'
  '\\DNS\\Zone Transfer Failure'
  '\\DNS\\Zone Transfer Request Received'
  '\\DNS\\Zone Transfer SOA Request Sent'
  '\\DNS\\Zone Transfer Success'
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
    newRGresourceGroup: resourceGroupName
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    location: location
  }
}

// Alerts - the module below creates the alerts and associates them with the action group

module Alerts './WinDns2016Alerts.bicep' = {
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

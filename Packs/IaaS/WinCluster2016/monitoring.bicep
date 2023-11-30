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

var ruleshortname = 'WSFC'
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1583)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1578)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1576)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1580)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1579)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5200)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5123)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5124)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5142)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5136)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1592)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1588)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1555)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1541)]]'
  'Microsoft-Windows-FailoverClustering/Operational!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1568)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1560)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1049)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1047)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1223)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1046)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1078)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1360)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1127)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1126)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1130)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1129)]]'
  'Microsoft-Windows-FailoverClustering/Operational!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1566)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1215)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1011)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1034)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1069)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1234)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1093)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1080)]]'
  'Microsoft-Windows-FailoverClustering/Operational!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1567)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=4868)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1561)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1000)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1569)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1044)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1121)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1041)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1039)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1040)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1042)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1054)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1055)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1077)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1363)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1361)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1242)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1045)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1038)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1544)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1556)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=4871)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1177)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1574)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=4872)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1545)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5133)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5128)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5120)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=5121)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1584)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1222)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1228)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1231)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1250)]]'
  'System!*[System[Provider[@Name=\'Microsoft-Windows-FailoverClustering\'] and (EventID=1254)]]'  
]

// The performance counters define which counters are collected
var performanceCounters=[]

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

module Alerts './WinCluster2016Alerts.bicep' = {
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

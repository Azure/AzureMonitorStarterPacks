targetScope='managementGroup'

// @description('Name of the DCR rule to be created')
// param rulename string = 'AMSP-IIS-Server'
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'WSFC2016'
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
param customerTags object
param actionGroupResourceId string
param instanceName string
var rulename = 'AMP-${instanceName}-${packtag}'
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'AMP-${instanceName}-${packtag}'
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
var performanceCounters=[
]

// Alerts - the module below creates the alerts and associates them with the action group
module Alerts './alerts.bicep' = {
  name: 'Alerts-${packtag}-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: actionGroupResourceId
    packtag: packtag
    Tags: Tags
    instanceName: instanceName
  }
}
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance-${packtag}-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers: performanceCounters
    Tags: Tags
    dceId: dceId
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}-${instanceName}-${location}'
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
    instanceName: instanceName
  }
}

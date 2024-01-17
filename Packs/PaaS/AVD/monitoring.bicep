targetScope = 'managementGroup'

param packtag string = 'AVD'
param solutionTag string
param solutionVersion string 
// param actionGroupResourceId string
// @description('Name of the DCR rule to be created')
// param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string

// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param resourceGroupId string
param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
// param grafanaName string
param customerTags object 
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
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'


// the xpathqueries define which counters are collected
var xPathQueries=[
  'DNS Server!*[System[Provider[@Name=\'Microsoft-Windows-DNS-Server-Service\'] and (EventID=10)]]'
]
var performanceCounters=[
]

var resourceTypes = [
  'Microsoft.DesktopVirtualization/workspaces'
  'Microsoft.DesktopVirtualization/hostpools'
]
// var tempTags ={
//   '${solutionTag}': packtag
//   MonitoringPackType: 'PaaS'
//   solutionVersion: solutionVersion
// }
// if the customer has provided tags, then use them, otherwise use the default tags
// var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
// var resourceGroupName = split(resourceGroupId, '/')[4]

// DCRs
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
    Tags: Tags
    dceId: dceId
  }
}

// Diagnostic settings policies
module diagnosticsPolicy '../../../modules/policies/mg/diagnostics/associacionpolicyDiag.bicep' = [for (rt,i) in resourceTypes: {
  name: 'associacionpolicy-${packtag}-${split(rt, '/')[1]}'
  params: {
    logAnalyticsWSResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    policyDescription: 'Policy to associate the diagnostics setting for ${split(rt, '/')[1]} resources the tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the diagnostics with the ${split(rt, '/')[1]} resources tagged with ${packtag} tag.'
    policyName: 'Associate-diagnostics-${packtag}-${split(rt, '/')[1]}'
    resourceType: rt
    initiativeMember: false
    packtype: 'PaaS'
    // assignmentLevel: assignmentLevel
    // assignmentSuffix: ''
    // instanceName: instanceName
    // mgname: mgname
    // policyLocation: location
    // subscriptionId: subscriptionId
    // userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}]
module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' = [for (rt,i) in resourceTypes: {
  name: 'AMP-diag-${instanceName}-${packtag}-${split(rt, '/')[1]}'
  dependsOn: [
    diagnosticsPolicy
  ]
  params: {
    location: location
    mgname: mgname
    packtag: packtag
    policydefinitionId: diagnosticsPolicy[i].outputs.policyId
    resourceType: rt
    solutionTag: solutionTag
    subscriptionId: subscriptionId 
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    policyType: 'diag'
    instanceName: instanceName
  }
}]

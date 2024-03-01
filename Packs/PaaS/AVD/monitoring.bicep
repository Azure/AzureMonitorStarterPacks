targetScope = 'managementGroup'

// Given the need to loop through each host pool this deployment will eventually pass the alerts to a deployment script that will
// map the host pool session hosts to the possible different Resource Group to scope the alerts to for VMs.  It will then launch the
// modules/alerts/PaaS/alerts.json from within the script. Thus the dependancy on the ARM/JSON version of alerts.json.


// @description('Location of needed scripts to deploy solution.')
// param _artifactsLocation string = 'https://raw.githubusercontent.com/JCoreMS/HostPoolDeployment/master/'

// @description('SaS token if needed for script location.')
// @secure()
// param _ArtifactsLocationSasToken string = ''
// param ruleshortname string
// param actionGroupResourceId string
param packtag string
param solutionTag string
// param solutionVersion string 
// param actionGroupResourceId string
// @description('Name of the DCR rule to be created')
// param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string

// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
// param parResourceGroupName string
@description('Full resource ID of the user managed identity to be used for the deployment')
param resourceGroupId string
param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
// param grafanaName string
// param customerTags object 
param instanceName string

var rulename = 'AMP-${instanceName}-${packtag}'

// if the customer has provided tags, then use them, otherwise use the default tags
// var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

// var avdLogAlertsUri = '${_artifactsLocation}Packs/PaaS/AVD/LogAlertsHostPool.json${_ArtifactsLocationSasToken}'
// var primaryScriptUri = '${_artifactsLocation}Packs/PaaS/AVD/AVDHostPoolMapAlerts.ps1${_ArtifactsLocationSasToken}'
// var templateUri = '${_artifactsLocation}modules/alerts/alerts.json${_ArtifactsLocationSasToken}'
var workspaceFriendlyName = split(workspaceId, '/')[8]
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

// var moduleprefix = 'AMP-${instanceName}-${packtag}'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0) ]]'
  'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
  'System!*'
  'Microsoft-FSLogix-Apps/Operational!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
  'Application!*[System[(Level=2 or Level=3)]]'
  'Microsoft-FSLogix-Apps/Admin!*[System[(Level=2 or Level=3 or Level=4 or Level=0)]]'
]
// The performance counters define which counters are collected
// these counters are collected every 30 seconds
var performanceCounters30 = [
  '\\LogicalDisk(C:)\\Avg. Disk Queue Length'
  '\\LogicalDisk(C:)\\Current Disk Queue Length'
  '\\Memory\\Available Mbytes'
  '\\Memory\\Page Faults/sec'
  '\\Memory\\Pages/sec'
  '\\Memory\\% Committed Bytes In Use'
  '\\PhysicalDisk(*)\\Avg. Disk Queue Length'
  '\\PhysicalDisk(*)\\Avg. Disk sec/Read'
  '\\PhysicalDisk(*)\\Avg. Disk sec/Transfer'
  '\\PhysicalDisk(*)\\Avg. Disk sec/Write'
  '\\Processor Information(_Total)\\% Processor Time'
  '\\User Input Delay per Process(*)\\Max Input Delay'
  '\\User Input Delay per Session(*)\\Max Input Delay'
  '\\RemoteFX Network(*)\\Current TCP RTT'
  '\\RemoteFX Network(*)\\Current UDP Bandwidth'
]
// these counters are collected every 30 seconds
var performanceCounters60 = [
  '\\LogicalDisk(C:)\\% Free Space'
  '\\LogicalDisk(C:)\\Avg. Disk sec/Transfer'
  '\\Terminal Services(*)\\Active Sessions'
  '\\Terminal Services(*)\\Inactive Sessions'
  '\\Terminal Services(*)\\Total Sessions'
]

var resourceTypes = [
  'Microsoft.DesktopVirtualization/workspaces'
  'Microsoft.DesktopVirtualization/applicationGroups'
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

// Alerts - the module below creates the alerts and associates them with the action group

/* module dsAVDHostPoolMapAlerts 'dsAVDHostMapping.bicep' = {
  name: 'linked_ds-AVDHostMapping-${uniqueString(deployment().name)}'
  scope: resourceGroup(subscriptionId, parResourceGroupName)
  params: {
    avdLogAlertsUri: avdLogAlertsUri
    AGId: actionGroupResourceId
    location: location
    moduleprefix: moduleprefix
    packtag: packtag
    primaryScriptUri: primaryScriptUri
    templateUri: templateUri
    workspaceId: workspaceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    Tags: Tags
  }
} */

// DCRs
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcravdMonitoring '../../../modules/DCRs/dcr-AVD.bicep' = {
  name: 'dcrPerformance-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers30: performanceCounters30
    counterSpecifiers60: performanceCounters60
    packtag: packtag
    solutionTag: solutionTag
    dceId: dceId
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: dcravdMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: rulename
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
    instanceName: instanceName
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

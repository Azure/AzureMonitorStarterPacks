targetScope='managementGroup'

@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-Windows-PS2016'
@description('Name of the Action Group to be used or created.')
param actionGroupName string
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array  = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'PS2016'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string = '0.1.0'
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
var ruleshortname = 'PS2016'
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

// the xpathqueries define which counters are collected
var xPathQueries=[
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=83) and (Provider[@Name=\'Microsoft-Windows-PrintBRM\' or @Name=\'PrintBrm\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=360) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Operational!*[System[(EventID=701 or EventID=702 or EventID=703 or EventID=704) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=364 or EventID=365 or EventID=367) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=315) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=371) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=356) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=513 or EventID=514) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=600 or EventID=601) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=515 or EventID=516 or EventID=517 or EventID=518 or EventID=519 or EventID=520) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
  'Microsoft-Windows-PrintService/Admin!*[System[(EventID=502 or EventID=503 or EventID=504 or EventID=505 or EventID=506 or EventID=507 or EventID=508 or EventID=509 or EventID=510 or EventID=511 or EventID=512) and (Provider[@Name=\'Microsoft-Windows-PrintService\'])]]'
]
// The performance counters define which counters are collected
var performanceCounters=[
  '\\Print Queue(_Total)\\Jobs'
  '\\Print Queue(_Total)\\Jobs Spooling'
  '\\Print Queue(_Total)\\Total Jobs Printed'
  '\\Print Queue(_Total)\\Total Pages Printed'
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
module Alerts './alerts.bicep' = {
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


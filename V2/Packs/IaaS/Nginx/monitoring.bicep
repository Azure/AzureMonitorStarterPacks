targetScope = 'managementGroup'

// @description('Name of the DCR rule to be created')
// param rulename string = 'AMSP-Linux-Nginx'

param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'Nginx'
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
param instanceName string
var tableName = 'NginxLogs'

var tableNameToUse = '${tableName}_CL'

var lawFriendlyName = split(workspaceId,'/')[8]

var rulename = 'AMP-${instanceName}-${packtag}'
var ruleshortname = 'AMP-${instanceName}-${packtag}'

var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
}
var filePatterns = [
  '/var/log/nginx/access.log'
  '/var/log/nginx/error.log'
]
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var resourceGroupName = split(resourceGroupId, '/')[4]
var lawResourceGroup = split(workspaceId, '/')[4]

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

module table '../../../modules/LAW/table.bicep' = {
  name: tableName
  scope: resourceGroup(subscriptionId, lawResourceGroup)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse //that will be created. This will be the table name that will be used in the DCR, not the stream name.
    retentionDays: 31
  }
}

module fileCollectionRule '../../../modules/DCRs/filecollectionSyslogLinux.bicep' = [for (fp,i) in filePatterns: {
  name: 'filecollectionrule-${packtag}-${i}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    table
  ]
  params: {
    location: location
    endpointResourceId: dceId
    Tags: Tags
    ruleName: '${rulename}-${i}'
    filepatterns: [
      fp
    ]
    lawResourceId:workspaceId
    tableName: tableNameToUse
    facilityNames: facilityNames
    logLevels: logLevels
    syslogDataSourceName: 'NginxLogs-1238219'
  }
}]

module Alerts './alerts.bicep' = {
  name: 'Alerts-${packtag}'
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
module policysetup '../../../modules/policies/mg/policies.bicep' = [for (fp,i) in filePatterns:{
  name: 'policysetup-${packtag}-${i}'
  params: {
    dcrId: fileCollectionRule[i].outputs.ruleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: '${rulename}-${i}'
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: '${rulename}-${i}'
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
    instanceName: instanceName
    index: i
  }
}]

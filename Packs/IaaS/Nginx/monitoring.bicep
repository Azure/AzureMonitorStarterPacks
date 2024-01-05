targetScope = 'managementGroup'

@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-Linux-Nginx'

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
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var ruleshortname = 'Nginx'
var resourceGroupName = split(resourceGroupId, '/')[4]

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

// Action Group
// module ag '../../../modules/actiongroups/ag.bicep' =  {
//   name: 'actionGroup'
//   params: {
//     actionGroupName: actionGroupName
//     existingAGRG: existingAGRG
//     emailreceiver: emailreceiver
//     emailreiceversemail: emailreiceversemail
//     useExistingAG: useExistingAG
//     newRGresourceGroup: resourceGroupName
//     solutionTag: solutionTag
//     subscriptionId: subscriptionId
//     location: location
//     Tags: Tags
//   }
// }

module fileCollectionRule '../../../modules/DCRs/filecollectionSyslogLinux.bicep' = {
  name: 'filecollectionrule-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    endpointResourceId: dceId
    Tags: Tags
    ruleName: rulename
    filepatterns: [
      '/var/log/nginx/access.log'
    //'/var/log/nginx/error.log'
    ]
    lawResourceId:workspaceId
    tableName: 'NginxLogs'
    facilityNames: facilityNames
    logLevels: logLevels
    syslogDataSourceName: 'NginxLogs-1238219'
  }
}
module Alerts './nginxalerts.bicep' = {
  name: 'Alerts-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: actionGroupResourceId
    packtag: packtag
    Tags: Tags
    
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: fileCollectionRule.outputs.ruleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
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

targetScope = 'managementGroup'


// @description('Name of the DCR rule to be created')
// param rulename string = 'AMSP-VMI-Linux'
param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'LxOS'
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

var rulename = 'AMP-${instanceName}-${packtag}'
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
  instanceName: instanceName
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'AMP-${instanceName}-${packtag}'
var resourceGroupName = split(resourceGroupId, '/')[4]
//
// Previously, this pack was composed of VMInsights rules. Since there are conflicts Linux and Windows boxes running VMinsights and no way to determine if a machne is Linux or Windows, these have been deactivated.

// // So, let's create an Insights rule for the VMs that should be the same as the usual VMInsights.
// module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
//   name: 'vmInsightsDCR-${packtag}'
//   scope: resourceGroup(subscriptionId, resourceGroupName)
//   params: {
//     location: location
//     workspaceResourceId: workspaceId
//     Tags: Tags
//     ruleName: rulename
//     dceId: dceId
//   }
// }

// module policysetup '../../../modules/policies/mg/policies.bicep' = {
//   name: 'policysetup-${packtag}'
//   scope: managementGroup(mgname)
//   params: {
//     dcrId: vmInsightsDCR.outputs.VMIRuleId
//     packtag: packtag
//     solutionTag: solutionTag
//     rulename: rulename
//     location: location
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//     mgname: mgname
//     ruleshortname: ruleshortname
//     assignmentLevel: assignmentLevel
//     subscriptionId: subscriptionId
//     instanceName: instanceName
//   }
// }

module InsightsAlerts './alerts.bicep' = {
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

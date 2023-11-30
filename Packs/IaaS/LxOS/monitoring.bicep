targetScope = 'managementGroup'


@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-VMI-Linux'
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string = ''
@description('If set to true, a new Action group will be created')
param useExistingAG bool
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
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
param grafanaName string
param customerTags object
var Tags = union({
  '${solutionTag}': packtag
  'solutionVersion': solutionVersion
},customerTags)
//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'VMI-LxOS'
var resourceGroupName = split(resourceGroupId, '/')[4]

// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
  name: 'New-AG'
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    useExistingAG: useExistingAG
    newRGresourceGroup: resourceGroupName
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    location: location
  }
}
// So, let's create an Insights rule for the VMs that should be the same as the usual VMInsights.
module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
  name: 'vmInsightsDCR-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceResourceId: workspaceId
    Tags: Tags
    ruleName: rulename
    dceId: dceId
  }
}
module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    Tags: Tags
  }
}
module policysetup '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  scope: managementGroup(mgname)
  params: {
    dcrId: vmInsightsDCR.outputs.VMIRuleId
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

targetScope = 'managementGroup'
param rulename string
param actionGroupName string
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
param location string //= resourceGroup().location
param workspaceId string
param packtag string
param solutionTag string
param solutionVersion string
param dceId string
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string

var ruleshortname = 'VMI-OS'
var resourceGroupName = split(resourceGroupId, '/')[4]
// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
  name: 'actiongroup'
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
    //location: location defailt is global
  }
}

// // Alerts - Event viewer based alerts. Depend on the event viewer logs being enabled on the VMs events are being sent to the workspace via DCRs.
// module eventAlerts 'eventAlerts.bicep' = {
//   name: 'eventAlerts-${packtag}'
//   params: {
//     AGId: ag.outputs.actionGroupResourceId
//     location: location
//     workspaceId: workspaceId
//     packtag: packtag
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion

//   }
// } 

// This option uses an existing VMI rule but this can be a tad problematic.
// resource vmInsightsDCR 'Microsoft.Insights/dataCollectionRules@2021-09-01-preview' existing = if(enableInsightsAlerts == 'true') {
//   name: insightsRuleName
//   scope: resourceGroup(insightsRuleRg)
// }
// So, let's create an Insights rule for the VMs that should be the same as the usual VMInsights.

module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
  name: 'vmInsightsDCR-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    workspaceResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
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
    solutionTag: solutionTag
    solutionVersion: solutionVersion
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
// Azure recommended Alerts for VMs
// These are the (very) basic recommeded alerts for VM, based on platform metrics
// module vmrecommended 'AzureBasicMetricAlerts.bicep' = if (enableBasicVMPlatformAlerts) {
//   name: 'vmrecommended'
//   params: {
//     vmIDs: vmIDs
//     packtag: packtag
//     solutionTag: solutionTag
//   }
// }

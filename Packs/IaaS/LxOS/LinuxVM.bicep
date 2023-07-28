//param vmnames array
//param vmIDs array = []
//param vmOSs array = []
//param arcVMIDs array = []
param rulename string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
// param enableBasicVMPlatformAlerts bool = false
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
//param osTarget string
param packtag string
param solutionTag string
param solutionVersion string

// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
  name: actionGroupName
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    solutionTag: solutionTag
    //location: location defailt is global
  }
}
// So, let's create an Insights rule for the VMs that should be the same as the usual VMInsights.
module vmInsightsDCR '../../../modules/DCRs/DefaultVMI-rule.bicep' = {
  name: 'vmInsightsDCR-${packtag}'
  params: {
    location: location
    workspaceResourceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    ruleName: rulename
  }
}
module InsightsAlerts './VMInsightsAlerts.bicep' = {
  name: 'Alerts-${packtag}'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
module policysetup '../../../modules/policies/subscription/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: vmInsightsDCR.outputs.VMIRuleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
  }
}

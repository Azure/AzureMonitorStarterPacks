targetScope = 'managementGroup'

param packtag string = 'AVD'
param solutionTag string
param solutionVersion string 
// param actionGroupResourceId string
// @description('Name of the DCR rule to be created')
// param rulename string = ''
// @description('location for the deployment.')
// param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string

// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
// param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param resourceGroupId string
// param subscriptionId string
// param userManagedIdentityResourceId string
// param mgname string 
// param assignmentLevel string
// param grafanaName string
//param solutionVersion string
param customerTags object 
// param instanceName string


var resourceTypes = [
  'Microsoft.DesktopVirtualization/applicationgroups'
  'Microsoft.DesktopVirtualization/hostpools'
]
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'PaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var resourceGroupName = split(resourceGroupId, '/')[4]

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
  }
}]

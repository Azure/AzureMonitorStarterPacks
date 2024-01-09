targetScope = 'managementGroup'

// @description('Name of the Action Group to be used or created.')
// param actionGroupName string = ''
// @description('Email receiver names to be used for the Action Group if being created.')
// param emailreceivers array = []
// @description('Email addresses to be used for the Action Group if being created.')
// param emailreiceversemails array = []
// @description('If set to true, a new Action group will be created')
// param useExistingAG bool
// @description('Name of the existing resource group to be used for the Action Group if existing.')
// param existingAGRG string = ''
param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
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
param instanceName string

//var solutionTagComponents='MonitorStarterPacksComponents'
// var tempTags= {
//   '${solutionTagComponents}': 'BackendComponent'
//   solutionVersion: solutionVersion
//   instanceName: instanceName
// }
//var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

module Storage './Storage/monitoring.bicep' = {
  name: 'StorageAlerts'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    packtag: 'Storage'
    grafanaName: grafanaName
    dceId: dceId
    customerTags: customerTags
  }
}
module OpenAI './OpenAI/monitoring.bicep' = {
  name: 'OpenAIAlerts'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    packtag: 'Storage'
    grafanaName: grafanaName
    dceId: dceId
    customerTags: customerTags
  }
}


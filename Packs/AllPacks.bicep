targetScope = 'managementGroup'

param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string = ''
@description('If set to true, a new Action group will be created')
param useExistingAG bool
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string
param solutionVersion string
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param assignmentLevel string
param grafanaResourceId string
param customerTags object
param existingActionGroupResourceId string
param deployIaaSPacks bool
param deployPaaSPacks bool
param deployPlatformPacks bool
param storageAccountName string
@secure()
param imagaGalleryName string
var solutionTagComponents='MonitorStarterPacksComponents'

var resourceGroupName = split(resourceGroupId, '/')[4]
var Tags = (customerTags=={}) ? {'${solutionTagComponents}': 'BackendComponent'
'solutionVersion': solutionVersion} : union({
  '${solutionTagComponents}': 'BackendComponent'
  'solutionVersion': solutionVersion
},customerTags['All'])

module ag '../modules/actiongroups/emailactiongroup.bicep' = if (!useExistingAG) {
  name: 'deployAG-new'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    Tags: Tags
    location: 'global'
    groupshortname: actionGroupName
  }
}

module IaaSPacks './IaaS/AllIaaSPacks.bicep' = if (deployIaaSPacks) {
  name: 'deployIaaSPacks'
  params: {
    // Tags: Tags
    location: location
    workspaceId: workspaceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    dceId: dceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    grafanaResourceId: grafanaResourceId
    actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
    customerTags: customerTags
    mgname: mgname
    resourceGroupId: resourceGroupId
    subscriptionId: subscriptionId
    storageAccountName: storageAccountName
    imagaGalleryName: imagaGalleryName
  }
}

module AllPaaSPacks 'PaaS/AllPaaSPacks.bicep' = if (deployPaaSPacks) {
  name: 'deployPaaSPacks'
  params: {
    // Tags: Tags
    location: location
    workspaceId: workspaceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    dceId: dceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    grafanaName: 'grafana'
    actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
    customerTags: customerTags
    mgname: mgname
    resourceGroupId: resourceGroupId
    subscriptionId: subscriptionId
  }
}

module AllPlatformPacks './Platform/AllPlatformPacks.bicep' = if (deployPlatformPacks) {
  name: 'deployPlatformPacks'
  params: {
    // Tags: Tags
    location: location
    workspaceId: workspaceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    dceId: dceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
    grafanaName: 'grafana'
    mgname: mgname
    resourceGroupId: resourceGroupId
    subscriptionId: subscriptionId
    customerTags: customerTags
  }
}

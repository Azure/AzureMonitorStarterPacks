targetScope = 'managementGroup'


// param _artifactsLocation string
// @secure()
// param _artifactsLocationSasToken string
// param workspaceIdAVD string

param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
@description('location for the deployment.')
param location string
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
param grafanaResourceId string = ''
param customerTags object
param existingActionGroupResourceId string
param deployIaaSPacks bool
param deployPaaSPacks bool
// param deployPlatformPacks bool - No longer supported
param storageAccountName string
param imageGalleryName string
param instanceName string
param deployGrafana bool

@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string = ''

var solutionTagComponents='MonitorStarterPacksComponents'

var resourceGroupName = split(resourceGroupId, '/')[4]
var tempTags= {
  '${solutionTagComponents}': 'BackendComponent'
  solutionVersion: solutionVersion
  instanceName: instanceName
}
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

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
  name: 'deployIaaSPacks-${instanceName}-${location}'
  params: {
    // Tags: Tags
    location: location
    workspaceId: workspaceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    dceId: dceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    //grafanaResourceId: grafanaResourceId
    actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
    customerTags: customerTags
    mgname: mgname
    resourceGroupId: resourceGroupId
    subscriptionId: subscriptionId
    storageAccountName: storageAccountName
    imageGalleryName: imageGalleryName
    instanceName: instanceName
  }
}

module AllPaaSPacks 'PaaS/AllPaaSPacks.bicep' = if (deployPaaSPacks) {
  name: 'deployPaaSPacks-${instanceName}-${location}'
  params: {
    // _artifactsLocation: _artifactsLocation
    // _artifactsLocationSasToken: _artifactsLocationSasToken
    location: location
    workspaceId: workspaceId
    //workspaceIdAVD: workspaceIdAVD
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    dceId: dceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    //grafanaName: 'grafana'
    actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
    customerTags: customerTags
    mgname: mgname
    resourceGroupId: resourceGroupId
    subscriptionId: subscriptionId
    instanceName: instanceName
  }
}

// module AllPlatformPacks './Platform/AllPlatformPacks.bicep' = if (deployPlatformPacks) {
//   name: 'deployPlatformPacks'
//   params: {
//     // Tags: Tags
//     location: location
//     workspaceId: workspaceId
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion
//     //dceId: dceId
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//     assignmentLevel: assignmentLevel
//     actionGroupResourceId: useExistingAG ? existingActionGroupResourceId : ag.outputs.agGroupId
//     //grafanaName: 'grafana'
//     mgname: mgname
//     resourceGroupId: resourceGroupId
//     subscriptionId: subscriptionId
//     customerTags: customerTags
//     instanceName: instanceName
//   }
// }

// Grafana upload and install of dashboards.
module grafana './ds.bicep' = if (deployGrafana) {
  name: 'grafana'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    fileName: 'grafana.zip'
    grafanaResourceId: grafanaResourceId
    location: location
    resourceGroupName: resourceGroupName
    customerTags: customerTags
    packsManagedIdentityResourceId: userManagedIdentityResourceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    instanceName: instanceName
    subscriptionId: subscriptionId
  }
}

targetScope = 'managementGroup'

param mgname string
param subscriptionId string
param resourceGroupName string
param createNewResourceGroup bool = false
param location string
param assignmentLevel string
param newLogAnalyticsWSName string = ''
param createNewLogAnalyticsWS bool
param existingLogAnalyticsWSId string = ''
param deployAMApolicy bool
//param currentUserIdObject string // This is to automatically assign permissions to Grafana.
param functionName string
param grafanaLocation string = ''
param grafanaName string = ''
param newGrafana bool
param existingGrafanaResourceId string = ''
param storageAccountName string
param createNewStorageAccount bool = false
param resourceGroupId string = ''

// Packs` stuff
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
param customerTags object
param existingActionGroupId string = ''

param deployAllPacks bool
param deployIaaSPacks bool = false
param deployPaaSPacks bool = false
param deployPlatformPacks bool = false
param deployDiscovery bool = false

var deployPacks = deployAllPacks || deployIaaSPacks || deployPaaSPacks || deployPlatformPacks
var solutionTag='MonitorStarterPacks'
var solutionTagComponents='MonitorStarterPacksComponents'
var solutionVersion='0.1'
var Tags = (customerTags=={}) ? {'${solutionTagComponents}': 'BackendComponent'
solutionVersion: solutionVersion} : union({
  '${solutionTagComponents}': 'BackendComponent'
  solutionVersion: solutionVersion
},customerTags.All)

module resourgeGroup '../backend/code/modules/mg/resourceGroup.bicep' = if (createNewResourceGroup) {
  name: 'resourceGroup-Deployment'
  scope: subscription(subscriptionId)
  params: {
    resourceGroupName: resourceGroupName
    location: location
    Tags: Tags
  }
}

module storageAccount '../backend/code/modules/mg/storageAccount.bicep' = if (createNewStorageAccount) {
  name:'newstorage-deployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    resourgeGroup
  ]
  params: {
    location: location
    Tags: Tags
    storageAccountName: storageAccountName
  }
}
module existingStorageAccount '../backend/code/modules/mg/storageAccountBlobs.bicep' = if (!createNewStorageAccount) {
  name:'existingstorage-deployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    storageAccountName: storageAccountName
  }
}

module logAnalytics '../../modules/LAW/law.bicep' = if (createNewLogAnalyticsWS) {
  name: 'logAnalytics-Deployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    resourgeGroup
  ]
  params: {
    location: location
    logAnalyticsWorkspaceName: newLogAnalyticsWSName
    Tags: Tags
    createNewLogAnalyticsWS: createNewLogAnalyticsWS
  }
}

// AMA policy - conditionally deploy it
module AMAPolicy '../AMAPolicy/amapoliciesmg.bicep' = if (deployAMApolicy) {
  name: 'DeployAMAPolicy'
  dependsOn: [
    resourgeGroup
  ]
  params: {
    assignmentLevel: assignmentLevel
    location: location
    resourceGroupName: resourceGroupName
    solutionTag: solutionTagComponents
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    Tags: Tags
  }
}

module discovery '../discovery/discovery.bicep' = if (deployDiscovery) {
  name: 'DeployDiscovery'
  dependsOn: [
    backend
  ]
  params: {
    assignmentLevel: assignmentLevel
    location: location
    resourceGroupName: resourceGroupName
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    dceId: backend.outputs.dceId
    imageGalleryName: 'MonitoringPacks'
    lawResourceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    mgname: mgname
    storageAccountname: storageAccountName
    tableName: 'Discovery'
    userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    Tags: Tags
  }
}

module amg '../backend/code/modules/grafana.bicep' = if (newGrafana) {
  name: 'azureManagedGrafana'
  dependsOn: [
    resourgeGroup
    logAnalytics
  ]
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    Tags: Tags
    location: grafanaLocation
    grafanaName: grafanaName
    solutionTag: solutionTag
    //userObjectId: currentUserIdObject
    //lawresourceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
  }
}

module backend '../backend/code/backend.bicep' = {
  name: 'MonitoringPacks-backend'
  dependsOn: [
    resourgeGroup
  ]
  params: {
    appInsightsLocation: location
//    currentUserIdObject: currentUserIdObject
    functionname: functionName
    lawresourceid: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    location: location
    mgname: mgname
    resourceGroupName: resourceGroupName
    Tags: Tags
    storageAccountName: storageAccountName
    subscriptionId: subscriptionId
    solutionTag: solutionTag
  }
}

module AllPacks '../../Packs/AllPacks.bicep' = if (deployPacks) {
  name: 'DeployAllPacks'
  dependsOn: [
    backend
  ]
  params: {
    assignmentLevel: assignmentLevel
    location: location
    dceId: backend.outputs.dceId
    mgname: mgname
    customerTags: customerTags
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    workspaceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    actionGroupName: actionGroupName
    resourceGroupId: createNewResourceGroup ? resourgeGroup.outputs.newResourceGroupId : resourceGroupId
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    grafanaResourceId: newGrafana ? amg.outputs.grafanaId : existingGrafanaResourceId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    existingActionGroupResourceId: existingActionGroupId
    deployIaaSPacks: deployIaaSPacks || deployAllPacks
    deployPaaSPacks: deployPaaSPacks || deployAllPacks
    deployPlatformPacks: deployPlatformPacks || deployAllPacks
    storageAccountName: storageAccountName
    imagaGalleryName: discovery.outputs.galleryName
  }
}

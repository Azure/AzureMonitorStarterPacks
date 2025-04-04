targetScope = 'subscription'

// param _artifactsLocation string = 'https://raw.githubusercontent.com/JCoreMS/AzureMonitorStarterPacks/JCore-AVD/'
// @secure()
// param _artifactsLocationSasToken string = ''

param subscriptionId string
param resourceGroupName string
param createNewResourceGroup bool = false
param location string
param newLogAnalyticsWSName string = ''
param createNewLogAnalyticsWS bool
param existingLogAnalyticsWSId string = ''
//param currentUserIdObject string // This is to automatically assign permissions to Grafana.
//param functionName string
param grafanaLocation string = ''
param grafanaName string = ''
param newGrafana bool
param existingGrafanaResourceId string = ''
param storageAccountName string
param createNewStorageAccount bool = false
param resourceGroupId string = ''
param instanceName string
param deployGrafana bool
// Packs` stuff
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
param existingActionGroupId string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
param customerTags object

param deployAllPacks bool
param deployIaaSPacks bool = false
param deployDiscovery bool = false

param collectTelemetry bool = true
param appInsightsLocation string

var deployPacks = deployAllPacks || deployIaaSPacks //|| deployPaaSPacks || deployPlatformPacks
var solutionTag='MonitorStarterPacks'
var solutionTagComponents='MonitorStarterPacksComponents'
var solutionVersion='0.1'
var tempTags={'${solutionTagComponents}': 'BackendComponent'
solutionVersion: solutionVersion
instanceName: instanceName}
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var functionName = 'AMP-${instanceName}-${split(subscriptionId,'-')[0]}-Function'
var logicAppName = 'AMP-${instanceName}-LogicApp'
var ImageGalleryName = 'AMP${instanceName}Gallery'

module resourgeGroup '../backend/bicep/modules/mg/resourceGroup.bicep' = if (createNewResourceGroup) {
  name: 'RGMonitoringPacks-${location}-${instanceName}'
  scope: subscription(subscriptionId)
  params: {
    resourceGroupName: resourceGroupName
    location: location
    Tags: Tags
  }
}

module storageAccount '../backend/bicep/modules/mg/storageAccount.bicep' = if (createNewStorageAccount) {
  name:'STOmonitoringPacks-${location}-${instanceName}'

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
module existingStorageAccount '../backend/bicep/modules/mg/storageAccountBlobs.bicep' = if (!createNewStorageAccount) {
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
    //createNewLogAnalyticsWS: createNewLogAnalyticsWS
  }
}

// module logAnalyticsAVD '../../modules/LAW/law.bicep' = if (createNewLogAnalyticsWSAVD) {
//   name: 'logAnalytics-AVD-Deployment'
//   scope: resourceGroup(subscriptionId, resourceGroupName)
//   dependsOn: [
//     resourgeGroup
//   ]
//   params: {
//     location: location
//     logAnalyticsWorkspaceName: newLogAnalyticsWSNameAVD
//     Tags: Tags
//     createNewLogAnalyticsWS: createNewLogAnalyticsWSAVD
//   }
// }

// AMA policy - conditionally deploy it
// module AMAPolicy '../AMAPolicy/amapoliciesmg.bicep' = if (deployAMApolicy) {
//   name: 'DeployAMAPolicy'
//   dependsOn: [
//     resourgeGroup
//   ]
//   params: {
//     assignmentLevel: assignmentLevel
//     location: location
//     resourceGroupName: resourceGroupName
//     solutionTag: solutionTagComponents
//     solutionVersion: solutionVersion
//     subscriptionId: subscriptionId
//     Tags: Tags
//   }
// }

module discovery '../discovery/discovery.bicep' = if (deployDiscovery) {
  name: 'DeployDiscovery-${instanceName}'
  params: {
    location: location
    resourceGroupName: resourceGroupName
    solutionTag: solutionTag
    //solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    dceId: backend.outputs.dceId
    imageGalleryName: ImageGalleryName
    lawResourceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    storageAccountname: storageAccountName
    tableName: 'Discovery'
    //userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    Tags: Tags
    instanceName: instanceName
  }
}

module amg '../backend/bicep/modules/grafana.bicep' = if (newGrafana && deployGrafana) {
  name: 'azureManagedGrafana-${instanceName}'
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
    instanceName: instanceName
    //userObjectId: currentUserIdObject
    //lawresourceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
  }
}

module backend '../backend/bicep/backend.bicep' = {
  name: 'MonitoringPacks-backend-${instanceName}'
  dependsOn: [
    resourgeGroup
  ]
  params: {
    appInsightsLocation: appInsightsLocation
    functionname: functionName
    lawresourceid: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    location: location
    resourceGroupName: resourceGroupName
    Tags: Tags
    storageAccountName: storageAccountName
    subscriptionId: subscriptionId
    solutionTag: solutionTag
    imageGalleryName: ImageGalleryName
    logicappname: logicAppName
    instanceName: instanceName
    collectTelemetry: collectTelemetry
  }
}

module AllPacks '../../Packs/AllPacks.bicep' = if (deployPacks) {
  name: 'DeployAllPacks'
  params: {
    // _artifactsLocation: _artifactsLocation
    // _artifactsLocationSasToken: _artifactsLocationSasToken
    location: location
    dceId: backend.outputs.dceId
    customerTags: customerTags
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    workspaceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    //workspaceIdAVD: seperateLAWforAVD ? (createNewLogAnalyticsWSAVD ? logAnalyticsAVD.outputs.lawresourceid : existingLogAnalyticsWSIdAVD) : ''
    actionGroupName: actionGroupName
    resourceGroupId: createNewResourceGroup ? resourgeGroup.outputs.newResourceGroupId : resourceGroupId
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    grafanaResourceId: deployGrafana ? ( newGrafana ? amg.outputs.grafanaId : existingGrafanaResourceId) : ''
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    existingActionGroupResourceId: existingActionGroupId
    deployIaaSPacks: deployIaaSPacks || deployAllPacks
    // deployPaaSPacks: deployPaaSPacks || deployAllPacks
    // deployPlatformPacks: deployPlatformPacks || deployAllPacks
    storageAccountName: storageAccountName
    imageGalleryName: ImageGalleryName
    instanceName: instanceName
    deployGrafana: deployGrafana
  }
}

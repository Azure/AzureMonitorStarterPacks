targetScope = 'subscription'

param subscriptionId string //1
param resourceGroupName string //2
param createNewResourceGroup bool = false //3
param location string //4
param newLogAnalyticsWSName string = '' //5
param createNewLogAnalyticsWS bool //6
param existingLogAnalyticsWSId string = ''
//param currentUserIdObject string // This is to automatically assign permissions to Grafana.
//param functionName string
param grafanaLocation string = ''
param grafanaName string = ''
param newGrafana bool
param storageAccountName string
param createNewStorageAccount bool = false
param instanceName string
param deployGrafana bool
// Packs` stuff
param customerTags object
// param deployAllPacks bool
// param deployIaaSPacks bool = false
param deployDiscovery bool = false
param collectTelemetry bool = true
param appInsightsLocation string

//var deployPacks = deployAllPacks || deployIaaSPacks //|| deployPaaSPacks || deployPlatformPacks
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
  name:'existingstorage-depl-${location}-${instanceName}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    storageAccountName: storageAccountName
  }
}

module logAnalytics '../../modules/LAW/law.bicep' = if (createNewLogAnalyticsWS) {
  name: 'logAnalytics-Deployment-${location}-${instanceName}'
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

module discovery '../discovery/discovery.bicep' = if (deployDiscovery) {
  name: 'DeployDiscovery-${location}-${instanceName}'
  dependsOn: [
   backend
  ]
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
    tableName: 'Discovery' // to store discovery data, no the results of the discovery
    resultstableName: 'DiscoveryResults' // to store the results of the discovery
    //userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    functionName: functionName
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
    storageAccount
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

// module AllPacks '../../Packs/AllPacks.bicep' = if (deployPacks) {
//   name: 'DeployAllPacks'
//   params: {
//     // _artifactsLocation: _artifactsLocation
//     // _artifactsLocationSasToken: _artifactsLocationSasToken
//     location: location
//     dceId: backend.outputs.dceId
//     customerTags: customerTags
//     subscriptionId: subscriptionId
//     useExistingAG: useExistingAG
//     userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
//     workspaceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
//     //workspaceIdAVD: seperateLAWforAVD ? (createNewLogAnalyticsWSAVD ? logAnalyticsAVD.outputs.lawresourceid : existingLogAnalyticsWSIdAVD) : ''
//     actionGroupName: actionGroupName
//     resourceGroupId: createNewResourceGroup ? resourgeGroup.outputs.newResourceGroupId : resourceGroupId
//     emailreceiver: emailreceiver
//     emailreiceversemail: emailreiceversemail
//     grafanaResourceId: deployGrafana ? ( newGrafana ? amg.outputs.grafanaId : existingGrafanaResourceId) : ''
//     solutionTag: solutionTag
//     solutionVersion: solutionVersion
//     existingActionGroupResourceId: existingActionGroupId
//     deployIaaSPacks: deployIaaSPacks || deployAllPacks
//     // deployPaaSPacks: deployPaaSPacks || deployAllPacks
//     // deployPlatformPacks: deployPlatformPacks || deployAllPacks
//     storageAccountName: storageAccountName
//     imageGalleryName: ImageGalleryName
//     instanceName: instanceName
//     deployGrafana: deployGrafana
//   }
// }

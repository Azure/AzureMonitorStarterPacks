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
param grafanaLocation string
param grafanaName string
param storageAccountName string
param createNewStorageAccount bool = false
param resourceGroupId string = ''

// Packs` stuff
param deployPacks bool = false
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''


var solutionTag='MonitorStarterPacks'
var solutionVersion='0.1'

module resourgeGroup '../backend/code/modules/mg/resourceGroup.bicep' = if (createNewResourceGroup) {
  name: 'resourceGroup-Deployment'
  scope: subscription(subscriptionId)
  params: {
    resourceGroupName: resourceGroupName
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion    
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
    solutionVersion: solutionVersion
    solutionTag: solutionTag
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
    solutionTag: solutionTag
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
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
  }
}

module backend '../backend/code/backend.bicep' = {
  name: 'backend'
  dependsOn: [
    resourgeGroup
  ]
  params: {
    appInsightsLocation: location
//    currentUserIdObject: currentUserIdObject
    functionname: functionName
    grafanalocation: grafanaLocation
    grafanaName: grafanaName
    lawresourceid: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    location: location
    mgname: mgname
    resourceGroupName: resourceGroupName
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    storageAccountName: storageAccountName
    subscriptionId: subscriptionId
  }
}

module AllPacks '../../Packs/IaaS/AllIaaSPacks.bicep' = if (deployPacks) {
  name: 'DeployAllPacks'
  dependsOn: [
    backend
  ]
  params: {
    assignmentLevel: assignmentLevel
    location: location
    dceId: backend.outputs.dceId
    mgname: mgname
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: backend.outputs.packsUserManagedResourceId
    workspaceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    actionGroupName: actionGroupName
    resourceGroupId: createNewResourceGroup ? resourgeGroup.outputs.newResourceGroupId : resourceGroupId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}

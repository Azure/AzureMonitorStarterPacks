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
param newGrafana bool = true
param existingGrafanaResourceId string = ''
param storageAccountName string
param createNewStorageAccount bool = false
param resourceGroupId string = ''

// Packs` stuff
param deployPacks bool = false
@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
param customerTags object
param existingActionGroupId string


var solutionTag='MonitorStarterPacks'
var solutionTagComponents='MonitorStarterPacksComponents'
var solutionVersion='0.1'
var Tags = (customerTags=={}) ? {'${solutionTagComponents}': 'BackendComponent'
'solutionVersion': solutionVersion} : union({
  '${solutionTagComponents}': 'BackendComponent'
  'solutionVersion': solutionVersion
},customerTags['All'])

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

module amg '../backend/code/modules/grafana.bicep' = if (newGrafana) {
  name: 'azureManagedGrafana'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    Tags: Tags
    location: grafanaLocation
    grafanaName: grafanaName
    solutionTag: solutionTagComponents
    //userObjectId: currentUserIdObject
    //lawresourceId: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
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
    lawresourceid: createNewLogAnalyticsWS ? logAnalytics.outputs.lawresourceid : existingLogAnalyticsWSId
    location: location
    mgname: mgname
    resourceGroupName: resourceGroupName
    Tags: Tags
    storageAccountName: storageAccountName
    subscriptionId: subscriptionId
    solutionTag: solutionTagComponents
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
  }
}

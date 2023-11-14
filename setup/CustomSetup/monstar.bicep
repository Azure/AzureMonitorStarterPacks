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

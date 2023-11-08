targetScope = 'managementGroup'

param mgname string
param subscriptionId string
param resourceGroupName string
param location string
param assignmentLevel string
param workspaceResourceId string
param deployAMApolicy bool
param currentUserIdObject string // This is to automatically assign permissions to Grafana.
param functionName string
param grafanaLocation string
param grafanaName string
param storageAccountName string

var solutionTag='MonitorStarterPacks'
var solutionVersion='0.1'

// AMA policy - conditionally deploy it
module AMAPolicy '../AMAPolicy/amapoliciesmg.bicep' = if (deployAMApolicy) {
  name: 'DeployAMAPolicy'
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
  params: {
    appInsightsLocation: location
    currentUserIdObject: currentUserIdObject
    functionname: functionName
    grafanalocation: grafanaLocation
    grafanaName: grafanaName
    lawresourceid: workspaceResourceId
    location: location
    mgname: mgname
    resourceGroupName: resourceGroupName
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    storageAccountName: storageAccountName
    subscriptionId: subscriptionId
  }
}

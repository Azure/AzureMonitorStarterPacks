targetScope = 'managementGroup'

@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
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

var resourceGroupName = split(resourceGroupId, '/')[4]

module WinOSPack './WinOS/monitoring.bicep' = {
  name: 'WinOSPack'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
module LxOSPack './LxOS/monitoring.bicep' = {
  name: 'LxOSPack-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
module IIS './IIS/monitoring.bicep' = {
  name: 'IISPack-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}

module IIS2016 './IIS2016/monitoring.bicep' = {
  name: 'IIS2016-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
module DNS2016 './DNS2016/monitoring.bicep' = {
  name: 'DNS2016-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
module PS2016 './PS2016/monitoring.bicep' = {
  name: 'PS2016-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
module Nginx './Nginx/monitoring.bicep' = {
  name: 'Nginx-deployment'
  params: {
    actionGroupName: actionGroupName
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    useExistingAG: useExistingAG
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    existingAGRG: existingAGRG
    grafanaName: grafanaName
  }
}
// Grafana upload and install
module grafana 'ds.bicep' = {
  name: 'grafana'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    fileName: 'grafana.zip'
    grafanaName: grafanaName
    location: location
    resourceGroupName: resourceGroupName
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    packsManagedIdentityResourceId: userManagedIdentityResourceId
  }
}

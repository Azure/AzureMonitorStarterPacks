targetScope = 'managementGroup'
// @description('Name of the Action Group to be used or created.')
// param actionGroupName string = ''
// @description('Email receiver names to be used for the Action Group if being created.')
// param emailreceivers array = []
// @description('Email addresses to be used for the Action Group if being created.')
// param emailreiceversemails array = []
// @description('If set to true, a new Action group will be created')
// param useExistingAG bool
// @description('Name of the existing resource group to be used for the Action Group if existing.')
// param existingAGRG string = ''
// param _artifactsLocation string
// @secure()
// param _artifactsLocationSasToken string

param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
@description('Full resource ID of the log analytics AVD workspace to be used for the deployment IF seperate.')
param workspaceIdAVD string
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
//param grafanaName string
param customerTags object 
param instanceName string

module Storage './Storage/monitoring.bicep' = {
  name: 'StorageAlerts'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packtag: 'Storage'
    //grafanaName: grafanaName
    //dceId: dceId
    customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
  }
}
module OpenAI './OpenAI/monitoring.bicep' = {
  name: 'OpenAIAlerts'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packtag: 'OpenAI'
    //grafanaName: grafanaName
    //dceId: dceId
    customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
  }
}

module AVD './AVD/monitoring.bicep' = {
  name: 'AvdAlerts'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    packtag: 'Avd'
    //grafanaName: grafanaName
    instanceName: instanceName
    dceId: dceId
    workspaceId: workspaceIdAVD
  }
}

// No logs for this pack, so going straight to alerts
module LogicApps './LogicApps/alerts.bicep' = {
  name: 'LogicAppsAlerts'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'LogicApps'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    solutionVersion: solutionVersion
    resourceType: 'Microsoft.Logic/workflows'
  }
}

// No logs for this pack, so going straight to alerts
module SQLMI './SQL/SQLMI/alerts.bicep' = {
  name: 'SQLMIAlerts'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'SQLMI'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Sql/managedInstances'
  }
}
module SQLSrv './SQL/server/alerts.bicep' = {                              
  name: 'SQLSrvAlerts'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'SQLSrv'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Sql/servers/databases'
  }
}
module WebApps './WebApp/monitoring.bicep' = {
  name: 'WebApps'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packtag: 'WebApp'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    actionGroupResourceId: actionGroupResourceId
    customerTags: customerTags
    location: location
    resourceGroupId: resourceGroupId
    workspaceId: workspaceId
  }
}

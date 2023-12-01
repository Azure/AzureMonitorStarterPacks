targetScope = 'managementGroup'

@description('Name of the Action Group to be used or created.')
param actionGroupName string = ''
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceiver string = ''
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemail string = ''
@description('If set to true, a new Action group will be created')
param useExistingAG bool
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = '' // probably useless
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
param grafanaResourceId string
param customerTags object
param existingActionGroupResourceId string

var solutionTagComponents='MonitorStarterPacksComponents'

var resourceGroupName = split(resourceGroupId, '/')[4]
var Tags = (customerTags=={}) ? {'${solutionTagComponents}': 'BackendComponent'
'solutionVersion': solutionVersion} : union({
  '${solutionTagComponents}': 'BackendComponent'
  'solutionVersion': solutionVersion
},customerTags['All'])

module ag '../../modules/actiongroups/emailactiongroup.bicep' = if (useExistingAG) {
    name: 'deployAG-new'
    scope: resourceGroup(solutionTag, resourceGroupName)
    params: {
      emailreceiver: emailreceiver
      emailreiceversemail: emailreiceversemail
      Tags: Tags
      location: location
      solutionTag: solutionTag
      actiongroupname: actionGroupName
      groupshortname: actionGroupName
    }
  }

module WinOSPack './WinOS/monitoring.bicep' = {
  name: 'WinOSPack'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}
module LxOSPack './LxOS/monitoring.bicep' = {
  name: 'LxOSPack-deployment'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}
module IIS './IIS/monitoring.bicep' = {
  name: 'IISPack-deployment'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}

module IIS2016 './IIS2016/monitoring.bicep' = {
  name: 'IIS2016-deployment'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId:existingActionGroupResourceId
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
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    existingAGRG: existingAGRG
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}
module PS2016 './PS2016/monitoring.bicep' = {
  name: 'PS2016-deployment'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}
module Nginx './Nginx/monitoring.bicep' = {
  name: 'Nginx-deployment'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    customerTags: customerTags
    actionGroupResourceId: existingActionGroupResourceId
  }
}
// Grafana upload and install
module grafana 'ds.bicep' = {
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
  }
}

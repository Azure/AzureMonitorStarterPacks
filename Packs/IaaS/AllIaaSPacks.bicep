targetScope = 'managementGroup'

param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
@description('location for the deployment.')
param location string //= resourceGroup().location
// @description('Name of the Action Group to be used or created.')
// param actionGroupName string = ''
// @description('Email receiver names to be used for the Action Group if being created.')
// param emailreceiver string = ''
// @description('Email addresses to be used for the Action Group if being created.')
// param emailreiceversemail string = ''
// @description('If set to true, a new Action group will be created')
// param useExistingAG bool
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string
param solutionVersion string
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param assignmentLevel string
param grafanaResourceId string
param customerTags object
param actionGroupResourceId string
param storageAccountName string
param imagaGalleryName string
param instanceName string

var solutionTagComponents='MonitorStarterPacksComponents'
var tempTags= {
  '${solutionTagComponents}': 'BackendComponent'
  solutionVersion: solutionVersion
  instanceName: instanceName
  MonitoringPackType: 'IaaS'
}
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var resourceGroupName = split(resourceGroupId, '/')[4]


// module ag '../../modules/actiongroups/emailactiongroup.bicep' = if (!useExistingAG) {
//     name: 'deployAG-new'
//     scope: resourceGroup(subscriptionId, resourceGroupName)
//     params: {
//       emailreceiver: emailreceiver
//       emailreiceversemail: emailreiceversemail
//       Tags: Tags
//       location: 'global'
//       groupshortname: actionGroupName
//     }
//   }
module ADDS './ADDS/monitoring.bicep' = {
  name: 'ADDSPack'
  params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    location: location
    mgname: mgname
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    imageGalleryName: imagaGalleryName
    resourceGroupId: resourceGroupId
    storageAccountname: storageAccountName
    tableName: 'addsmonitoring'
    tags: Tags
    actionGroupResourceId: actionGroupResourceId
    customerTags: customerTags
    workspaceId: workspaceId
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
    actionGroupResourceId: actionGroupResourceId
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
    actionGroupResourceId: actionGroupResourceId
    instanceName: instanceName
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
    actionGroupResourceId: actionGroupResourceId
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
    actionGroupResourceId: actionGroupResourceId
  }
}
module DNS2016 './DNS2016/monitoring.bicep' = {
  name: 'DNS2016-deployment'
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
    actionGroupResourceId: actionGroupResourceId
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
    actionGroupResourceId: actionGroupResourceId
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
    actionGroupResourceId: actionGroupResourceId
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
    instanceName: instanceName
  }
}

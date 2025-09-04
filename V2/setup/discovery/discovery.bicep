targetScope = 'managementGroup'

param location string 
param solutionTag string
param solutionVersion string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
param tableName string
param userManagedIdentityResourceId string
param mgname string
param assignmentLevel string
param dceId string
param Tags object
param instanceName string
// Table to receive the data
var tableNameToUse = '${tableName}_CL'
var lawFriendlyName = split(lawResourceId,'/')[8]
var lawResourceGroupName = split(lawResourceId,'/')[4]
var lawSubscriptionId = split(lawResourceId,'/')[2]

module table '../../modules/LAW/table.bicep' = {
  name: tableNameToUse
  scope: resourceGroup(lawSubscriptionId, lawResourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}

module WindowsDiscovery './Windows/discovery.bicep' = {
  name: 'WindowsDiscovery-${instanceName}'
  dependsOn: [
    table
  ]
  params: {
    location: location
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    storageAccountname: storageAccountname
    imageGalleryName: imageGalleryName
    lawResourceId: lawResourceId
    tableNameToUse: tableNameToUse
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    assignmentLevel: assignmentLevel
    dceId: dceId
    tags: Tags
    instanceName: instanceName
  }
}
module LinuxDiscovery 'Linux/discovery.bicep' = {
  name: 'LinuxDiscovery-${instanceName}'
  dependsOn: [
    table
  ]
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    storageAccountname: storageAccountname
    imageGalleryName: imageGalleryName
    lawResourceId: lawResourceId
    tableNameToUse: tableNameToUse
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    assignmentLevel: assignmentLevel
    dceId: dceId
    tags: Tags
    instanceName: instanceName
  }
}


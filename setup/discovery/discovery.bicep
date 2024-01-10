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
var tableNameToUse = 'Custom${tableName}_CL'
var lawFriendlyName = split(lawResourceId,'/')[8]

module table '../../modules/LAW/table.bicep' = {
  name: tableNameToUse
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}

module WindowsDiscovery './Windows/discovery.bicep' = {
  name: 'WindowsDiscovery-${instanceName}'
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


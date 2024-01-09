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

module WindowsDiscovery './Windows/discovery.bicep' = {
  name: 'WindowsDiscovery'
  params: {
    location: location
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    storageAccountname: storageAccountname
    imageGalleryName: imageGalleryName
    lawResourceId: lawResourceId
    tableName: tableName
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    assignmentLevel: assignmentLevel
    dceId: dceId
    tags: Tags
  }
}
module LinuxDiscovery 'Linux/discovery.bicep' = {
  name: 'LinuxDiscovery'
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
    tableName: tableName
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    assignmentLevel: assignmentLevel
    dceId: dceId
    tags: Tags
  }
}


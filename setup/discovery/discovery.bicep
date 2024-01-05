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

module gallery './modules/aig.bicep' = {
  name: 'gallery'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    galleryname: imageGalleryName
    location: location
    tags: Tags
  }
}

module WindowsDiscovery './Windows/discovery.bicep' = {
  name: 'WindowsDiscovery'
  dependsOn: [
    gallery
  ]
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
    gallery
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
output galleryName string = gallery.name

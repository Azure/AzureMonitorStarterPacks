targetScope = 'subscription'

param location string 
param solutionTag string
//param solutionVersion string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
param tableName string
param resultstableName string
//param userManagedIdentityResourceId string
param dceId string
param customerTags object
param instanceName string
param solutionVersion string
param functionName string

// Table to receive the data
var tableNameToUse = '${tableName}_CL'
var resultstableNameToUse = '${resultstableName}_CL'
var lawFriendlyName = split(lawResourceId,'/')[8]

module table '../../modules/LAW/table.bicep' = {
  name: '${tableNameToUse}-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}

module resultstable '../../modules/LAW/resultstable.bicep' = {
  name: 'results${tableNameToUse}-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: resultstableNameToUse
    retentionDays: 31
  }
}
module discoveryDCR '../../modules/DCRs/discoveryDCR.bicep' = {
  name: 'DiscoveryDCR-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    table
  ]
  params: {
    location: location
    workspaceResourceId: lawResourceId
    Tags: customerTags
    ruleName: 'discoveryDRC-${lawFriendlyName}'
    dceId: dceId
    tableName: resultstableNameToUse
  }
}

module WindowsDiscovery './Windows/discovery.bicep' = {
  name: 'WindowsDiscovery-${instanceName}-${location}'
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
    //userManagedIdentityResourceId: userManagedIdentityResourceId
    dceId: dceId
    instanceName: instanceName
    customerTags: customerTags
    solutionVersion: solutionVersion
    packtag: 'WinDisc'

  }
}

module LinuxDiscovery 'Linux/discovery.bicep' = {
  name: 'LinuxDiscovery-${instanceName}-${location}'
  dependsOn: [
    table
  ]
  params: {
    location: location
    solutionTag: solutionTag
    //solutionVersion: solutionVersion
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    storageAccountname: storageAccountname
    imageGalleryName: imageGalleryName
    lawResourceId: lawResourceId
    tableNameToUse: tableNameToUse
    //userManagedIdentityResourceId: userManagedIdentityResourceId
    dceId: dceId
    instanceName: instanceName
    customerTags: customerTags
    solutionVersion: solutionVersion
    packtag: 'LxDisc'
  }
}

module updateSiteConfig '../backend/bicep/modules/appsettings.bicep' = {
  name: 'updateSiteConfig-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    functionName: functionName
    appSettings: {
      appSettings: {
        discoveryDCRImmutableId: discoveryDCR.outputs.dcrImmutableId
        DiscoveryResultsTableName: resultstableNameToUse
      }
    }
  }
}

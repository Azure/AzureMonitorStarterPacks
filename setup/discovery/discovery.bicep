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

var solutionTagComponents='MonitorStarterPacksComponents'

var tempTags={'${solutionTagComponents}': 'BackendComponent'
solutionVersion: solutionVersion
instanceName: instanceName}
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

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

module WindowsDiscovery './Windows/discovery.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'WinDisc-${instanceName}-${location}'
  dependsOn: [
    table
  ]
  params: {
    customerTags: customerTags
    solutionVersion: solutionVersion
    packtag: 'WinDisc'
    location: location
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    resourceGroupName: resourceGroupName
    storageAccountname: storageAccountname
    imageGalleryName: imageGalleryName
    lawResourceId: lawResourceId
    tableNameToUse: tableNameToUse
    dceId: dceId
    instanceName: instanceName
  }
}
module LinuxDiscovery 'Linux/discovery.bicep' = {
  name: 'LxDisc-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
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
    dceId: dceId
    packtag: 'LxDisc'
    customerTags: customerTags
    instanceName: instanceName
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
// This is the DCR to collect the results of the discovery, not the discovery data
module discoveryDCR '../../modules/DCRs/discoveryDCR.bicep' = {
  name: 'DiscoveryResults-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    resultstable
  ]
  params: {
    location: location
    workspaceResourceId: lawResourceId
    Tags: Tags
    ruleName: 'discoveryResults-${lawFriendlyName}'
    dceId: dceId
    tableName: resultstableNameToUse
  }
}

resource webApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: functionName
  scope: resourceGroup(resourceGroupName)
}

module updateSiteConfig '../backend/bicep/modules/appsettings.bicep' = {
  name: 'updateSiteConfig-${instanceName}-${location}'
  dependsOn: [
    webApp
    discoveryDCR
  ]
  scope: resourceGroup(resourceGroupName)
  params: {
    functionName: functionName
    appSettings: {
        discoveryDCRImmutableId: discoveryDCR.outputs.dcrImmutableId
        DiscoveryResultsTableName: resultstableNameToUse
    }
    currentAppSettings: list(resourceId(subscriptionId,resourceGroupName, 'Microsoft.Web/sites/config', webApp.name, 'appsettings'), webApp.apiVersion).properties
  }
}

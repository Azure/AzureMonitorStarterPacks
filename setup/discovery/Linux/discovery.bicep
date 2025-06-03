////targetScope = 'managementGroup'

param packtag string
param location string 
param solutionTag string
//param solutionVersion string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
param tableNameToUse string
//param userManagedIdentityResourceId string
param dceId string
param customerTags object
param instanceName string
param solutionVersion string
var filename = 'discover.tar'
var tempTags ={
  '${solutionTag}': packtag
  instanceName: instanceName
  MonitoringPackType: 'Discovery'
  solutionVersion: solutionVersion
}
var tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
//var workspaceFriendlyName = split(workspaceId, '/')[8]
//var ruleshortname = 'amp${instanceName}lxdisc'
var appName = '${instanceName}-LxDiscovery'
var appDescription = 'Linux Workload discovery'
var OS = 'Linux'
var appVersionName = '1.0.0'
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: sasExpiry
  signedProtocol: 'https'
  keyToSign: 'key2'
}
// VM Application to collect the data - this would be ideally an extension
module linuxdiscoveryapp '../../../modules/discovery/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'amp-${instanceName}-Discovery-${OS}-${location}'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
    tags: tags
  }
}

module uploadLinux './uploadDSLinux.bicep' = {
  name: 'upload-discovery-${OS}-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'discovery'
    filename: filename
    storageAccountName: storageAccountname
    location: location
    tags: tags
  }
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: storageAccountname
}
module linuxDiscovery '../../../modules/discovery/aigappversion.bicep' = {
  name: 'amp-${instanceName}-Discovery-${OS}-App-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    linuxdiscoveryapp
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: appVersionName
    location: location
    targetRegion: location
    mediaLink: '${uploadLinux.outputs.fileURL}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'
    installCommands: 'tar -xvf ${filename} && chmod +x ./install.sh && ./install.sh'
    removeCommands: '/opt/microsoft/discovery/uninstall.sh'
    tags: tags
    packageFileName: filename
  }
}
// DCR to collect the data
module LinuxDiscoveryDCR '../../../modules/discovery/discoveryrule.bicep' = {
  name: 'LinuxDiscoveryDCR-${instanceName}-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      '/opt/microsoft/discovery/*.csv'
    ]
    kind: 'Linux'
    location: location
    lawResourceId: lawResourceId
    OS: 'Linux'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: packtag
    packtype: 'Discovery'
    instanceName: instanceName
  }
}


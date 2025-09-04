////targetScope = 'managementGroup'
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: sasExpiry
  signedProtocol: 'https'
  keyToSign: 'key2'
}
param location string 
param solutionTag string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
//param userManagedIdentityResourceId string
param dceId string
param instanceName string
param packtag string
param tableNameToUse string
//var workspaceFriendlyName = split(workspaceId, '/')[8]
//var ruleshortname = 'amp${instanceName}windisc'
param customerTags object
param solutionVersion string
var tempTags ={
  '${solutionTag}': packtag
  instanceName: instanceName
  MonitoringPackType: 'Discovery'
  solutionVersion: solutionVersion
}
var tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var appName = '${instanceName}-windiscovery'
var appDescription = 'Windows Workload discovery'
var OS = 'Windows'
var appVersionName = '1.0.0'

// VM Application to collect the data - this would be ideally an extension
module windowsDiscoveryApp '../../../modules/discovery/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'amp-${instanceName}-Discovery-${OS}'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
    tags: tags
  }
}
module upload 'uploadDSWindows.bicep' = {
  name: 'upload-discovery-${OS}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'discovery'
    filename: 'discover.zip'
    storageAccountName: storageAccountname
    location: location
    tags: tags
  }
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: storageAccountname
}
module windiscovery '../../../modules/discovery/aigappversion.bicep' = {
  name: 'amp-${instanceName}-Discovery-${OS}-App'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    windowsDiscoveryApp
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: appVersionName
    location: location
    targetRegion: location
    mediaLink: '${upload.outputs.fileURL}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'
    installCommands: 'powershell -command "ren windiscovery discover.zip; expand-archive ./discover.zip . ; ./install.ps1"'
    removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'Monstar Packs Discovery\' \'\\\'"'
    tags: tags
    packageFileName: 'discover.zip'
  }
}
// DCR to collect the data
module windiscoveryDCR '../../../modules/discovery/discoveryrule.bicep' = {
  name: 'amp-${instanceName}-DCR-${OS}Discovery'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      'C:\\WindowsAzure\\Discovery\\*.csv'
    ]
    kind: 'Windows'
    location: location
    lawResourceId: lawResourceId
    OS: 'Windows'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: packtag
    packtype: 'Discovery'
    instanceName: instanceName
  }
}

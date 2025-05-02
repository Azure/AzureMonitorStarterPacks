//Client is a vm application used to collect data from a VM (VM only, not Arc servers.)
////targetScope = 'managementGroup'
targetScope = 'subscription'

@description('Name of the DCR rule to be created')
param packtag string = 'ADDS'
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string 
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
//param userManagedIdentityResourceId string
param subscriptionId string
param resourceGroupId string
//param assignmentLevel string

param storageAccountname string
param imageGalleryName string
param tableName string
param tags object
param instanceName string
//param ruleshortname string
param appName string
param appDescription string
param OS string
param filepatterns array = [
  'C:\\WindowsAzure\\ADDS\\*.csv'
]
var resourceGroupName = split(resourceGroupId, '/')[4]

var tableNameToUse = '${tableName}_CL'
var lawFriendlyName = split(workspaceId,'/')[8]
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
module addscollectionapp '../../../modules/discovery/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'addscollectionapp-${instanceName}'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
    tags: tags
  }
}

module upload 'uploadDSADDS.bicep' = {
  name: 'upload-addscollectionapp-${instanceName}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'applications'
    filename: 'addscollection.zip'
    storageAccountName: storageAccountname
    location: location
    tags: tags
    instanceName: instanceName
  }
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: storageAccountname
}
module addscollectionappversion '../../../modules/discovery/aigappversion.bicep' = {
  name: 'addscollectionappversion-${instanceName}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    addscollectionapp
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: '1.0.0'
    location: location
    targetRegion: location
    mediaLink: '${upload.outputs.fileURL}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'
    installCommands: 'powershell -command "ren addscollection addscollection.zip; expand-archive ./addscollection.zip . ; ./install.ps1"'
    removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'AD DS Collection Task\' \'\\\' "'
    tags: tags
    packageFileName: 'addscollection.zip'
  }
}
// Table to receive the data
module table '../../../modules/LAW/table.bicep' = {
  name: tableNameToUse
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    parentname: lawFriendlyName
    tableName: tableNameToUse
    retentionDays: 31
  }
}
// DCR to collect the data
module addscollectionDCR '../../../modules/discovery/discoveryrule.bicep' = {
  dependsOn: [
    table
  ]
  name: 'addscollectionDCR'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: filepatterns
    kind: 'Windows'
    location: location
    lawResourceId: workspaceId
    OS: 'Windows'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: packtag
    packtype: 'IaaS'
    instanceName: instanceName
  }
}

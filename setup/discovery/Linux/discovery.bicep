////targetScope = 'managementGroup'
targetScope = 'subscription'

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
param tags object
param instanceName string
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
module linuxdiscoveryapp '../modules/aigapp.bicep' = {
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
    filename: 'discover.tar'
    storageAccountName: storageAccountname
    location: location
    tags: tags
  }
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: storageAccountname
}
module linuxDiscovery '../modules/aigappversion.bicep' = {
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
    installCommands: 'tar -xvf ${appName} && chmod +x ./install.sh && ./install.sh'
    removeCommands: '/opt/microsoft/discovery/uninstall.sh'
    tags: tags
    packageFileName: 'discover.tar'
  }
}
// module applicationPolicy '../modules/vmapplicationpolicy.bicep' = {
//   name: 'applicationPolicy-${appName}'
//   params: {
//     packtag: 'LxDisc'
//     policyDescription: 'Install ${appName} to ${OS} VMs'
//     policyName: 'Install ${appName}'
//     policyDisplayName: 'Install ${appName} to ${OS} VMs'
//     solutionTag: solutionTag
//     vmapplicationResourceId: linuxDiscovery.outputs.appVersionId
//     roledefinitionIds: [
//       '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
//     ]
//     packtype: 'Discovery'
//   }
// }
// module vmapplicationAssignment '../modules/assignment.bicep' = if(assignmentLevel == 'managementGroup') {
//   dependsOn: [
//     applicationPolicy
//   ]
//   name: 'Assignment-${ruleshortname}'
//   scope: managementGroup(mgname)
//   params: {
//     policyDefinitionId: applicationPolicy.outputs.policyId
//     assignmentName: 'AMP-Assign-${ruleshortname}-application'
//     location: location
//     //roledefinitionIds: roledefinitionIds
//     solutionTag: solutionTag
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//   }
// }
// module vmassignmentsub '../modules/sub/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
//   dependsOn: [
//     applicationPolicy
//   ]
//   name: 'AssignSub-${ruleshortname}'
//   scope: subscription(subscriptionId)
//   params: {
//     policyDefinitionId: applicationPolicy.outputs.policyId
//     assignmentName: 'AMP-Assign-${ruleshortname}-application'
//     location: location
//     //roledefinitionIds: roledefinitionIds
//     solutionTag: solutionTag
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//   }
// }
// DCR to collect the data
module LinuxDiscoveryDCR '../modules/discoveryrule.bicep' = {
  name: 'LinuxDiscoveryDCR'
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
    packtag: 'LxDisc'
    packtype: 'Discovery'
    instanceName: instanceName
  }
}

// Policy to assign DCR to all Linux VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
// module policysetup '../modules/policies.bicep' = {
//   name: 'policysetup-linuxdiscovery'
//   params: {
//     dcrId: LinuxDiscoveryDCR.outputs.ruleId
//     packtag: 'LxDisc'
//     solutionTag: solutionTag
//     rulename: LinuxDiscoveryDCR.outputs.ruleName
//     location: location
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//     mgname: mgname
//     ruleshortname: ruleshortname
//     assignmentLevel: assignmentLevel
//     subscriptionId: subscriptionId
//     packtype: 'Discovery'
//     instanceName: instanceName
//   }
// }

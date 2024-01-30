targetScope = 'managementGroup'

param location string 
param solutionTag string
param subscriptionId string
param resourceGroupName string
param storageAccountname string
param imageGalleryName string
param lawResourceId string
param userManagedIdentityResourceId string
param mgname string
param assignmentLevel string
param dceId string
param tags object
param instanceName string
param tableNameToUse string
//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'amp${instanceName}windisc'
var appName = '${instanceName}-windiscovery'
var appDescription = 'Windows Workload discovery'
var OS = 'Windows'
var appVersionName = '1.0.0'
//var resourceGroupName = split(resourceGroupId, '/')[4]

//var tableNameToUse = 'Custom${tableName}_CL'
// var lawFriendlyName = split(lawResourceId,'/')[8]

// VM Application to collect the data - this would be ideally an extension
module windowsDiscoveryApp '../modules/aigapp.bicep' = {
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

module windiscovery '../modules/aigappversion.bicep' = {
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
    mediaLink: upload.outputs.fileURL
    installCommands: 'powershell -command "ren windiscovery discover.zip; expand-archive ./discover.zip . ; ./install.ps1"'
    removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'Monstar Packs Discovery\' \'\\\'"'
    tags: tags
    packageFileName: 'discover.zip'
  }
}
module applicationPolicy '../modules/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${appName}'
  params: {
    packtag: 'WinDisc'
    policyDescription: 'Install ${appName} to ${OS} VMs'
    policyName: 'Install ${appName}'
    policyDisplayName: 'Install ${appName} to ${OS} VMs'
    solutionTag: solutionTag
    vmapplicationResourceId: windiscovery.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
    packtype: 'Discovery'
  }
}
module vmapplicationAssignment '../modules/assignment.bicep' = if(assignmentLevel == 'managementGroup') {
  dependsOn: [
    applicationPolicy
  ]
  name: 'Assignment-${ruleshortname}'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: applicationPolicy.outputs.policyId
    assignmentName: 'AMP-Assign-${ruleshortname}-application'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module vmassignmentsub '../modules/sub/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
  dependsOn: [
    applicationPolicy
  ]
  name: 'AssignSub-${ruleshortname}'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: applicationPolicy.outputs.policyId
    assignmentName: 'AMP-Assign-${ruleshortname}-application'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
// DCR to collect the data
module windiscoveryDCR '../modules/discoveryrule.bicep' = {
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
    packtag: 'WinDisc'
    packtype: 'Discovery'
    instanceName: instanceName
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../modules/policies.bicep' = {
  name: 'policysetup-windoscovery'
  params: {
    dcrId: windiscoveryDCR.outputs.ruleId
    packtag: 'WinDisc'
    solutionTag: solutionTag
    rulename: windiscoveryDCR.outputs.ruleName
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
    packtype: 'Discovery'
    instanceName: instanceName
  }
}

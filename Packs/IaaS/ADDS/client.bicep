//Client is a vm application used to collect data from a VM (VM only, not Arc servers.)
targetScope = 'managementGroup'

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
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string

param storageAccountname string
param imageGalleryName string
param tableName string
param tags object
param instanceName string
param ruleshortname string
param appName string
param appDescription string
param OS string
var resourceGroupName = split(resourceGroupId, '/')[4]

var tableNameToUse = 'Custom${tableName}_CL'
var lawFriendlyName = split(workspaceId,'/')[8]

// VM Application to collect the data - this would be ideally an extension
module addscollectionapp '../../../setup/discovery/modules/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'addscollectionapp'
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
  name: 'upload-addscollectionapp'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'applications'
    filename: 'addscollection.zip'
    storageAccountName: storageAccountname
    location: location
    tags: tags
  }
}

module addscollectionappversion '../../../setup/discovery/modules/aigappversion.bicep' = {
  name: 'addscollectionappversion'
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
    mediaLink: upload.outputs.fileURL
    installCommands: 'powershell -command "ren addscollection addscollection.zip; expand-archive ./addscollection.zip . ; ./install.ps1"'
    removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'AD DS Collection Task\' \'\\\' "'
    tags: tags
    packageFileName: 'addscollection.zip'
  }
}
module applicationPolicy '../../../setup/discovery/modules/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${appName}'
  params: {
    packtag: 'ADDS'
    policyDescription: 'Install ${appName} to ${OS} VMs'
    policyName: 'Install ${appName}'
    policyDisplayName: 'Install ${appName} to ${OS} VMs'
    solutionTag: solutionTag
    vmapplicationResourceId: addscollectionappversion.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
    packtype: 'IaaS'
  }
}
module vmapplicationAssignment '../../../setup/discovery/modules/assignment.bicep' = if(assignmentLevel == 'managementGroup') {
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
module vmassignmentsub '../../../setup/discovery/modules/sub/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
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
module addscollectionDCR '../../../setup/discovery/modules/discoveryrule.bicep' = {
  dependsOn: [
    table
  ]
  name: 'addscollectionDCR'

  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      'C:\\WindowsAzure\\ADDS\\*.csv'
    ]
    kind: 'Windows'
    location: location
    lawResourceId: workspaceId
    OS: 'Windows'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: 'ADDS'
    packtype: 'IaaS'
    instanceName: instanceName
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../../../setup/discovery/modules/policies.bicep' = {
  name: 'policysetup-application-${packtag}'
  params: {
    dcrId: addscollectionDCR.outputs.ruleId
    packtag: 'ADDS'
    solutionTag: solutionTag
    rulename: addscollectionDCR.outputs.ruleName
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: ruleshortname
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
    packtype: 'IaaS'
    instanceName: instanceName
  }
}

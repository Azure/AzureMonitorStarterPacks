//Client is a vm application used to collect data from a VM (VM only, not Arc servers.)
targetScope = 'managementGroup'

@description('Name of the DCR rule to be created')
param packtag string = 'CrtW'
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

var tableNameToUse = '${tableName}_CL'
var lawFriendlyName = split(workspaceId,'/')[8]

// VM Application to collect the data - this would be ideally an extension
module certswcollectionapp '../../../setup/discovery/modules/aigapp.bicep' = {
  scope: resourceGroup(subscriptionId, resourceGroupName)
  name: 'certswcollectionapp'
  params: {
    aigname: imageGalleryName
    appDescription: appDescription
    appName: appName
    location: location
    osType: OS
    tags: tags
  }
}
module upload './upload.bicep' = {
  name: 'upload-certwcollectionapp'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    containerName: 'applications'
    filename: 'certswin.zip'
    storageAccountName: storageAccountname
    location: location
    tags: tags
  }
}

module certswcollectionappversion '../../../setup/discovery/modules/aigappversion.bicep' = {
  name: 'certswcollectionappversion'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    certswcollectionapp
  ]
  params: {
    aigname: imageGalleryName
    appName: appName
    appVersionName: '1.0.0'
    location: location
    targetRegion: location
    mediaLink: upload.outputs.fileURL
    installCommands: 'powershell -command "ren certswcollection certswin.zip; expand-archive ./certswin.zip . ; ./install.ps1"'
    removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'Certificates Win Collection Task\' \'\\\' "'
    tags: tags
    packageFileName: 'certswin.zip'
  }
}
module applicationPolicy '../../../setup/discovery/modules/vmapplicationpolicy.bicep' = {
  name: 'applicationPolicy-${appName}'
  params: {
    packtag: 'certsw'
    policyDescription: 'Install ${appName} to ${OS} VMs'
    policyName: 'Install ${appName}'
    policyDisplayName: 'Install ${appName} to ${OS} VMs'
    solutionTag: solutionTag
    vmapplicationResourceId:certswcollectionappversion.outputs.appVersionId
    roledefinitionIds: [
      '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
    ]
    packtype: 'IaaS'
  }
}
module vmapplicationAssignment '../../../setup/discovery/modules/assignment.bicep' = if(assignmentLevel == 'ManagementGroup') {
  dependsOn: [
    applicationPolicy
  ]
  name: 'Assignment-${ruleshortname}'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: applicationPolicy.outputs.policyId
    assignmentName: 'AMg-${ruleshortname}-application'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module vmassignmentsub '../../../setup/discovery/modules/sub/assignment.bicep' = if(assignmentLevel != 'ManagementGroup') {
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
module certswcollectionDCR '../../../setup/discovery/modules/discoveryrule.bicep' = {
  dependsOn: [
    table
  ]
  name: 'certscollectionDCR'

  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    endpointResourceId: dceId
    filepatterns: [
      'C:\\WindowsAzure\\certsw\\*.csv'
    ]
    kind: 'Windows'
    location: location
    lawResourceId: workspaceId
    OS: 'Windows'
    solutionTag: solutionTag
    tableName: tableNameToUse
    packtag: 'certsw'
    packtype: 'IaaS'
    instanceName: instanceName
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../../../setup/discovery/modules/policies.bicep' = {
  name: 'policysetup-application-${packtag}'
  params: {
    dcrId: certswcollectionDCR.outputs.ruleId
    packtag: 'certsw'
    solutionTag: solutionTag
    rulename: certswcollectionDCR.outputs.ruleName
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

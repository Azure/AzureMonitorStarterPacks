targetScope = 'managementGroup'


@description('Name of the DCR rule to be created')
param rulename string = 'AMSP-IIS2016-Server'
param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param packtag string = 'ADDS'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string = '0.1.0'
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string

param customerTags object
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var workspaceFriendlyName = split(workspaceId, '/')[8]
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

param storageAccountname string
param imageGalleryName string
param tableName string
param tags object

//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = 'addscollection'
var appName = 'addscollection'
var appDescription = 'AD DS Collection'
var OS = 'Windows'

//var resourceGroupName = split(resourceGroupId, '/')[4]

var tableNameToUse = 'Custom${tableName}_CL'
var lawFriendlyName = split(workspaceId,'/')[8]
var xPathQueries=[ 
]
// The performance counters define which counters are collected
var performanceCounters=[
 '\\NTDS:DirectoryServices\\DS Search sub-operations/sec'
]

// module Alerts './alerts.bicep' = {
//   name: 'Alerts-${packtag}'
//   scope: resourceGroup(subscriptionId, resourceGroupName)
//   params: {
//     location: location
//     workspaceId: workspaceId
//     AGId: actionGroupResourceId
//     packtag: packtag
//     Tags: Tags
//   }
// }
// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers: performanceCounters
    Tags: Tags
    dceId: dceId
  }
}
module policysetupDCR '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: dcrbasicvmMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: '${ruleshortname}-1'
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
  }
}
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
    removeCommands: 'Unregister-ScheduledTask -TaskName "AD DS Collection Task" "\\"'
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
    assignmentName: '${ruleshortname}-application'
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
    assignmentName: '${ruleshortname}-application'
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
  }
}

// Policy to assign DCR to all Windows VMs (in which context? MG if we want to use the same DCR for all subscriptions?)
module policysetup '../../../setup/discovery/modules/policies.bicep' = {
  name: 'policysetup-windoscovery'
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
  }
}

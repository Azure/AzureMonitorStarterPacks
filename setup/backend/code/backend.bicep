targetScope = 'managementGroup'

@secure()
param _artifactsLocationSasToken string
param _artifactsLocation string
@description('The name for the function app that you wish to create')
param functionname string
param logicappname string
param instanceName string
//param currentUserIdObject string
param location string
param storageAccountName string
param solutionTag string
//param kvname string
param lawresourceid string
param appInsightsLocation string
@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param Tags object
param subscriptionId string
param resourceGroupName string
param mgname string
param imageGalleryName string
param collectTelemetry bool
var monitoringSecretName = 'monitoringKey'
var SASecretName = 'SAKey'
var appInsightsSecretName = 'appInsightsKey'

var packPolicyRoleDefinitionIds=[
  // '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor
  // '92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
  // //Above role should be able to add diagnostics to everything according to docs.
  // '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // VM Contributor, in order to update VMs with vm Applications
  //Contributor may be needed if we want to create alerts anywhere
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
//These are specific to the scopen where the function is deployed to.
//potential issue when enabling policies to a different scope and permissions are not added to a higher scope.
var backendFunctionRoleDefinitionIds = [
  '4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
  '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // VM Contributor
  '48b40c6e-82e0-4eb3-90d5-19e40f49b624' // Arc Contributor
  'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
  '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
  '36243c78-bf99-498c-9df9-86d9f8d28608' // policy contributor
  'f1a07417-d97a-45cb-824c-7a7467783830' // Managed identity Operator
]
var packsRGroleDefinitionIds=[
  //contributor roles
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor Role Definition Id for Contributor
  //grafana admin
  '22926164-76b3-42b3-bc55-97df8dab3e41' // Grafana Admin
  //Above role should be able to add diagnostics to everything according to docs.
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]

var functionRGroleDefinitionIds=[
  'ba92f5b4-2d11-453d-a403-e96b0029c9fe'] // Storage Blob Data Contributor

var logicappRequiredRoleassignments = [
  '4633458b-17de-408a-b874-0445c86b69e6'   //keyvault reader role
]

var telemetryInfo = json(loadTextContent('./telemetry.json'))

module telemetry './nested_telemetry.bicep' =  if (collectTelemetry) {
  name: telemetryInfo.customerUsageAttribution.SolutionIdentifier
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {}
}
//var subscriptionId = subscription().subscriptionId
// var ContributorRoleDefinitionId='4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Contributor Role Definition Id for Tag Contributor
// var VMContributorRoleDefinitionId='9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
// var ArcContributorRoleDefinitionId='48b40c6e-82e0-4eb3-90d5-19e40f49b624'
// var ReaderRoleDefinitionId='acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader Role Definition Id for Reader
// var LogAnalyticsContributorRoleDefinitionId='92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
// var MonitoringContributorRoleDefinitionId='749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor

// var sasConfig = {
//   signedResourceTypes: 'sco'
//   signedPermission: 'r'
//   signedServices: 'b'
//   signedExpiry: sasExpiry
//   signedProtocol: 'https'
//   keyToSign: 'key2'
// }
module gallery './modules/aig.bicep' = {
  name: imageGalleryName
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    galleryname: imageGalleryName
    location: location
    tags: Tags
  }
}

// Module below implements function, storage account, and app insights
module backendFunction 'modules/function.bicep' = {
  name: functionname
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    functionUserManagedIdentity
    kvSecretstorage
  ]
  params: {
    appInsightsLocation: appInsightsLocation
    functionname: functionname
    lawresourceid: lawresourceid
    location: location
    Tags: Tags
    storageAccountName: storageAccountName
    userManagedIdentity: functionUserManagedIdentity.outputs.userManagedIdentityResourceId
    userManagedIdentityClientId: functionUserManagedIdentity.outputs.userManagedIdentityClientId
    packsUserManagedId: packsUserManagedIdentity.outputs.userManagedIdentityResourceId
    solutionTag: solutionTag
    instanceName: instanceName
    _artifactsLocation: _artifactsLocation
    _artifactsLocationSasToken: _artifactsLocationSasToken
    keyVaultName: keyvault.outputs.kvName
    SAkvSecretName: SASecretName
    monitoringKeyName: monitoringSecretName
    appInsightsSecretName: appInsightsSecretName
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId

  }
}

module logicapp './modules/logicapp.bicep' = {
  name: logicappname
  scope: resourceGroup(subscriptionId, resourceGroupName)
  dependsOn: [
    backendFunction
  ]
  params: {
    functioname: functionname
    logicAppName: logicappname
    location: location
    Tags: Tags
    keyvaultid: keyvault.outputs.kvResourceId
    subscriptionId: subscriptionId
  }
}
// module workbook './modules/workbook.bicep' = {
//   name: 'workbookdeployment'
//   scope: resourceGroup(subscriptionId, resourceGroupName)
//   params: {
//     lawresourceid: lawresourceid
//     location: location
//     Tags: Tags
//   }
// }

module extendedWorkbook './modules/extendedworkbook.bicep' = {
  name: 'workbook2deployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    lawresourceid: lawresourceid
    location: location
    Tags: Tags
  }
}

// A DCE in the main region to be used by all rules.
module dataCollectionEndpoint '../../../modules/DCRs/dataCollectionEndpoint.bicep' = {
  name: 'AMP-${instanceName}-DCE-${location}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    Tags: Tags
    dceName: 'AMP-${instanceName}-DCE-${location}'
  }
}

// This module creates a user managed identity for the packs to use.
module packsUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'AMP-${instanceName}-UMI-Packs'
  params: {
    location: location
    Tags: Tags
    roleDefinitionIds: packPolicyRoleDefinitionIds
    userIdentityName: 'AMP-${instanceName}-UMI-Packs'
    mgname: mgname
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    addRGRoleAssignments: true
    solutionTag: solutionTag
    RGroleDefinitionIds: packsRGroleDefinitionIds

  }
}

// module customRemdiationRole '../../../modules/rbac/subscription/remediationContributor.bicep' = {
//   name: 'customRemediationRole'
//   scope: subscription(subscriptionId)
//   params: {
//   }
// }

module functionUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'AMP-${instanceName}-UMI-Function'
  params: {
    location: location
    Tags: Tags
    roleDefinitionIds: backendFunctionRoleDefinitionIds//,array('${customRemdiationRole.outputs.roleDefId}'))
    userIdentityName: 'AMP-${instanceName}-UMI-Function'
    mgname: mgname
    resourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    solutionTag: solutionTag
    RGroleDefinitionIds: functionRGroleDefinitionIds
    addRGRoleAssignments: true
  }
}

//Add keyvault
module keyvault 'modules/keyvault.bicep' = {
  name: 'amp-${instanceName}-kv-${substring(uniqueString(subscriptionId, resourceGroupName, location, 'keyvault'), 0, 6)}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    kvName: 'amp-${instanceName}-kv-${substring(uniqueString(subscriptionId, resourceGroupName,location,'keyvault'), 0, 6)}'
    location: location
    Tags: Tags
  }
}

//Add permissions for loginapp as a user to keyvault
module userIdentityRoleAssignments '../../../modules/rbac/mg/roleassignment.bicep' =  [for (roledefinitionId, i) in logicappRequiredRoleassignments:  {
  name: 'logiapprbac-${i}'
  scope: managementGroup(mgname)
  params: {
    resourcename: keyvault.outputs.kvResourceId
    principalId: logicapp.outputs.logicAppPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]
//
// Secrets
//
module kvSecretstorage './modules/keyvaultsecretstorage.bicep' = {
  name: 'kvSecretsstorage'
  dependsOn: [
    keyvault
  ]
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    kvName: keyvault.outputs.kvName
    storageAccountName: storageAccountName
    Tags: Tags
    SASecretName: SASecretName
  }
}

module kvSecretsfunction './modules/keyvaultsecretsfunction.bicep' = {
  name: 'kvSecretsfunction'
  dependsOn: [
    keyvault
    backendFunction
  ]
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    functionName: functionname
    kvName: keyvault.outputs.kvName
    Tags: Tags
    monitoringSecretName: monitoringSecretName
  }
}

output packsUserManagedIdentityId string = packsUserManagedIdentity.outputs.userManagedIdentityPrincipalId
output packsUserManagedResourceId string = packsUserManagedIdentity.outputs.userManagedIdentityResourceId
output dceId string = dataCollectionEndpoint.outputs.dceId


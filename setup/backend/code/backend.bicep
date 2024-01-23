targetScope = 'managementGroup'

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
//param packageUri string = 'https://amonstarterpacks2abbd.blob.core.windows.net/discovery/discovery.zip'
@description('UTC timestamp used to create distinct deployment scripts for each deployment')
//param utcValue string = utcNow()
//param filename string = 'discovery.zip'
//param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param Tags object
param subscriptionId string
param resourceGroupName string
param mgname string
param imageGalleryName string

var packPolicyRoleDefinitionIds=[
  // '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor
  // '92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
  // //Above role should be able to add diagnostics to everything according to docs.
  // '9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // VM Contributor, in order to update VMs with vm Applications
  //Contributor may be needed if we want to create alerts anywhere
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]

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
var logicappRequiredRoleassignments = [
  '4633458b-17de-408a-b874-0445c86b69e6'   //keyvault reader role
]
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
module workbook './modules/workbook.bicep' = {
  name: 'workbookdeployment'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    lawresourceid: lawresourceid
    location: location
    Tags: Tags
  }
}

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
  }
}

//Add keyvault
module keyvault 'modules/keyvault.bicep' = {
  name: 'amp-${instanceName}-kv-${substring(uniqueString(subscriptionId, resourceGroupName, 'keyvault'), 0, 6)}'
  dependsOn: [
    backendFunction
  ]
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    kvName: 'amp-${instanceName}-kv-${substring(uniqueString(subscriptionId, resourceGroupName, 'keyvault'), 0, 6)}'
    location: location
    Tags: Tags
    functionName: functionname
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

output packsUserManagedIdentityId string = packsUserManagedIdentity.outputs.userManagedIdentityPrincipalId
output packsUserManagedResourceId string = packsUserManagedIdentity.outputs.userManagedIdentityResourceId
output dceId string = dataCollectionEndpoint.outputs.dceId


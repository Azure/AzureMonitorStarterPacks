@description('The name for the function app that you wish to create')
param functionname string
param currentUserIdObject string
param location string
param storageAccountName string
//param kvname string
param lawresourceid string
param appInsightsLocation string
//param packageUri string = 'https://amonstarterpacks2abbd.blob.core.windows.net/discovery/discovery.zip'
@description('UTC timestamp used to create distinct deployment scripts for each deployment')
//param utcValue string = utcNow()
param filename string = 'discovery.zip'
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param solutionTag string
@secure()

param solutionVersion string

var discoveryContainerName = 'discovery'
var tempfilename = '${filename}.tmp'
//Role definition Ids for policy remediation
// var LogAnalyticsContributorRoleDefinitionId='92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
// var MonitoringContributorRoleDefinitionId='749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor
var packPolicyRoleDefinitionIds=[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor Role Definition Id for Monitoring Contributor
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor Role Definition Id for Log Analytics Contributor
  //Above role should be able to add diagnostics to everything according to docs.
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]

var backendFunctionRoleDefinitionIds = [
  '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
  '/providers/Microsoft.Authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c' // VM Contributor
  '/providers/Microsoft.Authorization/roleDefinitions/48b40c6e-82e0-4eb3-90d5-19e40f49b624' // Arc Contributor
  '/providers/Microsoft.Authorization/roleDefinitions/acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
  '/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
  '/providers/Microsoft.Authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor
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

// Module below implements function, storage account, and app insights
module backendFunction 'modules/function.bicep' = {
  name: 'backendFunciton'
  params: {
    appInsightsLocation: appInsightsLocation
    functionname: functionname
    lawresourceid: lawresourceid
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    storageAccountName: storageAccountName
    userManagedIdentity: functionUserManagedIdentity.outputs.userManagedIdentityId
  }
}
//Storage Account
// resource discoveryStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
//   name: storageAccountName
//   location: location
//   tags: {
//     '${solutionTag}': 'storageaccount'
//     '${solutionTag}-Version': solutionVersion
//   }
//   sku: {
//     name: 'Standard_LRS'
//   }
//   kind: 'StorageV2'
//   properties: {
//     accessTier: 'Hot'
//     allowBlobPublicAccess: false
//     allowSharedKeyAccess: true
//     supportsHttpsTrafficOnly: true
//   }
//   resource blobServices 'blobServices'={
//     name: 'default'
//     properties: {
//         cors: {
//             corsRules: []
//         }
//         deleteRetentionPolicy: {
//             enabled: false
//         }
//     }
//     resource container1 'containers'={
//       name: 'discovery'
//       properties: {
//         immutableStorageWithVersioning: {
//             enabled: false
//         }
//         denyEncryptionScopeOverride: false
//         defaultEncryptionScope: '$account-encryption-key'
//         publicAccess: 'None'
//       }
//     }
//   }
// }

// module customRemdiationRole '../../../modules/rbac/subscription/remediationContributor.bicep' = {
//   name: 'customRemediationRole'
//   scope: subscription()
//   params: {
//   }
// }

// resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
//   name: '${functionname}-farm'
//   location: location
//   tags: {
//     '${solutionTag}': 'serverfarm'
//     '${solutionTag}-Version': solutionVersion
//   }
//   sku: {
//     name: 'Y1'
//     tier: 'Dynamic'
//     size: 'Y1'
//     family: 'Y'
//     capacity: 0
//   }
//   kind: 'functioapp'
//   properties: {
//     perSiteScaling: false
//     elasticScaleEnabled: false
//     maximumElasticWorkerCount: 1
//     isSpot: false
//     reserved: false
//     isXenon: false
//     hyperV: false
//     targetWorkerCount: 0
//     targetWorkerSizeId: 0
//     zoneRedundant: false
//   }
// }
// resource azfunctionsite 'Microsoft.Web/sites@2021-03-01' = {
//   name: functionname
//   location: location
//   kind: 'functionapp'
//   tags: {
//     '${solutionTag}': 'site'
//     '${solutionTag}-Version': solutionVersion
//   }
//   identity: {
//       type: 'UserAssigned'
//       userAssignedIdentities: {
//           '${functionUserManagedIdentity.outputs.userManagedIdentityId}': {}
//       }
//   }  
//   properties: {
//       enabled: true      
//       hostNameSslStates: [
//           {
//               name: '${functionname}.azurewebsites.net'
//               sslState: 'Disabled'
//               hostType: 'Standard'
//           }
//           {
//               name: '${functionname}.azurewebsites.net'
//               sslState: 'Disabled'
//               hostType: 'Repository'
//           }
//       ]
//       serverFarmId: serverfarm.id
//       reserved: false
//       isXenon: false
//       hyperV: false
//       siteConfig: {
//           numberOfWorkers: 1
//           acrUseManagedIdentityCreds: false
//           alwaysOn: false
//           ipSecurityRestrictions: [
//               {
//                   ipAddress: 'Any'
//                   action: 'Allow'
//                   priority: 1
//                   name: 'Allow all'
//                   description: 'Allow all access'
//               }
//           ]
//           scmIpSecurityRestrictions: [
//               {
//                   ipAddress: 'Any'
//                   action: 'Allow'
//                   priority: 1
//                   name: 'Allow all'
//                   description: 'Allow all access'
//               }
//           ]
//           http20Enabled: false
//           functionAppScaleLimit: 200
//           minimumElasticInstanceCount: 0
//       }
//       scmSiteAlsoStopped: false
//       clientAffinityEnabled: false
//       clientCertEnabled: false
//       clientCertMode: 'Required'
//       hostNamesDisabled: false
//       containerSize: 1536
//       dailyMemoryTimeQuota: 0
//       httpsOnly: false
//       redundancyMode: 'None'
//       storageAccountRequired: false
//       keyVaultReferenceIdentity: 'SystemAssigned'
//   }
// }

// resource azfunctionsiteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
//   name: 'appsettings'
//   parent: azfunctionsite
//   properties: {
//     WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
//     AzureWebJobsStorage:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
//     WEBSITE_CONTENTSHARE : discoveryStorage.name
//     FUNCTIONS_WORKER_RUNTIME:'powershell'
//     FUNCTIONS_EXTENSION_VERSION:'~4'
//     ResourceGroup: resourceGroup().name
//     SolutionTag: solutionTag
//     APPINSIGHTS_INSTRUMENTATIONKEY: reference(appinsights.id, '2020-02-02-preview').InstrumentationKey
//     APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${reference(appinsights.id, '2020-02-02-preview').InstrumentationKey}'
//     ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
//   }
// }

// resource deployfunctions 'Microsoft.Web/sites/extensions@2021-02-01' = {
//   parent: azfunctionsite
//   dependsOn: [
//     deploymentScript
//   ]
//   name: 'MSDeploy'
//   properties: {
//     packageUri: '${discoveryStorage.properties.primaryEndpoints.blob}${discoveryContainerName}/${filename}?${(discoveryStorage.listAccountSAS(discoveryStorage.apiVersion, sasConfig).accountSasToken)}'
//   }
// }

// resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
//   name: functionname
//   tags: {
//     '${solutionTag}': 'InsightsComponent'
//     '${solutionTag}-Version': solutionVersion
//   }
//   location: appInsightsLocation
//   kind: 'web'
//   properties: {
//     Application_Type: 'web'
//     //ApplicationId: guid(functionname)
//     //Flow_Type: 'Redfield'
//     //Request_Source: 'IbizaAIExtension'
//     publicNetworkAccessForIngestion: 'Enabled'
//     publicNetworkAccessForQuery: 'Enabled'
//     WorkspaceResourceId: lawresourceid
//   }
// }

// var keyName = 'monitoringKey'

// resource monitoringkey 'Microsoft.Web/sites/host/functionKeys@2022-03-01' = { 
//   dependsOn: [ 
//     azfunctionsiteconfig 
//   ] 
//   name: '${functionname}/default/${keyName}'  
//   properties: {  
//     name: keyName  
//     value: apiManagementKey
//   }  
// } 

// module functionReadert '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionReaderRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: ReaderRoleDefinitionId
//     roleShortName: 'Reader'
//   }
// }

// module functionTagContributor '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionTagContributorRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: ContributorRoleDefinitionId
//     roleShortName: 'TagContributor'
//   }
// }
// module functionVMContributor '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionvmContributorRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: VMContributorRoleDefinitionId
//     roleShortName: 'vmcontributor'
//   }
// }
// module functionArcContributor '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionArcContributorRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: ArcContributorRoleDefinitionId
//     roleShortName: 'arccontributor'
//   }
// }
// // Custom role for remediation of policies. Policy Contributor could be used instead but this is as restrictive as possible.
// module functionRemediationRole '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionRemediationRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: customRemdiationRole.outputs.roleDefId //remediationRoleDefinitionId
//     roleShortName: 'remediation'
//   }
// }
// module functionMonitorContributorRole '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionMonitorContributorRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: MonitoringContributorRoleDefinitionId
//     roleShortName: 'monitorcontributor'
//   }
// }

// module functionLogAnalyticsContributorRole '../../../modules/rbac/subscription/roleassignment.bicep' = {
//   name: 'functionLogAnalyticsContributorRole'
//   scope: subscription()
//   params: {
//     resourcename: functionname
//     principalId: azfunctionsite.identity.principalId
//     solutionTag: solutionTag
//     resourceGroup: resourceGroup().name
//     roleDefinitionId: LogAnalyticsContributorRoleDefinitionId
//     roleShortName: 'loganalyticscontributor'
//   }
// }

module logicapp './modules/logicapp.bicep' = {
  name: 'BackendLogicApp'
  dependsOn: [
    backendFunction
  ]
  params: {
    functioname: functionname
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
module workbook './modules/workbook.bicep' = {
  name: 'workbookdeployment'
  params: {
    lawresourceid: lawresourceid
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
module amg 'modules/grafana.bicep' = {
  name: 'azureManagedGrafana'
  params: {
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    location: location
    grafanaName: 'MonstarPacks'
    userObjectId: currentUserIdObject
  }
}

// A DCE in the main region to be used by all rules.
module dataCollectionEndpoint '../../../modules/DCRs/dataCollectionEndpoint.bicep' = {
  name: 'DCE-${solutionTag}-${location}'
  params: {
    location: location
    packtag: 'dceMainRegion'
    solutionTag: solutionTag
    dceName: 'DCE-${solutionTag}-${location}'
  }
}

// This module creates a user managed identity for the packs to use.
module packsUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'packsUserManagedIdentity'
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    roleDefinitionIds: packPolicyRoleDefinitionIds
    userIdentityName: 'packsUserManagedIdentity'
  }
}

module functionUserManagedIdentity 'modules/userManagedIdentity.bicep' = {
  name: 'functionUserManagedIdentity'
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    roleDefinitionIds: backendFunctionRoleDefinitionIds
    userIdentityName: 'functionUserManagedIdentity'
  }
}
// resource packsUserManagedIdentity2 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: 'policyremediationidentity'
//   location: location
//   tags: {
//     '${solutionTag}': 'packManagedIdentity'
//     '${solutionTag}-Version': solutionVersion
//   }
// }

// resource roleassignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roledefinitionId, i) in packPolicyRoleDefinitionIds:  {
//   name: guid('monstarpacksuserid-${subscription().subscriptionId}-${i}')
//   properties: {
//     roleDefinitionId: roledefinitionId
//     principalId: packsUserManagedIdentity.id
//     principalType: 'ServicePrincipal'
//     description: 'Role assignment for Monstar packs with "${guid('monstarpacksuserid-${subscription().subscriptionId}-${i}')}" role definition id.'
//   }
// }]
//output functionkey string = listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
output packsUserManagedIdentityId string = packsUserManagedIdentity.outputs.userManagedIdentityId

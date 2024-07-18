param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string
param SAkvSecretName string
param appInsightsSecretName string
param functionname string
param location string
param Tags object
param userManagedIdentity string
param userManagedIdentityClientId string
param packsUserManagedId string
param storageAccountName string
param filename string = 'discovery.zip'
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param lawresourceid string
param appInsightsLocation string
param monitoringKeyName string
param keyVaultName string
param subscriptionId string
param resourceGroupName string

var discoveryContainerName = 'discovery'
var tempfilename = '${filename}.tmp'
param apiManagementKey string= base64(newGuid())
param solutionTag string
param instanceName string

var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: sasExpiry
  signedProtocol: 'https'
  keyToSign: 'key2'
}
resource discoveryStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-Function-${instanceName}'
  dependsOn: [
    azfunctionsiteconfig
  ]
  tags: Tags
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentity}': {}
    }
  }
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: discoveryStorage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: discoveryStorage.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadFileAsBase64('../../backend.zip')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${filename} && az storage blob upload -f ${filename} -c ${discoveryContainerName} -n ${filename} --overwrite true'
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${functionname}-farm'
  location: location
  tags: Tags
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  kind: 'functioapp'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: false
    maximumElasticWorkerCount: 1
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}
resource azfunctionsite 'Microsoft.Web/sites@2023-01-01' = {
  name: functionname
  location: location
  kind: 'functionapp'
  tags: Tags
  identity: {
      type: 'SystemAssigned, UserAssigned'
      userAssignedIdentities: {
          '${userManagedIdentity}': {}
      }
  }  
  properties: {
      enabled: true      
      hostNameSslStates: [
          {
              name: '${functionname}.azurewebsites.net'
              sslState: 'Disabled'
              hostType: 'Standard'
          }
          {
              name: '${functionname}.azurewebsites.net'
              sslState: 'Disabled'
              hostType: 'Repository'
          }
      ]
      serverFarmId: serverfarm.id
      reserved: false
      isXenon: false
      hyperV: false
      siteConfig: {
          numberOfWorkers: 1
          acrUseManagedIdentityCreds: false
          alwaysOn: false
          ipSecurityRestrictions: [
              {
                  ipAddress: 'Any'
                  action: 'Allow'
                  priority: 1
                  name: 'Allow all'
                  description: 'Allow all access'
              }
          ]
          scmIpSecurityRestrictions: [
              {
                  ipAddress: 'Any'
                  action: 'Allow'
                  priority: 1
                  name: 'Allow all'
                  description: 'Allow all access'
              }
          ]
          http20Enabled: false
          functionAppScaleLimit: 200
          minimumElasticInstanceCount: 0
          minTlsVersion: '1.2'
          cors: {
              allowedOrigins: [
                  'https://portal.azure.com'
              ]
              supportCredentials: true
          }  
      }
      scmSiteAlsoStopped: false
      clientAffinityEnabled: false
      clientCertEnabled: false
      clientCertMode: 'Required'
      hostNamesDisabled: false
      containerSize: 1536
      dailyMemoryTimeQuota: 0
      httpsOnly: true
      redundancyMode: 'None'
      storageAccountRequired: false
      keyVaultReferenceIdentity: 'SystemAssigned'
  }
}
// var functionSystemAssignedIdentityRoles= [
//   '4633458b-17de-408a-b874-0445c86b69e6'   //keyvault reader role
// ]

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' =  [for (roledefinitionId, i) in functionSystemAssignedIdentityRoles:  {
//   name: guid('${functionname}-role-assignment-${i}',resourceGroup().name)
//   properties: {
//     description: '${functionname}-${functionSystemAssignedIdentityRoles[0]}'
//     principalId: azfunctionsite.identity.principalId
//     principalType: 'ServicePrincipal'
//     roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roledefinitionId)
//   }
// }]

resource azfunctionsiteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  parent: azfunctionsite
  // dependsOn: [
  //   roleAssignment
  // ]
  properties: {
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    AzureWebJobsStorage:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    WEBSITE_CONTENTSHARE : discoveryStorage.name
    FUNCTIONS_WORKER_RUNTIME:'powershell'
    FUNCTIONS_EXTENSION_VERSION:'~4'
    ResourceGroup: resourceGroup().name
    SolutionTag: solutionTag
    APPINSIGHTS_INSTRUMENTATIONKEY: reference(appinsights.id, '2020-02-02-preview').InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${reference(appinsights.id, '2020-02-02-preview').InstrumentationKey}'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    MSI_CLIENT_ID: userManagedIdentityClientId
    PacksUserManagedId: packsUserManagedId
    ARTIFACS_LOCATION: _artifactsLocation
    ARTIFACTS_LOCATION_SAS_TOKEN: _artifactsLocationSasToken
    // WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${SAkvSecretName}'
    // //WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${SAkvSecretName})'
    // //AzureWebJobsStorage:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    // //AzureWebJobsStorage:'@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${SAkvSecretName}'
    // WEBSITE_SKIP_CONTENTSHARE_VALIDATION: '1'
    // //AzureWebJobsStorage__accountName: discoveryStorage.name
    // WEBSITE_CONTENTSHARE : discoveryStorage.name
    // FUNCTIONS_WORKER_RUNTIME:'powershell'
    // FUNCTIONS_EXTENSION_VERSION:'~4'
    // ResourceGroup: resourceGroup().name
    // SolutionTag: solutionTag
    // APPINSIGHTS_INSTRUMENTATIONKEY: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${appInsightsSecretName}'
    // APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=${appInsightsSecretName}'
    // ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
    // MSI_CLIENT_ID: userManagedIdentityClientId
    // PacksUserManagedId: packsUserManagedId
    // ARTIFACS_LOCATION: _artifactsLocation
    // ARTIFACTS_LOCATION_SAS_TOKEN: _artifactsLocationSasToken
  }
}
resource deployfunctions 'Microsoft.Web/sites/extensions@2021-02-01' = {
  parent: azfunctionsite
  dependsOn: [
    deploymentScript
  ]
  name: 'MSDeploy'
  properties: {
    packageUri: '${discoveryStorage.properties.primaryEndpoints.blob}${discoveryContainerName}/${filename}?${(discoveryStorage.listAccountSAS(discoveryStorage.apiVersion, sasConfig).accountSasToken)}'
  }
}
resource appinsights 'Microsoft.Insights/components@2020-02-02' = {
  name: functionname
  tags: Tags
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    //ApplicationId: guid(functionname)
    //Flow_Type: 'Redfield'
    //Request_Source: 'IbizaAIExtension'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: lawresourceid
  }
}

module kvSecretsAppInsights '../modules/keyvaultsecretAppInsights.bicep' = {
  name: 'kvSecretAppInsights'
  dependsOn: [
    appinsights
  ]
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    kvName: keyVaultName
    Tags: Tags
    appInsightsName: appinsights.name
    appInsightsSecretName: appInsightsSecretName
  }
}
resource monitoringkey 'Microsoft.Web/sites/host/functionKeys@2022-03-01' = { 
  dependsOn: [ 
    azfunctionsiteconfig 
  ]
  tags: Tags
  name: '${functionname}/default/${monitoringKeyName}'  
  properties: {  
    name: monitoringKeyName  
    value: apiManagementKey
  }  
} 


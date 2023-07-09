@description('The name for the function app that you wish to create')
param functionname string
param location string
param storageAccountName string
//param kvname string
param lawresourceid string
param appInsightsLocation string
//param packageUri string = 'https://amonstarterpacks2abbd.blob.core.windows.net/discovery/discovery.zip'
@description('UTC timestamp used to create distinct deployment scripts for each deployment')
param utcValue string = utcNow()
param filename string = 'discovery.zip'
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param tagname string


var se= '2023-07-25T00:00:00Z'

var discoveryContainerName = 'discovery'
var tempfilename = '${filename}.tmp'


var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: se
  signedProtocol: 'https'
  keyToSign: 'key2'
}
//Storage Account
resource discoveryStorage 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: storageAccountName
  location: location
  tags: {
    tagname: 'storageaccount'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
  }
  resource blobServices 'blobServices'={
    name: 'default'
    properties: {
        cors: {
            corsRules: []
        }
        deleteRetentionPolicy: {
            enabled: false
        }
    }
    resource container1 'containers'={
      name: 'discovery'
      properties: {
        immutableStorageWithVersioning: {
            enabled: false
        }
        denyEncryptionScopeOverride: false
        defaultEncryptionScope: '$account-encryption-key'
        publicAccess: 'None'
      }
    }
  }
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-upload-blob-${utcValue}'
  dependsOn: [
    azfunctionsite
  ]
  tags: {
    tagname: 'deploymentScript'
  }
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
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
        value: loadFileAsBase64('../../../../../../tmp/discovery.zip')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${filename} && az storage blob upload -f ${filename} -c ${discoveryContainerName} -n ${filename}'
  }
}

resource serverfarm 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${functionname}-farm'
  location: location
  tags: {
    tagname: 'serverfarm'
  }
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
resource azfunctionsite 'Microsoft.Web/sites@2021-03-01' = {
  name: functionname
  location: location
  kind: 'functionapp'
  tags: {
    tagname: 'site'
  }
  identity: {
      type: 'SystemAssigned'
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
      }
      scmSiteAlsoStopped: false
      clientAffinityEnabled: false
      clientCertEnabled: false
      clientCertMode: 'Required'
      hostNamesDisabled: false
      containerSize: 1536
      dailyMemoryTimeQuota: 0
      httpsOnly: false
      redundancyMode: 'None'
      storageAccountRequired: false
      keyVaultReferenceIdentity: 'SystemAssigned'
  }
}
resource azfunctionsiteconfig 'Microsoft.Web/sites/config@2021-03-01' = {
  name: 'appsettings'
  parent: azfunctionsite
  properties: {
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    AzureWebJobsStorage:'DefaultEndpointsProtocol=https;AccountName=${discoveryStorage.name};AccountKey=${listKeys(discoveryStorage.id, discoveryStorage.apiVersion).keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    WEBSITE_CONTENTSHARE : discoveryStorage.name
    FUNCTIONS_WORKER_RUNTIME:'powershell'
    FUNCTIONS_EXTENSION_VERSION:'~4'
    ResourceGroup: resourceGroup().name
    APPINSIGHTS_INSTRUMENTATIONKEY: reference(appinsights.id, '2020-02-02-preview').InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: 'InstrumentationKey=${reference(appinsights.id, '2020-02-02-preview').InstrumentationKey}'
    ApplicationInsightsAgent_EXTENSION_VERSION: '~2'
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
  tags: {
    tagname: 'InsightsComponent'
  }
  location: appInsightsLocation
  kind: 'web'
  properties: {
    Application_Type: 'web'
    //ApplicationId: guid(functionname)
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    WorkspaceResourceId: lawresourceid
  }
}

resource logicapp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'Discovery'
  tags: {
    tagname: 'logicapp'
  }
  dependsOn: [
    deployfunctions
  ]
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
        '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
        contentVersion: '1.0.0.0'
        parameters: {}
        triggers: {
            manual: {
              type: 'Request'
              kind: 'Http'
              inputs: {}
            }
        }
        actions: {
            tagmgmt: {
                runAfter: {}
                type: 'Function'
                inputs: {
                    body: '@triggerBody()'
                    function: {
                        id: '${azfunctionsite.id}/functions/tagmgmt'
                    }
                }
            }
        }
        outputs: {}
    }
    parameters: {}
  }
}
var wbConfig = loadTextContent('amsp.workbook')
// var wbConfig2='"/subscriptions/${subscriptionId}/resourceGroups/${rg}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}"]}'
// //var wbConfig3='''
// //'''
// // var wbConfig='${wbConfig1}${wbConfig2}${wbConfig3}'
// var wbConfig='${wb}${wbConfig2}'

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  location: location
  tags: {
    tagname: 'mainworkbook'
  }
  kind: 'shared'
  name: guid('monstar')
  properties:{
    displayName: 'Azure Monitor Starter Packs'
    serializedData: wbConfig
    category: 'workbook'
    sourceId: lawresourceid
  }
}
// output sas string = '${discoveryStorage.properties.primaryEndpoints.blob}${discoveryContainerName}/${filename}?${(discoveryStorage.listAccountSAS(discoveryStorage.apiVersion, sasConfig).accountSasToken)}'

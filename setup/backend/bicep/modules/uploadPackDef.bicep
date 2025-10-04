param location string
param storageAccountName string
//param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param filename string
param containerName string
param UserManagedIdentityId string
//param resourceName string
param tags object


var tempfilename = 'download'
// var sasConfig = {
//   signedResourceTypes: 'sco'
//   signedPermission: 'r'
//   signedServices: 'b'
//   signedExpiry: sasExpiry
//   signedProtocol: 'https'
//   keyToSign: 'key2'
// }
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2023-08-01' = {
  name: 'deployscript-PacksDef-${filename}'
  tags: tags
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${UserManagedIdentityId}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    // storageAccountSettings: {
    //   storageAccountName: packStorage.name
    //   //sasToken: packStorage.listServiceSas(sasConfig).serviceSasToken
    // }
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: packStorage.name
      }
      {
        name: 'CONTENT'
        value: loadFileAsBase64('../../../../Packs/PacksDef.zip')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename}.tmp && cat ${tempfilename}.tmp | base64 -d > ${tempfilename}.zip && unzip ${tempfilename}.zip  && az storage blob upload -f ${filename} -c ${containerName} -n ${filename} --overwrite true'
  }
}

output fileURL string = '${packStorage.properties.primaryEndpoints.blob}${containerName}/${filename}'

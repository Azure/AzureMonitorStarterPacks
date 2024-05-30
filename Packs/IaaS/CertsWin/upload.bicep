param location string
param storageAccountName string
param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
param filename string
param containerName string
//param resourceName string
param tags object
var discoveryContainerName = 'applications'


var tempfilename = 'download.tmp'
var sasConfig = {
  signedResourceTypes: 'sco'
  signedPermission: 'r'
  signedServices: 'b'
  signedExpiry: sasExpiry
  signedProtocol: 'https'
  keyToSign: 'key2'
}
resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-addappdiscovery'
  tags: tags
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'AZURE_STORAGE_ACCOUNT'
        value: packStorage.name
      }
      {
        name: 'AZURE_STORAGE_KEY'
        secureValue: packStorage.listKeys().keys[0].value
      }
      {
        name: 'CONTENT'
        value: loadFileAsBase64('./certswin.zip')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${filename} && az storage blob upload -f ${filename} -c ${discoveryContainerName} -n ${filename} --overwrite true'
  }
}

output fileURL string = '${packStorage.properties.primaryEndpoints.blob}${containerName}/${filename}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'

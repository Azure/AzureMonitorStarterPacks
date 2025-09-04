param kvName string
param Tags object 
param storageAccountName string
param SASecretName string


// resource azfunctionsite 'Microsoft.Web/sites@2022-09-01' existing = {
//   name: functionName
// }
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
}
// resource storageAccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
//   name: storageAccountName
// }
// // Add secret from function
// resource kvsecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
//   name: monitoringSecretName
//   tags: Tags
//   parent: keyvault
//   properties: {
//     attributes: {
//       enabled: true
//     }
//     contentType: 'string'
//     value: listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
//   }
// }
// Add storage account key a secret
resource kvsecret2 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: SASecretName
  tags: Tags
  parent: keyvault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};AccountKey=${listKeys(resourceId('Microsoft.Storage/storageAccounts', storageAccountName), '2021-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}

param kvName string
param Tags object 
param functionName string
param monitoringSecretName string

resource azfunctionsite 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionName
}
resource keyvault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: kvName
}

// Add secret from function
resource kvsecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: monitoringSecretName
  tags: Tags
  parent: keyvault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
  }
}

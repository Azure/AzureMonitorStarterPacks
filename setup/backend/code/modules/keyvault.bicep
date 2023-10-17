param kvName string
param location string
param solutionTag string
param solutionVersion string
param functionName string

var vaultUri = 'https://${kvName}.vault.azure.net'


resource azfunctionsite 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functionName
}

resource monstarvault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: kvName
  location: location
  tags: {
    '${solutionTag}': 'KeyVault'
    '${solutionTag}-Version': solutionVersion
  }
  properties: {
    sku: {
      family: 'A'
      name:  'standard'
    }
    tenantId: subscription().tenantId
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false
    enableSoftDelete: false
    softDeleteRetentionInDays: 90
    enableRbacAuthorization: true
    vaultUri: vaultUri
    provisioningState: 'Succeeded'
    publicNetworkAccess: 'Enabled'
  }
}
// Add secret from function
resource kvsecret1 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'FunctionKey'
  parent: monstarvault
  properties: {
    attributes: {
      enabled: true
    }
    contentType: 'string'
    value: listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
  }
}

output kvResourceId string = monstarvault.id

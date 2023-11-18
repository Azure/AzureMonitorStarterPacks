param storageAccountName string
param location string
param solutionTag string
param solutionVersion string

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: {
    '${solutionTag}': 'storageaccount'
    '${solutionTag}-Version': solutionVersion
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
output storageAccountName string = storageAccount.name
output storageAccountResourceId string = storageAccount.id

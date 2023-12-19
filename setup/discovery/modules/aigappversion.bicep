param aigname string
param appName string
param appVersionName string
param location string
param targetRegion string
param mediaLink string
param installCommands string
param removeCommands string

resource aig 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: aigname
  scope: resourceGroup()
}

resource app1 'Microsoft.Compute/galleries/applications@2022-03-03' existing = {
  parent: aig
  name: appName
}

resource appVersion 'Microsoft.Compute/galleries/applications/versions@2022-03-03' = {
  parent: app1
  name: appVersionName
  location: location
  properties: {
    publishingProfile:{
      source: {
        mediaLink: mediaLink
      }
      manageActions: {
        install: installCommands
        remove: removeCommands
      }
      settings: {}
      enableHealthCheck: false
      targetRegions: [
        {
          name: targetRegion
          regionalReplicaCount: 1
          storageAccountType: 'Standard_LRS'
        }
      ]
      replicaCount: 1
      excludeFromLatest: false
      storageAccountType: 'Standard_LRS'
    }
  }
}
output appVersionId string = appVersion.id

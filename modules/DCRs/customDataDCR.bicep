param location string 
param solutionTag string
param workspaceResourceId string
param tableName string
param packtag string
param kind string
param filepatterns array
param OS string
param packtype string
@description('Specifies the resource id of the data collection endpoint.')
param dceId string
param instanceName string
param retentionDays int = 31
param rulename string
param tags object = {}
// param storageAccountname string
// param tags object
// param imageGalleryName string
// param appName string
// param appDescription string
// param sasExpiry string = dateTimeAdd(utcNow(), 'PT2H')
// var sasConfig = {
//   signedResourceTypes: 'sco'
//   signedPermission: 'r'
//   signedServices: 'b'
//   signedExpiry: sasExpiry
//   signedProtocol: 'https'
//   keyToSign: 'key2'
// }
var tableNameToUse  = '${tableName}_CL'
var streamName= 'Custom-${tableName}_CL'
var lawFriendlyName = split(workspaceResourceId,'/')[8]

resource fileCollectionRule 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
  name: rulename
  location: location
  tags: {
    '${solutionTag}': packtag
      instanceName: instanceName
    MonitoringPackType: packtype
  }
  kind: kind
  properties: {
    dataSources: {
      logFiles: [
        {
            streams: [
              streamName
            ]
            filePatterns: filepatterns
            format: 'text'
            settings: {
              text: {
                  recordStartTimestampFormat: 'ISO 8601'
              }
            }
            name: tableName
        }
      ]
    }
    destinations:  {
      logAnalytics : [
          {
              workspaceResourceId: workspaceResourceId
              name: lawFriendlyName
          }
      ]
    }
    dataFlows: [
      {
          streams: [
            streamName
          ]
          destinations: [
              lawFriendlyName
          ]
          transformKql: 'source'
          outputStream: streamName
      }
    ]
    dataCollectionEndpointId: dceId
    streamDeclarations: {
      '${streamName}': {
        columns: [
          {
            name: 'TimeGenerated'
            type: 'datetime'
          }
          {
            name: 'RawData'
            type: 'string'
          }
        ]
      }
    }
  }
}
// module addscollectionapp '../discovery/aigapp.bicep' = {
//   name: 'addscollectionapp-${instanceName}'
//   params: {
//     aigname: imageGalleryName
//     appDescription: appDescription
//     appName: appName
//     location: location
//     osType: OS
//     tags: tags
//   }
// }

// module upload '../ImageGallery/uploadDS.bicep' = {
//   name: 'upload-addscollectionapp-${instanceName}'
//   params: {
//     containerName: 'applications'
//     filename: 'addscollection.zip'
//     storageAccountName: storageAccountname
//     location: location
//     tags: tags
//     instanceName: instanceName
//   }
// }
// resource packStorage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
//   name: storageAccountname
// }
// module addscollectionappversion '../discovery/aigappversion.bicep' = {
//   name: 'addscollectionappversion-${instanceName}'
//   dependsOn: [
//     addscollectionapp
//   ]
//   params: {
//     aigname: imageGalleryName
//     appName: appName
//     appVersionName: '1.0.0'
//     location: location
//     targetRegion: location
//     mediaLink: '${upload.outputs.fileURL}?${(packStorage.listAccountSAS(packStorage.apiVersion, sasConfig).accountSasToken)}'
//     installCommands: 'powershell -command "ren addscollection addscollection.zip; expand-archive ./addscollection.zip . ; ./install.ps1"'
//     removeCommands: 'powershell -command "Unregister-ScheduledTask -TaskName \'AD DS Collection Task\' \'\\\' "'
//     tags: tags
//     packageFileName: 'addscollection.zip'
//   }
// }

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: lawFriendlyName
}

resource featuresTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  name: tableNameToUse
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: tableNameToUse
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'RawData'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

output ruleId string = fileCollectionRule.id
output ruleName string = fileCollectionRule.name

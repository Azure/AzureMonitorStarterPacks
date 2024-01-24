targetScope = 'resourceGroup'

param avdLogAlertsUri string
param primaryScriptUri string
param AGId string
param location string = resourceGroup().location
param solutionTag string
param packtag string
param templateUri string
param workspaceId string
param userManagedIdentityResourceId string
param Tags object

var dsArguments = '-Environment ${environment().name} -TenantId ${subscription().tenantId} -resourceGroup ${resourceGroup().name} -avdLogAlertsUri ${avdLogAlertsUri} -templateUri ${templateUri} -Tags """${Tags}""" -AGId ${AGId} -modulePrefix ${solutionTag} -packtag ${packtag} -workspaceId ${workspaceId} -location ${location}'

resource deployScriptAVD 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-AVDHostMapping'
  tags: Tags
  location: location
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${userManagedIdentityResourceId}': {}
    }
  }
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '7.0'
    arguments: dsArguments
    timeout: 'PT10M'
    retentionInterval: 'PT2H'
    primaryScriptUri: primaryScriptUri
    cleanupPreference: 'OnExpiration'
  }
}


output AVDHostMap object = deployScriptAVD.properties.outputs

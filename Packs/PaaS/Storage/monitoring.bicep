targetScope = 'managementGroup'

param packtag string = 'Storage'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string = '0.1.0'
param actionGroupResourceId string
@description('Name of the DCR rule to be created')
param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string

@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')

param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
param grafanaName string
//param solutionVersion string
param customerTags object 
var Tags = (customerTags=={}) ? {'${solutionTag}': packtag
'solutionVersion': solutionVersion} : union({
  '${solutionTag}': packtag
  'solutionVersion': solutionVersion
},customerTags['All'])
var resourceGroupName = split(resourceGroupId, '/')[4]

var resourceType = 'Microsoft.Storage/storageaccounts'

module StorageAlerts 'alerts.bicep' = {
  name: '${packtag}-Alerts'
  params: {
    packTag: packtag
    policyLocation: location
    solutionTag: solutionTag
    parResourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    mgname: mgname
    resourceType: resourceType
    assignmentLevel: assignmentLevel
    userManagedIdentityResourceId: userManagedIdentityResourceId
    AGId: actionGroupResourceId

  }
}

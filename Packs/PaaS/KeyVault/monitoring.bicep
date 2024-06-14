targetScope = 'managementGroup'

param packtag string = 'KeyVault'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string 
param actionGroupResourceId string
// @description('Name of the DCR rule to be created')
// param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
// @description('Full resource ID of the log analytics workspace to be used for the deployment.')
// param workspaceId string

@description('Full resource ID of the data collection endpoint to be used for the deployment.')
// param dceId string
// @description('Full resource ID of the user managed identity to be used for the deployment')

param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
//param grafanaName string
param instanceName string
//param solutionVersion string
// param customerTags object 
// var tempTags ={
//   '${solutionTag}': packtag
//   MonitoringPackType: 'PaaS'
//   solutionVersion: solutionVersion
// }
// if the customer has provided tags, then use them, otherwise use the default tags
//var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var resourceGroupName = split(resourceGroupId, '/')[4]

var resourceType = 'Microsoft.KeyVault/vaults'

module KVAlert 'alerts.bicep' = {
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
    solutionVersion: solutionVersion
    location: location
    instanceName: instanceName
  }
}

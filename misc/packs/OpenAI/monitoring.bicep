targetScope = 'managementGroup'
param packtag string = 'OpenAI'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string 
// @description('Name of the DCR rule to be created')
// param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
// @description('Full resource ID of the log analytics workspace to be used for the deployment.')
// param workspaceId string
// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
// param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param actionGroupResourceId string

param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
//param grafanaName string
param instanceName string
var resourceType = 'Microsoft.CognitiveServices/accounts'
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]
param customerTags object 
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'PaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)

module Alerts 'Alerts.bicep' = {
  name: '${packtag}-Alerts-${instanceName}-${location}'
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
    instanceName: instanceName
  }
}

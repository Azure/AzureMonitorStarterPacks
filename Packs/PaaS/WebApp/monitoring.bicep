targetScope = 'managementGroup'
param workspaceId string
param packtag string
param solutionTag string
param actionGroupResourceId string
param instanceName string

var resourceTypes = [
  'Microsoft.Web/sites'
]

param location string //= resourceGroup().location
param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
param solutionVersion string
param customerTags object 
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'PaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

module webappsalerts 'alerts.bicep' = {
  name: 'WebApps-Alerts'
  params: {
    packTag: packtag
    policyLocation: location
    solutionTag: solutionTag
    parResourceGroupName: resourceGroupName
    subscriptionId: subscriptionId
    mgname: mgname
    resourceType: resourceTypes[0]
    assignmentLevel: assignmentLevel
    userManagedIdentityResourceId: userManagedIdentityResourceId
    AGId: actionGroupResourceId
    instanceName: instanceName
    solutionVersion: solutionVersion
  }
}

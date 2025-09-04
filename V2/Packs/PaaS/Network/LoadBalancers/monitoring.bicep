targetScope = 'managementGroup'
param packtag string = 'ALB'
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string 
param actionGroupResourceId string
// @description('Name of the DCR rule to be created')
// param rulename string = ''
@description('location for the deployment.')
param location string //= resourceGroup().location
// @description('Full resource ID of the log analytics workspace to be used for the deployment.')
// param workspaceId string

// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
// param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')

param subscriptionId string
param userManagedIdentityResourceId string
param mgname string 
param assignmentLevel string
param resourceGroupId string
//param grafanaName string
param customerTags object 
param instanceName string
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'PaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
//var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var resourceType = 'Microsoft.Network/loadBalancers'
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

// // Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
// module ag '../../../../modules/actiongroups/ag.bicep' = {
//   name: actionGroupName
//   params: {
//     actionGroupName: actionGroupName
//     existingAGRG: existingAGRG
//     emailreceivers: emailreceivers
//     emailreiceversemails: emailreiceversemails
//     useExistingAG: useExistingAG
//     newRGresourceGroup: resourceGroupName
//     solutionTag: solutionTag
//     subscriptionId: subscriptionId
//     location: location
//   }
// }

module LBAlerts 'alerts.bicep' = {
  name: '${packtag}-Alerts'
  params: {
    packTag: packtag
    policyLocation: location
    solutionTag: solutionTag
    //parResourceGroupName: resourceGroupName
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

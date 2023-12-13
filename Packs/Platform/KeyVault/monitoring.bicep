targetScope = 'managementGroup'

param packtag string = 'KeyVault'
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

var resourceType = 'Microsoft.KeyVault/vaults'
//var resourceShortType = split(resourceType, '/')[1]



// Action Group - the action group is either created or can reference an existing action group, depending on the useExistingAG parameter
// module ag '../../../modules/actiongroups/ag.bicep' = {
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

// module diagnosticsPolicy '../../../modules/policies/mg/diagnostics/associacionpolicyDiag.bicep' = {
//   name: 'associacionpolicy-${packtag}-${split(resourceType, '/')[1]}'
//   params: {
//     logAnalyticsWSResourceId: workspaceId
//     packtag: packtag
//     solutionTag: solutionTag
//     policyDescription: 'Policy to associate the diagnostics setting for ${split(resourceType, '/')[1]} resources the tagged with ${packtag} tag.'
//     policyDisplayName: 'Associate the diagnostics with the ${split(resourceType, '/')[1]} resources tagged with ${packtag} tag.'
//     policyName: 'Associate-diagnostics-${packtag}-${split(resourceType, '/')[1]}'
//     resourceType: resourceType
//   }
// }

// module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' =  {
//   name: 'diagassignment-${packtag}-${split(resourceType, '/')[1]}'
//   dependsOn: [
//     diagnosticsPolicy
//   ]
//   params: {
//     location: location
//     mgname: mgname
//     packtag: packtag
//     policydefinitionId: diagnosticsPolicy.outputs.policyId
//     resourceType: resourceType
//     solutionTag: solutionTag
//     subscriptionId: subscriptionId 
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//     assignmentLevel: assignmentLevel
//     policyType: 'diag'
//   }
// }

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
  }
}

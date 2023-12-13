targetScope = 'managementGroup'
param packtag string = 'Storage'
param solutionTag string = 'MonitorStarterPacks'
param actionGroupResourceId string
param solutionVersion string = '0.1.0'
@description('Name of the DCR rule to be created')
param rulename string = ''
@description('Name of the Action Group to be used or created.')
param actionGroupName string
@description('Email receiver names to be used for the Action Group if being created.')
param emailreceivers array = []
@description('Email addresses to be used for the Action Group if being created.')
param emailreiceversemails array  = []
@description('If set to true, a new Action group will be created')
param useExistingAG bool = false
@description('Name of the existing resource group to be used for the Action Group if existing.')
param existingAGRG string = ''
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

var resourceType = 'Microsoft.Storage/storageAccounts'
//var resourceShortType = split(resourceType, '/')[1]

var resourceGroupName = split(resourceGroupId, '/')[4]

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

module alerts 'alerts.bicep' = {
  name: '${packtag}-alerts'
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

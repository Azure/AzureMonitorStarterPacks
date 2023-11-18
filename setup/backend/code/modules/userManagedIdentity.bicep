targetScope = 'managementGroup'
param location string
param solutionTag string
param solutionVersion string
param roleDefinitionIds array
param userIdentityName string
param mgname string
param subscriptionId string
param resourceGroupName string
param addRGRoleAssignments bool = false
var RGroleDefinitionIds=[

  //contributor roles
  'b24988ac-6180-42a0-ab88-20f7382dd24c' // Contributor Role Definition Id for Contributor
  //grafana admin
  '22926164-76b3-42b3-bc55-97df8dab3e41' // Grafana Admin
  //Above role should be able to add diagnostics to everything according to docs.
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
// resource userManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
//   name: userIdentityName
//   location: location
//   tags: {
//     '${solutionTag}': userIdentityName
//     '${solutionTag}-Version': solutionVersion
//   }
// }
module userManagedIdentity './umidentityresource.bicep' = {
  name: userIdentityName
  scope: resourceGroup(subscriptionId,resourceGroupName)
  params: {
    location: location
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    userIdentityName: userIdentityName
  }
}

module userIdentityRoleAssignments '../../../../modules/rbac/mg/roleassignment.bicep' =  [for (roledefinitionId, i) in roleDefinitionIds:  {
  name: '${userIdentityName}-${i}'
  scope: managementGroup(mgname)
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.outputs.userManagedIdentityPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

module userIdentityRoleAssignmentRG '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = [for (roledefinitionId, i) in RGroleDefinitionIds: if (addRGRoleAssignments) {
  name: '${userIdentityName}-${i}-RG'
  scope: resourceGroup(subscriptionId,resourceGroupName)
  params: {
    resourcename: userIdentityName
    principalId: userManagedIdentity.outputs.userManagedIdentityPrincipalId
    solutionTag: solutionTag
    roleDefinitionId: roledefinitionId
    roleShortName: roledefinitionId
  }
}]

output userManagedIdentityPrincipalId string = userManagedIdentity.outputs.userManagedIdentityPrincipalId
output userManagedIdentityClientId string = userManagedIdentity.outputs.userManagedIdentityClientId
output userManagedIdentityResourceId string = userManagedIdentity.outputs.userManagedIdentityResourceId

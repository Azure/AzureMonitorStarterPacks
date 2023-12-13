targetScope='managementGroup'
param packtag string
param solutionTag string
param location string
param userManagedIdentityResourceId string
param assignmentSuffix string=''
param mgname string
param assignmentLevel string = 'managementGroup'
param subscriptionId string
param resourceType string
@allowed(
  [
    'diag'
    'alert'
  ]
)
param policyType string
param policydefinitionId string
var resourceShortType = split(resourceType, '/')[1]

// var roledefinitionIds=[
//   '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
//   '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
//   // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
// ]
//module policyAssignment {}
// param policyAssignmentName string = 'audit-vm-manageddisks'
// param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'

module diagassignment './assignment.bicep' = if(assignmentLevel == 'managementGroup') {
  name: 'AM-${packtag}-${resourceShortType}-${assignmentSuffix}'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: policydefinitionId
    assignmentName: '${packtag}-${resourceShortType}-${assignmentSuffix}'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module diagassignmentsub '../subscription/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
  name: 'AM-${packtag}-${resourceShortType}-${assignmentSuffix}'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: policydefinitionId
    assignmentName: '${packtag}-${resourceShortType}-${policyType}-${assignmentSuffix}'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}

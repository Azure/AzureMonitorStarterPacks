targetScope='managementGroup'
param packtag string
param dcrId string
param solutionTag string
param rulename string
param ruleshortname string
param location string
param userManagedIdentityResourceId string
param mgname string
param assignmentLevel string = 'ManagementGroup'
param subscriptionId string
param instanceName string
param index int=1

var roledefinitionIds=[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
var dcrName = split (dcrId,'/')[8]

module policyARC './associacionpolicyARC.bicep' = {
  name: 'AssocPolArc-${dcrName}'
  scope: managementGroup(mgname)
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${rulename} DCR with the ARC Servers tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${rulename} DCR to ARC Servers. Tag: ${packtag}'
    policyName: 'Associate-${rulename}-${packtag}-arc'
    DCRId: dcrId
    solutionTag: solutionTag
    roledefinitionIds: roledefinitionIds
    instanceName: instanceName
  }
}
//module policyAssignment {}
// param policyAssignmentName string = 'audit-vm-manageddisks'
// param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
module arcassignment './assignment.bicep' = if(assignmentLevel == 'ManagementGroup') {
  dependsOn: [
    policyARC
  ]
  name: 'AM-${packtag}${index}-arc'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: policyARC.outputs.policyId
    location: location
    assignmentName: 'AM-${packtag}${index}-arc'
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module arcassignmentsub '../subscription/assignment.bicep' = if(assignmentLevel != 'ManagementGroup') {
  dependsOn: [
    policyARC
  ]
  name: 'ASub-${packtag}-${ruleshortname}-arc'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: policyARC.outputs.policyId
    location: location
    assignmentName: 'AMg-${ruleshortname}-arc'
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}

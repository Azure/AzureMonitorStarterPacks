targetScope='managementGroup'
param packtag string
param dcrId string
param solutionTag string
param rulename string
param ruleshortname string
param location string
param userManagedIdentityResourceId string
param mgname string
param assignmentLevel string = 'managementGroup'
param subscriptionId string

var roledefinitionIds=[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
var dcrName = split (dcrId,'/')[8]

module policyVM '../modules/associacionpolicyVM.bicep' = {
  name: 'associationpolicyVM-${packtag}-${dcrName}'
  scope: managementGroup(mgname)
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyName: 'Associate-${rulename}-${packtag}-vms'
    DCRId: dcrId
    solutionTag: solutionTag
    roledefinitionIds: roledefinitionIds
  }
}
module vmassignment '../modules/assignment.bicep' = if(assignmentLevel == 'managementGroup') {
  dependsOn: [
    policyVM
  ]
  name: 'Assignment-${packtag}-${ruleshortname}-vm'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: '${packtag}-${ruleshortname}-vm'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module vmassignmentsub '../modules/sub/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
  dependsOn: [
    policyVM
  ]
  name: 'AssignSub-${packtag}-${ruleshortname}-vm'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: '${packtag}-${ruleshortname}-vm'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}

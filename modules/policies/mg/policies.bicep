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
param instanceName string
param arcEnabled bool = true

var roledefinitionIds=[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
var dcrName = split (dcrId,'/')[8]

module policyVM './associacionpolicyVM.bicep' = {
  name: 'AssocPolVM-${dcrName}'
  scope: managementGroup(mgname)
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyName: 'Associate-${rulename}-${packtag}-vms'
    DCRId: dcrId
    solutionTag: solutionTag
    roledefinitionIds: roledefinitionIds
    instanceName: instanceName
  }
}
module vmassignment './assignment.bicep' = if(assignmentLevel == 'managementGroup') {
  dependsOn: [
    policyVM
  ]
  name: 'Assignment-${packtag}-${ruleshortname}-vm'
  scope: managementGroup(mgname)
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: 'AMP-Assign-${ruleshortname}-vm'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module vmassignmentsub '../subscription/assignment.bicep' = if(assignmentLevel != 'managementGroup') {
  dependsOn: [
    policyVM
  ]
  name: 'AssignSub-${packtag}-${ruleshortname}-vm'
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: 'AMP-Assign-${ruleshortname}-vm'
    location: location
    //roledefinitionIds: roledefinitionIds
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
  }
}
module ARCPolicies './policiesARC.bicep' = if (arcEnabled) {
  name: 'AssocPoliciesArc-${dcrName}'
  scope: managementGroup(mgname)
  params: {
    packtag: packtag
    dcrId: dcrId
    solutionTag: solutionTag
    instanceName: instanceName
    location: location
    mgname: mgname
    rulename: rulename
    ruleshortname: ruleshortname
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
  }
}
// module policyARC './associacionpolicyARC.bicep' = if (arcEnabled) {
//   name: 'AssocPolArc-${dcrName}'
//   scope: managementGroup(mgname)
//   params: {
//     packtag: packtag
//     policyDescription: 'Policy to associate the ${rulename} DCR with the ARC Servers tagged with ${packtag} tag.'
//     policyDisplayName: 'Associate the ${rulename} DCR to ARC Servers. Tag: ${packtag}'
//     policyName: 'Associate-${rulename}-${packtag}-arc'
//     DCRId: dcrId
//     solutionTag: solutionTag
//     roledefinitionIds: roledefinitionIds
//     instanceName: instanceName
//   }
// }
// //module policyAssignment {}
// // param policyAssignmentName string = 'audit-vm-manageddisks'
// // param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
// module arcassignment './assignment.bicep' = if(assignmentLevel == 'managementGroup' && arcEnabled == true) {
//   dependsOn: [
//     policyARC
//   ]
//   name: 'Assignment-${packtag}-${ruleshortname}-arc'
//   scope: managementGroup(mgname)
//   params: {
//     policyDefinitionId: policyARC.outputs.policyId
//     location: location
//     assignmentName: 'AMP-Assign-${ruleshortname}-arc'
//     //roledefinitionIds: roledefinitionIds
//     solutionTag: solutionTag
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//   }
// }

// module arcassignmentsub '../subscription/assignment.bicep' = if(assignmentLevel != 'managementGroup' && arcEnabled) {
//   dependsOn: [
//     policyARC
//   ]
//   name: 'AssigSub-${packtag}-${ruleshortname}-arc'
//   scope: subscription(subscriptionId)
//   params: {
//     policyDefinitionId: policyARC.outputs.policyId
//     location: location
//     assignmentName: 'AMP-Assign-${ruleshortname}-arc'
//     //roledefinitionIds: roledefinitionIds
//     solutionTag: solutionTag
//     userManagedIdentityResourceId: userManagedIdentityResourceId
//   }
// }

param packtag string
param dcrId string
param solutionTag string
param rulename string
param location string
var roledefinitionIds=[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
module policyVM './associacionpolicyVM.bicep' = {
  name: 'associationpolicyVM'
  scope: subscription()
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyName: 'associate-${rulename}-${packtag}-vms'
    DCRId: dcrId
    solutionTag: solutionTag
    roledefinitionIds: roledefinitionIds
  }
}
module policyARC './associacionpolicyARC.bicep' = {
  name: 'associationpolicyARC'
  scope: subscription()
  params: {
    packtag: packtag
    policyDescription: 'Policy to associate the ${rulename} DCR with the VMs tagged with ${packtag} tag.'
    policyDisplayName: 'Associate the ${rulename} DCR with the ARC Servers tagged with ${packtag} tag.'
    policyName: 'associate-${rulename}-${packtag}-arc'
    DCRId: dcrId
    solutionTag: solutionTag
    roledefinitionIds: roledefinitionIds
  }
}
//module policyAssignment {}
// param policyAssignmentName string = 'audit-vm-manageddisks'
// param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
module arcassignment './assignment.bicep' = {
  dependsOn: [
    policyARC
  ]
  name: 'arcassignment'
  scope: subscription()
  params: {
    policyDefinitionId: policyARC.outputs.policyId
    location: location
    assignmentName: 'associate-${rulename}-${packtag}-arc'
    roledefinitionIds: roledefinitionIds
  }
}
module vmassignment './assignment.bicep' = {
  name: 'vmassignment'
  dependsOn: [
    policyVM
  ]
  scope: subscription()
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: 'associate-${rulename}-${packtag}-vm'
    location: location
    roledefinitionIds: roledefinitionIds
  }
}

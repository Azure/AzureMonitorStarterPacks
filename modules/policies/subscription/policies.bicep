param packtag string
param dcrId string
param solutionTag string
param rulename string
param location string

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
  }
}
//module policyAssignment {}
// param policyAssignmentName string = 'audit-vm-manageddisks'
// param policyDefinitionID string = '/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d'
module arcassignment './assignment.bicep' = {
  name: 'arcassignment'
  scope: subscription()
  params: {
    policyDefinitionId: policyARC.outputs.policyId
    location: location
    assignmentName: 'associate-${rulename}-${packtag}-arc'
  }
}
module vmassignment './assignment.bicep' = {
  name: 'vmassignment'
  scope: subscription()
  params: {
    policyDefinitionId: policyVM.outputs.policyId
    assignmentName: 'associate-${rulename}-${packtag}-vm'
    location: location
  }
}

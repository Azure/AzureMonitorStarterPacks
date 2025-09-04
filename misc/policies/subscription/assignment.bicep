targetScope = 'subscription'
param policyDefinitionId string
param assignmentName string
param location string
param solutionTag string
param userManagedIdentityResourceId string

var loc2 = trim(location)

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userManagedIdentityResourceId}': {}
    }
  }
  location: loc2
  properties: {
      policyDefinitionId: policyDefinitionId
      displayName: assignmentName
      enforcementMode: 'Default'
      metadata: {
        createdBy: solutionTag
      }
  }
}




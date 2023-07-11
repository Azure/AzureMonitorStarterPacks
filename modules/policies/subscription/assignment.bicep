targetScope = 'subscription'
param policyDefinitionId string
param assignmentName string
param location string
param roledefinitionIds array

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
      policyDefinitionId: policyDefinitionId
      displayName: assignmentName
      enforcementMode: 'Default'
  }
}
resource roleassignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = [for (roledefinitionId, i) in roledefinitionIds:  {
  name: '${assignmentName}-${i}'
  properties: {
    roleDefinitionId: roledefinitionId
    principalId: assignment.identity.principalId
  }
}]


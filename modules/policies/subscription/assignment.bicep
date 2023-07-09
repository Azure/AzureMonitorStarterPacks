targetScope = 'subscription'
param policyDefinitionId string
param assignmentName string
param location string

resource assignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: assignmentName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
      policyDefinitionId: policyDefinitionId
  }
}

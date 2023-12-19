targetScope = 'managementGroup'
param policyDefinitionId string
param assignmentName string
param location string
//param roledefinitionIds array
param solutionTag string
param userManagedIdentityResourceId string
//param utcValue string = utcNow()
//var roleassignmentnamePrefix=guid('${assignmentName}-${subscription().subscriptionId}')
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




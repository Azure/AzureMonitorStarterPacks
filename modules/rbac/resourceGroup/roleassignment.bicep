targetScope ='resourceGroup'
param resourcename string
param solutionTag string
param principalId string
param resourceGroupName string
param roleDefinitionId string
param roleShortName string //For consistent resource naming and redeployment
param utcValue string = utcNow()

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id,principalId,roleDefinitionId)
  scope: resourceGroup()
  properties: {
    description: '${solutionTag}-${roleShortName}-${resourcename}-${utcValue}'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleDefinitionId
  }
}
output roleassignmentname string = roleAssignment.name

targetScope = 'subscription'
param resourcename string
param solutionTag string
param principalId string
param roleDefinitionId string
param resourceGroup string
param roleShortName string //For consistent resource naming and redeployment
param utcValue string = utcNow()

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id,principalId,roleDefinitionId)
  scope: subscription()
  properties: {
    description: '${solutionTag}-${roleShortName}-${resourcename}-${utcValue}'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', roleDefinitionId)
  }
}
output roleassignmentname string = roleAssignment.name

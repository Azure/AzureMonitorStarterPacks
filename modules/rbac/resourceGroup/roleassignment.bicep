targetScope ='resourceGroup'
param resourcename string
param solutionTag string
param principalId string
//param resourceGroupName string
param roleDefinitionId string
param roleShortName string //For consistent resource naming and redeployment
param utcValue string = utcNow()


var roleIdtoUse=subscriptionResourceId('Microsoft.Authorization/roleDefinitions',roleDefinitionId)

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(subscription().id,principalId,roleDefinitionId)
  properties: {
    description: '${solutionTag}-${roleShortName}-${resourcename}-${utcValue}'
    principalId: principalId
    principalType: 'ServicePrincipal'
    roleDefinitionId: roleIdtoUse
  }
}
output roleassignmentname string = roleAssignment.name

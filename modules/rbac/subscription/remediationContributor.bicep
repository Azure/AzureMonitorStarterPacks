targetScope = 'subscription'

@description('Array of actions for the roleDefinition')
param actions array = [
  'Microsoft.PolicyInsights/remediations/write'
  // 'Microsoft.Authorization/policyAssignments/delete'
  // 'Microsoft.Authorization/policyAssignments/write'
]

@description('Array of notActions for the roleDefinition')
param notActions array = []

@description('Friendly name of the role definition')
param roleName string = 'Custom Role - Remediation Contributor'

@description('Detailed description of the role definition')
param roleDescription string = 'Subscription Level Remediation Role'

var roleDefName = guid(subscription().id, string(actions), string(notActions))

resource roleDef 'Microsoft.Authorization/roleDefinitions@2022-05-01-preview' = {
  name: roleDefName
  properties: {
    roleName: roleName
    description: roleDescription
    type: 'customRole'
    permissions: [
      {
        actions: actions
        notActions: notActions
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}
output roleDefId string = split(roleDef.id,'/')[6]



targetScope = 'subscription' 

@maxLength(64)
@description('PolicySet name')
param initiativeName string 

@maxLength(128)
@description('PolicySet display Name')
param initiativeDisplayName string

@description('PolicySet description')
param initiativeDescription string

@minLength(1)
@description('array of policy IDs')
//param initiativePoliciesID array
param solutionTag string
param category string = 'Monitoring' 
param version string = '1.0.0'

resource policySetDef 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {

  name: initiativeName

    properties: {
      description: initiativeDescription
      displayName: initiativeDisplayName 
      metadata: {
        category: category
        version: version
        '${solutionTag}': 'Policy Set'
      }
      parameters: {}
      policyDefinitions:  [
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ca817e41-e85a-4783-bc7f-dc532d36235e'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a4034bc6-ae50-406d-bf76-50f4ee5a7811'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/845857af-0333-4c5d-bbbc-6076697da122'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/94f686d6-9a24-4e19-91f1-de937dc171a4'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4efbd9d8-6bc6-45f6-9be2-7fe9dd5d89ff'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: {}
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/17b3de92-f710-4cf4-aa55-0e7859f1ed7b'
          policyDefinitionReferenceId: ''
        }
        {
          parameters: { 
              bringYourOwnUserAssignedManagedIdentity: {
                value: false
              }
          }
          policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/59c3d93f-900b-4827-a8bd-562e7b956e7c'
          policyDefinitionReferenceId: ''
        }
      ]
      policyType: 'Custom'

    }
}
output policySetDefId string = policySetDef.id

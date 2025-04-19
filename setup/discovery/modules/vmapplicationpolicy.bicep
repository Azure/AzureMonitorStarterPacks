////targetScope = 'managementGroup'
targetScope = 'subscription'
param vmapplicationResourceId string
param policyName string
param policyDisplayName string
param policyDescription string
param packtag string
param solutionTag string
param packtype string
param roledefinitionIds array =[
  '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
  '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
  // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
]
var vmApplicationName = split(vmapplicationResourceId, '/')[10]

resource policy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'AMP-${policyName}'
  properties: {
    description: 'AMP-${policyDescription}'
    displayName: 'AMP-${policyDisplayName}'
    metadata: {
      category: 'Monitoring'
      '${solutionTag}': packtag
      instanceName: instanceName
      MonitoringPackType: packtype
    }
    policyType: 'Custom'
    mode: 'Indexed'
    parameters: {
      tagName: {
        type: 'String'
        metadata: {
          displayName: 'Tag name'
          description: 'A tag to apply the association conditionally.'
        }
        defaultValue: solutionTag
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag value'
          description: 'The value of the tag.'
        }
        defaultValue: packtag
      }
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      vmapplicationId: {
        type: 'String'
        metadata: {
          displayName: 'applicationId'
          description: 'the VM application ID to assign to the VM'
        }
        defaultValue: vmapplicationResourceId
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]' // No need to use an additional forward square bracket in the expressions as in ARM templates
            contains : '[parameters(\'tagValue\')]'
          }
          {
            field: 'type'
            equals: 'Microsoft.Compute/virtualMachines'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Compute/virtualMachines'
          name: '[field(\'name\')]' 
          existenceCondition:{
            allOf: [
              {
                count: {
                  field: 'Microsoft.Compute/virtualMachines/applicationProfile.galleryApplications[*]'
                  where: {
                    field: 'Microsoft.Compute/virtualMachines/applicationProfile.galleryApplications[*].packageReferenceId'
                    equals: '[parameters(\'vmapplicationId\')]'
                  }
                }
                greater: 0
              }
            ]
          }
          roleDefinitionIds: roledefinitionIds
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json'
                contentVersion: '1.0.0.0'
                parameters: {
                  vmName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  vmapplicationId: {
                    type: 'string'
                  }
                }
                variables: {
                  vmApplicationName: vmApplicationName
                }
                resources: [
                  {
                    apiVersion: '2021-07-01'
                    type: 'Microsoft.Compute/virtualMachines/VMapplications'
                    name: '[concat(parameters(\'vmName\'), \'/\',variables(\'vmApplicationName\'))]'
                    location: '[parameters(\'location\')]'
                    properties: {
                      packageReferenceId: '[parameters(\'vmapplicationId\')]'
                    }
                  }
                ]
              }
              parameters: {
                vmName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                vmapplicationId: {
                  value: '[parameters(\'vmapplicationId\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}
output policyId string = policy.id

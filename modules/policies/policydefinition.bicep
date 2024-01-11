targetScope = 'subscription'
param policyName string
param policyDisplayName string
param policyDescription string

resource policy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    description: policyDescription
    displayName: policyDisplayName
    metadata: {
      category: 'Monitoring'
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
      }
      tagValue: {
        type: 'String'
        metadata: {
          displayName: 'Tag value'
          description: 'The value of the tag.'
        }
      }
      DCRName: {
        type: 'String'
        metadata: {
          displayName: 'Name of the Data Collection Rule'
          description: 'The Name of the Data Collection Rule to be associated with the virtual machine.'
        }
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
          type: 'Microsoft.Insights/dataCollectionRuleAssociations'
          name: 'AMP-RulesAssociation' 
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa' 
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
            // '/providers/Microsoft.Authorization/roleDefinitions/4a9ae827-6dc8-4573-8ac7-8239d42aa03f' // Tag Contributor
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceGroup: {
                    type: 'string'
                  }
                  vmName: {
                    type: 'string'
                  }
                  drcId2 : {
                    type: 'string'
                    defaultValue: '[resourceId(\'Microsoft.Insights/dataCollectionRules\', parameters(\'DCRName\'))]'
                  }
                }
                variables: {
                  locationLongNameToShortMap: {
                    canadacentral: 'CCA'
                    canadaeast: 'CCA'
                    centralus: 'CUS'
                    eastus2euap: 'eus2p'
                    eastus: 'EUS'
                    eastus2: 'EUS2'
                    southcentralus: 'SCUS'
                    westcentralus: 'WCUS'
                    westus: 'WUS'
                    westus2: 'WUS2'
                  }
                  DcrId: '[resourceId(\'Microsoft.Insights/dataCollectionRules\', parameters(\'DCRName\'))'
                  subscriptionId: '[subscription().subscriptionId]'
                  //dcrName: '[parameters(\'packdcrName\')]'
                  //dcrId: '[parameters(\'packDCRId\')]'
                  //dcrId: '[parameters(\'DCRId\')'
                  dcraName: '[concat(parameters(\'vmName\'),\'/Microsoft.Insights/\',parameters(\'DCRName\'))]'
                }
                resources: [
                  {
                    type: 'Microsoft.Compute/virtualMachines/providers/dataCollectionRuleAssociations'
                    name: '[variables(\'dcraName\')]'
                    apiVersion: '2021-04-01'
                    properties: {
                      description: 'Association of data collection rule for Azure Monitor Starter Packs for VMs'
                      dataCollectionRuleId: '[variables(\'DcrId\')]'
                    }
                  }
                ]
              }
            }
          }
        }
      }
    }
  }
}

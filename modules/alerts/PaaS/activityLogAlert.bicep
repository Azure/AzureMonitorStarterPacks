targetScope = 'managementGroup'
param assignmentSuffix string //used to differenciate the assignment names, based on some criteria
param alertname string
param alertDisplayName string
param alertDescription string
param policyLocation string
param solutionTag string
param packTag string
param parResourceGroupTags object = {
  environment: 'test'
}
param parResourceGroupName string
param deploymentRoleDefinitionIds array = [
  '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
param subscriptionId string
param mgname string
param assignmentLevel string
param userManagedIdentityResourceId string
param resourceType string
param operationName string
param AGId string
param initiativeMember bool

var parAlertState = 'true'
@allowed([
    'IaaS'
    'PaaS'
])
param packtype string
param instanceName string
module ActivityLogAlert '../../alz/deploy.bicep' = {
  name: guid(alertname,policyLocation,instanceName)
  params: {
      name: 'AMP-${instanceName}-${alertname}'
      displayName: 'AMP-${instanceName}-${alertDisplayName}'
      description: 'AMP-${instanceName}-${alertDescription}'
      location: policyLocation
      metadata: {
          version: '1.0.0'
          Category: 'ActivityLog'
          source: 'https://azure.github.io/azure-monitor-baseline-alerts/services/'
          '${solutionTag}': packTag
          MonitoringPackType: packtype
          initiativeMember: initiativeMember
      }
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
            displayName: 'Tag Value'
            description: 'A tag to apply the association conditionally.'
            }
            defaultValue: packTag
        }
        alertDescription: {
            type: 'String'
            metadata: {
                displayName: 'Description'
                description: 'Description for the alert'
            }
            defaultValue: alertDescription
        }
        alertname: {
            type: 'String'
            metadata: {
                displayName: 'Name'
                description: 'Name for the alert'
            }
            defaultValue: alertname
        }
        enabled: {
            type: 'String'
            metadata: {
                displayName: 'Alert State'
                description: 'Alert state for the alert'
            }
            allowedValues: [
                'true'
                'false'
            ]
            defaultValue: parAlertState
        }
        alertResourceGroupName: {
            type: 'String'
            metadata: {
                displayName: 'Resource Group Name'
                description: 'Resource group the alert is placed in'
            }
            defaultValue: parResourceGroupName
        }
        alertResourceGroupTags: {
            type: 'Object'
            metadata: {
                displayName: 'Resource Group Tags'
                description: 'Tags on the Resource group the alert is placed in'
            }
            defaultValue: parResourceGroupTags
        }
        actionGroupResourceId: {
            type: 'String'
            metadata: {
                displayName: 'Action Group Resource Id'
                description: 'Resource Id of the action group to be used for the alert'
            }
            defaultValue: AGId
        }
        resourceType: {
            type: 'String'
            metadata: {
                displayName: 'Resource Type'
                description: 'Resource Type for the alert'
            }
            defaultValue: resourceType
        }
        operationName: {
            type: 'String'
            metadata: {
                displayName: 'Operation Name'
                description: 'Operation Name for the alert'
            }
            defaultValue: operationName
        }
      }
      policyRule: {
          if: {
              allOf: [
                  {
                      field: 'type'
                      equals: resourceType
                  }
                  {
                      field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
                      contains : '[parameters(\'tagValue\')]'
                  }
              ]
          }
          then: {
              effect: 'deployIfNotExists'
              details: {
                  roleDefinitionIds: deploymentRoleDefinitionIds
                  type: 'Microsoft.Insights/activityLogAlerts'
                  name: alertname
                  existenceScope: 'resourcegroup'
                  resourceGroupName: '[parameters(\'alertResourceGroupName\')]'
                  deploymentScope: 'subscription'
                  existenceCondition: {
                      allOf: [
                          {
                              field: 'Microsoft.Insights/ActivityLogAlerts/enabled'
                              equals: '[parameters(\'enabled\')]'
                          }
                          {
                              count: {
                                  field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*]'
                                  where: {
                                      anyOf: [
                                          {
                                              allOf: [
                                                  {
                                                      field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].field'
                                                      equals: 'category'
                                                  }
                                                  {
                                                      field: 'Microsoft.Insights/ActivityLogAlerts/condition.allOf[*].equals'
                                                      equals: 'Administrative'
                                                  }
                                              ]
                                          }
                                          {
                                              allOf: [
                                                  {
                                                      field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].field'
                                                      equals: 'operationName'
                                                  }
                                                  {
                                                      field: 'microsoft.insights/activityLogAlerts/condition.allOf[*].equals'
                                                      equals: '${resourceType}/${operationName}'
                                                  }
                                              ]
                                          }
                                      ]
                                  }
                              }
                              equals: 2
                          }
                      ]
                  }
                  deployment: {
                      location: policyLocation
                      properties: {
                          mode: 'incremental'
                          template: {
                              '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                              contentVersion: '1.0.0.0'
                              parameters: {
                                alertResourceGroupName: {
                                    type: 'string'
                                }
                                resourceName: {
                                    type: 'String'
                                    metadata: {
                                        displayName: 'resourceName'
                                        description: 'Name of the resource'
                                    }
                                }
                                resourceId: {
                                    type: 'String'
                                    metadata: {
                                        displayName: 'resourceId'
                                        description: 'Resource ID of the resource emitting the metric that will be used for the comparison'
                                    }
                                }
                                alertResourceGroupTags: {
                                    type: 'object'
                                }
                                policyLocation: {
                                    type: 'string'
                                    defaultValue: policyLocation
                                }
                                enabled: {
                                    type: 'string'
                                }
                                alertDescription: {
                                    type: 'string'
                                }
                                alertname: {
                                    type: 'string'
                                }
                                solutionTag: {
                                    type: 'string'
                                }
                                packTag: {
                                    type: 'string'
                                }
                                actionGroupResourceId: {
                                    type: 'string'
                                }
                                resourceType: {
                                    type: 'string'
                                }
                                operationName: {
                                    type: 'string'
                                }
                              }
                              variables: {}
                              resources: [
                                  {
                                      type: 'Microsoft.Resources/deployments'
                                      apiVersion: '2019-10-01'
                                      name: '[concat(parameters(\'alertname\'),\'-\',parameters(\'resourceName\'))]'
                                      resourceGroup: '[parameters(\'alertResourceGroupName\')]'
                                      properties: {
                                          mode: 'Incremental'
                                          template: {
                                              '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                              contentVersion: '1.0.0.0'
                                              parameters: {
                                                enabled: {
                                                    type: 'string'
                                                }
                                                alertResourceGroupName: {
                                                    type: 'string'
                                                }
                                                alertDescription: {
                                                    type: 'string'
                                                }
                                                alertname: {
                                                    type: 'string'
                                                }
                                                solutionTag: {
                                                    type: 'string'
                                                }
                                                packTag: {
                                                    type: 'string'
                                                }
                                                actionGroupResourceId: {
                                                    type: 'string'
                                                }
                                                resourceType: {
                                                    type: 'string'
                                                }
                                                operationName: {
                                                    type: 'string'
                                                }
                                              }
                                              variables: {}
                                              resources: [
                                                  {
                                                      type: 'microsoft.insights/activityLogAlerts'
                                                      apiVersion: '2020-10-01'
                                                      name: '[concat(parameters(\'alertname\'),\'-\',parameters(\'resourceName\'))]'
                                                      location: 'global'
                                                      tags: {
                                                         '[parameters(\'solutionTag\')]': '[parameters(\'packTag\')]'
                                                      }
                                                      properties: {
                                                          description: '[parameters(\'alertDescription\')]'
                                                          enabled: '[parameters(\'enabled\')]'
                                                          scopes: [
                                                              '[parameters(\'resourceId\')]'
                                                          ]
                                                          condition: {
                                                              allOf: [
                                                                  {
                                                                      field: 'category'
                                                                      equals: 'Administrative'
                                                                  }
                                                                  {
                                                                      field: 'operationName'
                                                                      equals: '[concat(parameters(\'resourceType\'),\'/\',parameters(\'operationName\'))]'
                                                                  }
                                                                  {
                                                                      field: 'status'
                                                                      containsAny: [
                                                                          'succeeded'
                                                                      ]
                                                                  }
                                                              ]
                                                          }
                                                          actions: {
                                                            actionGroups: [
                                                                {
                                                                    actionGroupId: '[parameters(\'actionGroupResourceId\')]'
                                                                }
                                                            ]
                                                            customProperties: {
                                                            }
                                                          }
                                                          parameters: {
                                                              enabled: {
                                                                  value: '[parameters(\'enabled\')]'
                                                              }
                                                          }
                                                      }
                                                  }
                                              ]
                                          }
                                          parameters: {
                                            enabled: {
                                                value: '[parameters(\'enabled\')]'
                                            }
                                            alertResourceGroupName: {
                                                value: '[parameters(\'alertResourceGroupName\')]'
                                            }
                                            alertDescription: {
                                                value: '[parameters(\'alertDescription\')]'
                                            }
                                            alertname: {
                                                value: '[parameters(\'alertname\')]'
                                            }
                                            solutionTag: {
                                                value: '[parameters(\'solutionTag\')]'
                                            }
                                            packTag: {
                                                value: '[parameters(\'packTag\')]'
                                            }
                                            actionGroupResourceId: {
                                                value: '[parameters(\'actionGroupResourceId\')]'
                                            }
                                            resourceType: {
                                                value: '[parameters(\'resourceType\')]'
                                            }
                                            operationName: {
                                                value: '[parameters(\'operationName\')]'
                                            }
                                          }
                                      }
                                  }
                              ]
                          }
                          parameters: {
                            enabled: {
                                value: '[parameters(\'enabled\')]'
                            }
                            resourceName: {
                                value: '[field(\'name\')]'
                            }
                            alertResourceGroupName: {
                                value: '[parameters(\'alertResourceGroupName\')]'
                            }
                            alertResourceGroupTags: {
                                value: '[parameters(\'alertResourceGroupTags\')]'
                            }
                            alertDescription: {
                                value: '[parameters(\'alertDescription\')]'
                            }
                            alertname: {
                                value: '[parameters(\'alertname\')]'
                            }
                            solutionTag: {
                            value: '[parameters(\'tagName\')]'
                            }
                            packTag: {
                                value: '[parameters(\'tagValue\')]'
                            }
                            actionGroupResourceId: {
                                value: '[parameters(\'actionGroupResourceId\')]'
                            }
                            resourceId: {
                                value: '[field(\'id\')]'
                            }
                            operationName: {
                                value: '[parameters(\'operationName\')]'
                            }
                            resourceType: {
                                value: '[parameters(\'resourceType\')]'
                            }
                          }
                      }
                  }
              }
          }
      }
  }
}

module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' = if (!initiativeMember)  {
  name: guid('${alertname}-${assignmentSuffix}')
  dependsOn: [
    ActivityLogAlert
  ]
  params: {
    location: policyLocation
    mgname: mgname
    packtag: packTag
    policydefinitionId: ActivityLogAlert.outputs.resourceId
    resourceType: resourceType
    solutionTag: solutionTag
    subscriptionId: subscriptionId 
    userManagedIdentityResourceId: userManagedIdentityResourceId
    assignmentLevel: assignmentLevel
    policyType: 'alert'
    assignmentSuffix: assignmentSuffix
    instanceName: instanceName
  }
}

output policyResourceId string = ActivityLogAlert.outputs.resourceId
output policyId string = ActivityLogAlert.outputs.policyId

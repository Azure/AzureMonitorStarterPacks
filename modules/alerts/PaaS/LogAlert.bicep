// Copyright (c) Microsoft Corporation.
// Licensed under the MIT license.

targetScope = 'managementGroup'
param assignmentSuffix string //used to differenciate the assignment names, based on some criteria
param alertname string
param alertDisplayName string
param alertDescription string
param solutionTag string
param packTag string
// param parResourceGroupTags object = {
//   environment: 'test'
// }
// param parResourceGroupName string
param subscriptionId string
param mgname string
param assignmentLevel string
param userManagedIdentityResourceId string
param resourceType string
param timeAggregation string='Average'
//param metricNamespace string
param AGId string
param workspaceId string
//param metricName string
param logQuery string
// param operator string
param initiativeMember bool //will mostly true
param instanceName string

param policyLocation string
param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
@allowed([
    'IaaS'
    'PaaS'
])
param packtype string

@allowed([
    '0'
    '1'
    '2'
    '3'
    '4'
])
param parAlertSeverity string = '3'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
    'PT6H'
    'PT12H'
    'P1D'
])
param parWindowSize string = 'PT5M'

@allowed([
    'PT1M'
    'PT5M'
    'PT15M'
    'PT30M'
    'PT1H'
])
param parEvaluationFrequency string = 'PT5M'

@allowed([
    'deployIfNotExists'
    'disabled'
])
param parPolicyEffect string = 'disabled'

param parAutoMitigate string = 'true'

param parAlertState string = 'true'

param parThreshold string = '1000'

param parMonitorDisable string = 'MonitorDisable' 

module alert '../../alz/deploy.bicep' = {
    name: guid(alertname,policyLocation,instanceName)
    params: {
        name: 'AMP-${instanceName}-${alertname}'
        displayName: 'AMP-${instanceName}-${alertDisplayName}'
        description: 'AMP-${instanceName}-${alertDescription}'
        location: policyLocation
        metadata: {
            version: '1.0.0'
            Category: 'Monitoring'
            source: 'https://github.com/Azure/AzureMonitorStarterPacks'
            '${solutionTag}': packTag
            MonitoringPackType: packtype
            initiativeMember: initiativeMember
        }
        parameters: {
            severity: {
                type: 'String'
                metadata: {
                    displayName: 'Severity'
                    description: 'Severity of the Alert'
                }
                allowedValues: [
                    '0'
                    '1'
                    '2'
                    '3'
                    '4'
                ]
                defaultValue: parAlertSeverity
            }
            windowSize: {
                type: 'String'
                metadata: {
                    displayName: 'Window Size'
                    description: 'Window size for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                    'PT6H'
                    'PT12H'
                    'P1D'
                ]
                defaultValue: parWindowSize
            }
            evaluationFrequency: {
                type: 'String'
                metadata: {
                    displayName: 'Evaluation Frequency'
                    description: 'Evaluation frequency for the alert'
                }
                allowedValues: [
                    'PT1M'
                    'PT5M'
                    'PT15M'
                    'PT30M'
                    'PT1H'
                ]
                defaultValue: parEvaluationFrequency
            }
            autoMitigate: {
                type: 'String'
                metadata: {
                    displayName: 'Auto Mitigate'
                    description: 'Auto Mitigate for the alert'
                }
                allowedValues: [
                    'true'
                    'false'
                ]
                defaultValue: parAutoMitigate
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
            threshold: {
                type: 'String'
                metadata: {
                    displayName: 'Threshold'
                    description: 'Threshold for the alert'
                }
                defaultValue: parThreshold
            }
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
            logQuery: {
                type: 'String'
                metadata: {
                    displayName: 'Log Analytics Query'
                    description: 'Log Analytics Query'
                }
                defaultValue: logQuery
            }
            workspaceId: {
                type: 'String'
                metadata: {
                    displayName: 'LA Workspace Id'
                    description: 'LA Workspace Id'
                }
                defaultValue: workspaceId
            }
            // operator: {
            //     type: 'String'
            //     metadata: {
            //         displayName: 'Operator'
            //         description: 'Operator for the alert'
            //     }
            //     allowedValues: [
            //         'GreaterThan'
            //         'LessThan'
            //         'GreaterOrLessThan'
            //     ]
            //     defaultValue: operator
            // }
            alertname: {
                type: 'String'
                metadata: {
                    displayName: 'Operator'
                    description: 'Operator for the alert'
                }
                defaultValue: alertname
            }
            effect: {
                type: 'String'
                metadata: {
                    displayName: 'Effect'
                    description: 'Effect of the policy'
                }
                allowedValues: [
                    'deployIfNotExists'
                    'disabled'
                ]
                defaultValue: parPolicyEffect
            }
            alertDescription: {
                type: 'String'
                metadata: {
                    displayName: 'Description'
                    description: 'Description for the alert'
                }
                defaultValue: alertDescription
            }
            actionGroupResourceId: {
                type: 'String'
                metadata: {
                    displayName: 'Action Group Resource Id'
                    description: 'Action Group Resource Id for the alert'
                }
                defaultValue: AGId
            }
            // MonitorDisable: {
            //     type: 'String'
            //     metadata: {
            //         displayName: 'Effect'
            //         description: 'Tag name to disable monitoring resource. Set to true if monitoring should be disabled'
            //     }
          
            //     defaultValue: parMonitorDisable
            // }
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
                effect: '[parameters(\'effect\')]'
                details: {
                    roleDefinitionIds: deploymentRoleDefinitionIds
                    type: 'Microsoft.Insights/scheduledQueryRules'
                    existenceCondition: {
                        allOf: [
                            {
                                field: 'Microsoft.Insights/scheduledQueryRules/description'
                                contains: '[field(\'name\')]'
                            }
                            {
                                field: 'Microsoft.Insights/scheduledQueryRules/enabled'
                                equals: '[parameters(\'enabled\')]'
                            }
                        ]
                    }
                    deployment: {
                        properties: {
                            mode: 'incremental'
                            template: {
                                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#'
                                contentVersion: '1.0.0.0'
                                parameters: {
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
                                    metricNamespace : {
                                      type: 'String'
                                      metadata: {
                                          displayName: 'metricNamespace'
                                          description: 'Metric namespace of the metric that will be used for the comparison'
                                      }
                                    }
                                    metricName : {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'metricName'
                                            description: 'Metric Name that will be used for the comparison'
                                        }
                                    }
                                    operator : {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'operator'
                                            description: 'alert operator for metric threshold compatirson, like GreaterThan, LessThan, GreaterOrLessThan'
                                        }
                                    }
                                    alertname : {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'alertname'
                                            description: 'Name of the alert'
                                        }
                                    }
                                    alertDescription: {
                                        type: 'String'
                                        metadata: {
                                            displayName: 'description'
                                            description: 'Description of the alert'
                                        }
                                    }
                                    severity: {
                                        type: 'String'
                                    }
                                    windowSize: {
                                        type: 'String'
                                    }
                                    evaluationFrequency: {
                                        type: 'String'
                                    }
                                    autoMitigate: {
                                        type: 'String'
                                    }
                                    enabled: {
                                        type: 'String'
                                    }
                                    threshold: {
                                        type: 'String'
                                    }
                                    solutionTag: {
                                        type: 'string'
                                    }
                                    packTag: {
                                        type: 'string'
                                    }
                                    actionGroupResourceId :{
                                        type: 'string'
                                    }
                                }
                                variables: {}
                                resources: [
                                    {
                                        type: 'Microsoft.Insights/metricAlerts'
                                        apiVersion: '2018-03-01'
                                        name: '[parameters(\'alertname\')]'
                                        location: 'global'
                                        tags: {
                                            '[parameters(\'solutionTag\')]': '[parameters(\'packTag\')]'
                                        }
                                        properties: {
                                            description: '[parameters(\'alertDescription\')]'
                                            severity: '[parameters(\'severity\')]'
                                            enabled: '[parameters(\'enabled\')]'
                                            scopes: [
                                                '[parameters(\'resourceId\')]'
                                            ]
                                            evaluationFrequency: '[parameters(\'evaluationFrequency\')]'
                                            windowSize: '[parameters(\'windowSize\')]'
                                            criteria: {
                                                allOf: [
                                                    {
                                                        name: '[parameters(\'metricName\')]'
                                                        metricNamespace: '[parameters(\'metricNamespace\')]'
                                                        metricName: '[parameters(\'metricName\')]'
                                                        operator: '[parameters(\'operator\')]'
                                                        threshold: '[parameters(\'threshold\')]'
                                                        timeAggregation: timeAggregation
                                                        criterionType: 'StaticThresholdCriterion'
                                                    }
                                                ]
                                                'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
                                            }
                                            autoMitigate: '[parameters(\'autoMitigate\')]'
                                            actions: [
                                                {
                                                    actionGroupId: '[parameters(\'actionGroupResourceId\')]'
                                                }
                                            ]
                                            parameters: {
                                                severity: {
                                                    type: 'string'
                                                }
                                                windowSize: {
                                                    type: 'string'
                                                }
                                                evaluationFrequency: {
                                                    type: 'string'
                                                }
                                                autoMitigate: {
                                                    type: 'string'
                                                }
                                                enabled: {
                                                    type: 'string'
                                                }
                                                threshold: {
                                                    type: 'string'
                                                }
                                                metricNamespace: {
                                                    type: 'string'
                                                }
                                                metricName: {
                                                    type: 'string'
                                                }
                                                operator: {
                                                    type: 'string'
                                                }
                                                alertname: {
                                                    type: 'string'
                                                }
                                                alertDescription: {
                                                    type: 'string'
                                                }
                                                solutionTag: {
                                                    type: 'string'
                                                }
                                                packTag: {
                                                    type: 'string'
                                                }
                                            }
                                        }
                                    }
                                ]
                            }
                            parameters: {
                                resourceName: {
                                    value: '[field(\'name\')]'
                                }
                                resourceId: {
                                    value: '[field(\'id\')]'
                                }
                                severity: {
                                    value: '[parameters(\'severity\')]'
                                }
                                windowSize: {
                                    value: '[parameters(\'windowSize\')]'
                                }
                                evaluationFrequency: {
                                    value: '[parameters(\'evaluationFrequency\')]'
                                }
                                autoMitigate: {
                                    value: '[parameters(\'autoMitigate\')]'
                                }
                                enabled: {
                                    value: '[parameters(\'enabled\')]'
                                }
                                threshold: {
                                    value: '[parameters(\'threshold\')]'
                                }
                                metricNamespace: {
                                    value: '[parameters(\'metricNamespace\')]'
                                }
                                metricName: {
                                    value: '[parameters(\'metricName\')]'
                                }
                                operator: {
                                    value: '[parameters(\'operator\')]'
                                }
                                alertname: {
                                    value: '[parameters(\'alertname\')]'
                                }
                                alertDescription: {
                                    value: '[parameters(\'alertDescription\')]'
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
                            }
                        }
                    }
                }
            }
        }
    }
}

module policyassignment '../../../modules/policies/mg/policiesDiag.bicep' = if(!initiativeMember) {
  name: guid('${alertname}-${assignmentSuffix}')
  dependsOn: [
    alert
  ]
  params: {
    location: policyLocation
    mgname: mgname
    packtag: packTag
    policydefinitionId: alert.outputs.resourceId
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

output policyResourceId string = alert.outputs.resourceId
output policyId string = alert.outputs.policyId

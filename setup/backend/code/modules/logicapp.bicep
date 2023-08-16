param functioname string
param solutionTag string
param solutionVersion string
param location string


resource azfunctionsite 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functioname
}
resource logicapp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'MonitorStarterPacks-Backend'
  tags: {
    '${solutionTag}': 'logicapp'
    '${solutionTag}-Version': solutionVersion
  }

  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    definition: {
        '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
        contentVersion: '1.0.0.0'
        parameters: {}
        triggers: {
            manual: {
              type: 'Request'
              kind: 'Http'
              inputs: {}
            }
        }
        actions: {
          Parse_JSON: {
            runAfter: {}
            type: 'ParseJson'
            inputs: {
              content: '@triggerBody()'
              schema: {
                properties: {
                  function: {
                    type: 'string'
                  }
                  functionBody: {
                    properties: {}
                    type: 'object'
                  }
                }
                type: 'object'
              }
            }
          }
          Switch: {
            runAfter: {
              Parse_JSON: [
                'Succeeded'
              ]
            }
            cases: {
              Case: {
                case: 'tagmgmt'
                actions: {
                  tagmgmt: {
                    runAfter: {}
                    type: 'Function'
                    inputs: {
                        body: '@body(\'Parse_JSON\')?[\'functionBody\']'
                        Headers : {
                            //'x-functions-key': listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).masterKey
                            'x-functions-key': listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
                        }
                        function: {
                            id: '${azfunctionsite.id}/functions/tagmgmt'
                        }
                    }
                }
                }
              }
              Case_2: {
                case: 'alertmgmt'
                actions: {
                  alertConfigMgmt: {
                    runAfter: {}
                    type: 'Function'
                    inputs: {
                      body: '@body(\'Parse_JSON\')?[\'functionBody\']'
                      function: {
                        id: '${azfunctionsite.id}/functions/alertConfigMgmt'
                      }
                      headers: {
                        'x-functions-key': listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
                      }
                    }
                  }
                }
              }
              Case_3: {
                case: 'policymgmt'
                actions: {
                  policymgmt: {
                    runAfter: {}
                    type: 'Function'
                    inputs: {
                      body: '@body(\'Parse_JSON\')?[\'functionBody\']'
                      function: {
                        id: '${azfunctionsite.id}/functions/policymgmt'
                      }
                      headers: {
                        'x-functions-key': listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).functionKeys.monitoringKey
                      }
                    }
                  }
                }
              }           
            }
            default: {
              actions: {}
            }
            expression: '@body(\'Parse_JSON\')?[\'Function\']'
            type: 'Switch'
          }
        }
        outputs: {}
    }
    parameters: {}
  }
}


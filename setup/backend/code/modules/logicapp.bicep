param functioname string
param solutionTag string
param solutionVersion string
param location string
param keyvaultid string
param subscriptionId string

var keyVaultName = split(keyvaultid, '/')[8]

resource azfunctionsite 'Microsoft.Web/sites@2022-09-01' existing = {
  name: functioname
}
resource logicapp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'MonitorStarterPacks-Backend'
  // dependsOn: [
  //   logicappConnection
  // ]
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
        parameters: {
          '$connections': {
            defaultValue: {}
            type: 'Object'
          }
        }
        triggers: {
            manual: {
              type: 'Request'
              kind: 'Http'
              inputs: {}
            }
        }
        actions: {
          Get_Secret: {
            runAfter: {
              Parse_JSON: [
                'Succeeded'
              ]
            }
            type: 'ApiConnection'
            inputs: {
              host: {
                connection: {
                  name: '@parameters(\'$connections\')[\'keyvault\'][\'connectionId\']'
                }
              }
              method: 'get'
              path: '/secrets/@{encodeURIComponent(\'FunctionKey\')}/value'
            }
          }
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
              Get_Secret: [
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
                        headers: {
                          'x-functions-key': '@body(\'Get_secret\')?[\'value\']'
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
                        'x-functions-key': '@body(\'Get_secret\')?[\'value\']'
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
                        'x-functions-key': '@body(\'Get_secret\')?[\'value\']'
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
    parameters: {
      '$connections': {
        value: {
          keyvault: {
            connectionId: logicappConnection.id
            connectionName: 'keyvault'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
            id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/eastus/managedApis/keyvault'
          }
        }
      }
    }
  }
}

resource logicappConnection 'Microsoft.Web/connections@2018-07-01-preview' = {
  name: 'keyvault'
  properties: {
  displayName: 'KeyVault'
  authenticatedUser: {}
  overallStatus: 'Ready'
  statuses: [
    {
      status: 'Ready'
    }
  ]
    connectionState: 'Enabled'
    parameterValueSet: {
      name: 'oauthMI'
      values: {
        vaultName: {
          value: keyVaultName
        }
      }
    }
    customParameterValues: {}
    createdTime: '2023-10-12T20:52:26.0864876Z'
    changedTime: '2023-10-12T20:52:26.0864876Z'
    api: {
      name: 'keyvault'
      displayName: 'Azure Key Vault'
      description: 'Azure Key Vault is a service to securely store and access secrets.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1656/1.0.1656.3432/keyvault/icon.png'
      brandColor: '#0079d6'
      category: 'Standard'
      id: '/subscriptions/${subscriptionId}/providers/Microsoft.Web/locations/${location}/managedApis/keyvault'
      //id: resourceId('Microsoft.Web/locations/managedApis', 'keyvault')
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: []
    testRequests: []
  }
  location: location
}


output logicAppPrincipalId string = logicapp.identity.principalId

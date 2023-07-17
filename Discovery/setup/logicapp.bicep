param workflows_Discovery_name string = 'Discovery'
param sites_MonitorStarterPacks_6c64f9ed_externalid string = '/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/amonstarterpacks3/providers/Microsoft.Web/sites/MonitorStarterPacks-6c64f9ed'

resource workflows_Discovery_name_resource 'Microsoft.Logic/workflows@2017-07-01' = {
  name: workflows_Discovery_name
  location: 'eastus'
  tags: {
    MonitorStarterPacks: 'logicapp'
  }
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
                tagmgmt_3: {
                  runAfter: {}
                  type: 'Function'
                  inputs: {
                    body: '@body(\'Parse_JSON\')?[\'functionBody\']'
                    function: {
                      id: '${sites_MonitorStarterPacks_6c64f9ed_externalid}/functions/tagmgmt'
                    }
                    headers: {
                      'x-functions-key': 'NDZhYTI2N2EtOTM0Ny00Yjc5LWI0OTItMDUwMzE2NjJiMmZm'
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
                      id: '${sites_MonitorStarterPacks_6c64f9ed_externalid}/functions/alertConfigMgmt'
                    }
                    headers: {
                      'x-functions-key': 'NDZhYTI2N2EtOTM0Ny00Yjc5LWI0OTItMDUwMzE2NjJiMmZm'
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
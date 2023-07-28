param solutionTag string
param solutionVersion string
param location string
param lawresourceid string

//var wbConfig = loadTextContent('../amsp.workbook')
var wbConfig='''
{
  "version": "Notebook/1.0",
  "items": [
    {
      "type": 1,
      "content": {
        "json": "# Azure Monitor Starter Packs - Admin Centre\n[Azure MONitor STARter Packs](http://github.com/Azure/AzureMonitorStarterPacks)\n"
      },
      "customWidth": "50",
      "name": "text - 5"
    },
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "crossComponentResources": [
          "{Subscriptions}"
        ],
        "parameters": [
          {
            "id": "7a778b2c-619d-4f82-bd1c-810f853af6fd",
            "version": "KqlParameterItem/1.0",
            "name": "Subscriptions",
            "type": 6,
            "isRequired": true,
            "isGlobal": true,
            "multiSelect": true,
            "quote": "'",
            "delimiter": ",",
            "typeSettings": {
              "additionalResourceOptions": [
                "value::all"
              ],
              "includeAll": false,
              "showDefault": false
            },
            "timeContext": {
              "durationMs": 86400000
            },
            "value": [
              "value::all"
            ]
          },
          {
            "id": "1efb8bbe-532a-491b-b3c4-55f1402ee280",
            "version": "KqlParameterItem/1.0",
            "name": "logicAppResource",
            "label": "Logic App",
            "type": 5,
            "isRequired": true,
            "query": "resources\n| where type == \"microsoft.logic/workflows\"\n| project Id=id, Name=name",
            "crossComponentResources": [
              "{Subscriptions}"
            ],
            "typeSettings": {
              "resourceTypeFilter": {
                "microsoft.logic/workflows": true
              },
              "additionalResourceOptions": [],
              "showDefault": false
            },
            "timeContext": {
              "durationMs": 86400000
            },
            "queryType": 1,
            "resourceType": "microsoft.resourcegraph/resources",
            "value": "/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/amonstarterpacks3/providers/Microsoft.Logic/workflows/Backend"
          },
          {
            "id": "4552c35d-c26c-4cbf-a4cf-b2e57ff7ee78",
            "version": "KqlParameterItem/1.0",
            "name": "Workspace",
            "label": "WorkSpace",
            "type": 5,
            "isRequired": true,
            "isGlobal": true,
            "query": "resources\n| where type == \"microsoft.operationalinsights/workspaces\"\n| project id",
            "crossComponentResources": [
              "value::all"
            ],
            "typeSettings": {
              "additionalResourceOptions": [],
              "showDefault": false
            },
            "queryType": 1,
            "resourceType": "microsoft.resourcegraph/resources",
            "value": "/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/amonstarterpacks3/providers/Microsoft.OperationalInsights/workspaces/ws-amonstar"
          },
          {
            "id": "36bac02a-250b-45a0-a451-46561033b7ed",
            "version": "KqlParameterItem/1.0",
            "name": "showHidden",
            "label": "Show Hidden Items",
            "type": 2,
            "isRequired": true,
            "isGlobal": true,
            "typeSettings": {
              "additionalResourceOptions": []
            },
            "jsonData": "[\n    { \"value\":\"yes\", \"label\":\"Yes\" },\n    { \"value\":\"no\", \"label\":\"No\" }\n]",
            "value": "no"
          }
        ],
        "style": "above",
        "queryType": 1,
        "resourceType": "microsoft.resourcegraph/resources"
      },
      "customWidth": "50",
      "name": "parameters - 6"
    },
    {
      "type": 11,
      "content": {
        "version": "LinkItem/1.0",
        "style": "tabs",
        "links": [
          {
            "id": "15f0fa97-4286-48d6-9dea-26a956197d26",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Setup",
            "subTarget": "discovery",
            "style": "link"
          },
          {
            "id": "7499a88f-a536-41d7-9b58-9ebae1b5290e",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Alert Info",
            "subTarget": "alertmanagement",
            "style": "link"
          },
          {
            "id": "3a19e3a9-d64d-41d8-a313-3a60db36bcc4",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Policy Status",
            "subTarget": "policystatus",
            "style": "link"
          },
          {
            "id": "c2a67d72-dd46-44ea-adba-b9d70915c607",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Pack Management",
            "subTarget": "rulemanagement",
            "style": "link"
          },
          {
            "id": "d8f7936d-170f-430d-af7d-ac22115a9e38",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Agent Info",
            "subTarget": "agentmgmt",
            "style": "link"
          },
          {
            "id": "f46dfd96-b9b5-49f4-a67d-59f5f37a9c37",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "ALZ Baseline Info",
            "subTarget": "alzinfo",
            "style": "link"
          },
          {
            "id": "e1f636a4-1593-49ef-bf35-abf708e2be48",
            "cellValue": "tabSelection",
            "linkTarget": "parameter",
            "linkLabel": "Backend Status",
            "subTarget": "backend",
            "style": "link"
          }
        ]
      },
      "name": "links - 8"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "resources | where type =~ 'microsoft.compute/virtualmachines' or type =~ 'microsoft.hybridcompute/machines' \n| where isnotempty(tolower(tags.MonitorStarterPacks))\n| project Server=id,['Resource Group']=resourceGroup, Packs=tags.MonitorStarterPacks",
              "size": 0,
              "title": "Monitored Machines",
              "exportMultipleValues": true,
              "exportedParameters": [
                {
                  "fieldName": "",
                  "parameterName": "taggedVMs",
                  "parameterType": 5,
                  "quote": ""
                }
              ],
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "visualization": "table",
              "gridSettings": {
                "filter": true,
                "sortBy": [
                  {
                    "itemKey": "$gen_link_Packs_2",
                    "sortOrder": 1
                  }
                ]
              },
              "sortBy": [
                {
                  "itemKey": "$gen_link_Packs_2",
                  "sortOrder": 1
                }
              ]
            },
            "name": "Monitored Machines",
            "styleSettings": {
              "margin": "400",
              "padding": "400",
              "showBorder": true
            }
          },
          {
            "type": 9,
            "content": {
              "version": "KqlParameterItem/1.0",
              "crossComponentResources": [
                "{Workspace}"
              ],
              "parameters": [
                {
                  "id": "54f2c7fb-7251-43b6-aa4d-fd94647cac4a",
                  "version": "KqlParameterItem/1.0",
                  "name": "PackTagsLeft",
                  "label": "Add/Remove",
                  "type": 2,
                  "isGlobal": true,
                  "query": "resources\n| where type == \"microsoft.insights/datacollectionrules\"\n| where isnotempty(tags.MonitorStarterPacks)\n| project MPs=tostring(tags.MonitorStarterPacks)\n| summarize by MPs\n",
                  "crossComponentResources": [
                    "{Workspace}"
                  ],
                  "typeSettings": {
                    "additionalResourceOptions": [],
                    "showDefault": false
                  },
                  "timeContext": {
                    "durationMs": 86400000
                  },
                  "queryType": 1,
                  "resourceType": "microsoft.resourcegraph/resources",
                  "value": "Nginx"
                }
              ],
              "style": "pills",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources"
            },
            "customWidth": "25",
            "name": "parameters - 5 - Copy"
          },
          {
            "type": 11,
            "content": {
              "version": "LinkItem/1.0",
              "style": "paragraph",
              "links": [
                {
                  "id": "36b65f94-1c3d-4e7a-b771-677a2081d288",
                  "cellValue": "",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Remove Monitoring for {PackTagsLeft} Pack ",
                  "preText": "",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [
                      {
                        "key": "action",
                        "value": "removeTag"
                      }
                    ],
                    "body": "{ \n  \"function\": \"tagmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"RemoveTag\",\n    \"Servers\": [{taggedVMs}],\n    \"Pack\": \"{PackTagsLeft}\"\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Remove Monitoring",
                    "description": "# Please confirm the change.\n\nRemove Monitoring for {PackTagsLeft} Pack ",
                    "runLabel": "Confirm"
                  }
                },
                {
                  "id": "550df977-06a8-4c40-9cd3-aba6286ebcdf",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Add Monitoring for {PackTagsLeft} Pack",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"tagmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"AddTag\",\n    \"Servers\": [{taggedVMs}],\n    \"Pack\": \"{PackTagsLeft}\"\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Add Monitoring",
                    "description": "# Please confirm the change.\n\nAdd Monitoring for {PackTagsLeft} Pack ",
                    "actionName": "AddMonitoringPack",
                    "runLabel": "Confirm"
                  }
                },
                {
                  "id": "3b1af630-47ab-43e9-a5b2-d2f2e21880d0",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Remove All Monitoring for VM",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"tagmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"RemoveTag\",\n    \"Servers\": [{taggedVMs}],\n    \"Pack\": \"All\"\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Remove All Monitoring",
                    "description": "# Please confirm the change.\n\nRemove All Monitoring for {PackTagsLeft} Pack ",
                    "actionName": "RemoveAllMonitoring",
                    "runLabel": "Confirm"
                  }
                }
              ]
            },
            "customWidth": "75",
            "name": "links - 1"
          }
        ],
        "exportParameters": true
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "discovery"
      },
      "customWidth": "50",
      "name": "TaggedGroup"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "resources | where type =~ 'microsoft.compute/virtualmachines' or type =~ 'microsoft.hybridcompute/machines' \n| where isempty(tolower(tags.MonitorStarterPacks)) //and subscriptionId in split('{Subscriptions:subscriptionId}',',')\n| project Server=id,['Resource Group']=resourceGroup",
              "size": 0,
              "title": "Non-monitored Machines",
              "exportMultipleValues": true,
              "exportedParameters": [
                {
                  "parameterName": "vmstotag",
                  "parameterType": 1,
                  "quote": ""
                }
              ],
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "visualization": "table",
              "gridSettings": {
                "filter": true,
                "sortBy": [
                  {
                    "itemKey": "$gen_link_Server_0",
                    "sortOrder": 1
                  }
                ]
              },
              "sortBy": [
                {
                  "itemKey": "$gen_link_Server_0",
                  "sortOrder": 1
                }
              ]
            },
            "name": "Non Discoverable Machines",
            "styleSettings": {
              "margin": "400",
              "padding": "400",
              "showBorder": true
            }
          },
          {
            "type": 9,
            "content": {
              "version": "KqlParameterItem/1.0",
              "parameters": [
                {
                  "id": "8a177eab-edac-41cc-84f9-a5b7de931bea",
                  "version": "KqlParameterItem/1.0",
                  "name": "PackTags",
                  "label": "Select Pack to Enable",
                  "type": 2,
                  "isGlobal": true,
                  "query": "resources\n| where type == \"microsoft.insights/datacollectionrules\"\n| where isnotempty(tags.MonitorStarterPacks)\n| project MPs=tostring(tags.MonitorStarterPacks)\n| summarize by MPs",
                  "typeSettings": {
                    "additionalResourceOptions": [],
                    "showDefault": false
                  },
                  "timeContext": {
                    "durationMs": 86400000
                  },
                  "queryType": 1,
                  "resourceType": "microsoft.resourcegraph/resources",
                  "value": null
                }
              ],
              "style": "pills",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources"
            },
            "customWidth": "50",
            "name": "parameters - 5"
          },
          {
            "type": 11,
            "content": {
              "version": "LinkItem/1.0",
              "style": "paragraph",
              "links": [
                {
                  "id": "91fb0fed-0e4f-41ce-9024-98a3cc4432a7",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Enable Monitoring for {PackTags} Pack",
                  "preText": "",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [
                      {
                        "key": "action",
                        "value": "addTag"
                      }
                    ],
                    "body": "{ \n  \"function\": \"tagmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"AddTag\",\n    \"Servers\": [{vmstotag}],\n    \"Pack\": \"{PackTags}\"\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Enable Monitoring Packs",
                    "description": "# This will enable the pack for the following servers:\n{vmstotag}\n\nby adding the {PackTags} to the server.",
                    "actionName": "EnableMonitoring",
                    "runLabel": "Confirm"
                  }
                }
              ]
            },
            "customWidth": "50",
            "name": "links - 1 - Copy"
          }
        ],
        "exportParameters": true
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "discovery"
      },
      "customWidth": "50",
      "name": "NonTaggedGroup"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "title": "Alert Management",
        "items": [
          {
            "type": 9,
            "content": {
              "version": "KqlParameterItem/1.0",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "parameters": [
                {
                  "id": "e99b4870-f7a6-4b8e-95b7-6aaeece1f438",
                  "version": "KqlParameterItem/1.0",
                  "name": "AlertPack",
                  "type": 2,
                  "query": "resources\n| where type == \"microsoft.insights/scheduledqueryrules\"\n| where isnotempty(tags.MonitorStarterPacks)\n| project MPs=tostring(tags.MonitorStarterPacks)\n| summarize by MPs\n",
                  "crossComponentResources": [
                    "{Subscriptions}"
                  ],
                  "typeSettings": {
                    "additionalResourceOptions": []
                  },
                  "timeContext": {
                    "durationMs": 86400000
                  },
                  "queryType": 1,
                  "resourceType": "microsoft.resourcegraph/resources",
                  "value": "LxOS"
                }
              ],
              "style": "pills",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources"
            },
            "name": "parameters - 7"
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "resources\n| where type == \"microsoft.insights/scheduledqueryrules\"\n| where isnotempty(tags.MonitorStarterPacks)\n| project id,MP=tags.MonitorStarterPacks, Enabled=properties.enabled, Description=properties.description, ['Action Group']=split(properties.actions.actionGroups[0],\"/\")[8], location\n| where MP=='{AlertPack}'",
              "size": 0,
              "exportMultipleValues": true,
              "exportedParameters": [
                {
                  "fieldName": "",
                  "parameterName": "alertsselected",
                  "parameterType": 1,
                  "quote": ""
                }
              ],
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "visualization": "table",
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "location",
                    "formatter": 5
                  },
                  {
                    "columnMatch": "name",
                    "formatter": 7
                  }
                ]
              }
            },
            "customWidth": "50",
            "name": "query - 6",
            "styleSettings": {
              "showBorder": true
            }
          },
          {
            "type": 11,
            "content": {
              "version": "LinkItem/1.0",
              "style": "paragraph",
              "links": [
                {
                  "id": "f5cb3ede-91d1-4414-bfa1-a1689f45d0c8",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Enable Alerts",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"alertmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"Enable\", \n    \"alerts\":  [{alertsselected}]\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Enable Alerts",
                    "description": "# This action will Enable the selected Alerts\n\n{alertsselected}",
                    "runLabel": "Confirm"
                  }
                },
                {
                  "id": "d9469141-a104-4696-b9cd-f0fc7e3f963e",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Disable Alerts",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"alertmgmt\",\n  \"functionBody\" : {\n    \"Action\":\"Disable\", \n    \"alerts\":  [{alertsselected}]\n  }\n}\n",
                    "httpMethod": "POST",
                    "title": "Disable Alerts",
                    "description": "# This action will disable the selected Alerts\n\n{alertsselected}",
                    "runLabel": "Confirm"
                  }
                }
              ]
            },
            "customWidth": "50",
            "name": "links - 8"
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "alertmanagement"
      },
      "name": "AlertMGMT"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "resources\n| where type == \"microsoft.insights/datacollectionrules\"\n| extend MPs=tostring(['tags'].MonitorStarterPacks)\n| where isnotempty(MPs) //or properties.dataSources.performanceCounters[0].name == 'VMInsightsPerfCounters'\n| summarize by name\n",
              "size": 1,
              "title": "Select Pack to see associated Machines",
              "exportFieldName": "name",
              "exportParameterName": "selectedRule",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "Group",
                    "formatter": 1
                  }
                ]
              }
            },
            "customWidth": "50",
            "name": "query - 6 - Copy",
            "styleSettings": {
              "showBorder": true
            }
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "insightsresources\n| where type == \"microsoft.insights/datacollectionruleassociations\"\n| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0]\n| where isnotnull(properties.dataCollectionRuleId)\n| project rulename=split(properties.dataCollectionRuleId,\"/\")[8],resourceName=split(resourceId,\"/\")[8],resourceId//ruleId=properties.dataCollectionRuleId\n| where '{selectedRule}'==rulename",
              "size": 1,
              "title": "Associated Machines",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "Group",
                    "formatter": 1
                  }
                ]
              }
            },
            "customWidth": "50",
            "name": "query - 6 - Copy - Copy",
            "styleSettings": {
              "showBorder": true
            }
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "rulemanagement"
      },
      "name": "rulemanagement",
      "styleSettings": {
        "showBorder": true
      }
    },
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "parameters": [
          {
            "id": "982e7108-791d-4582-b245-f6c618045e71",
            "version": "KqlParameterItem/1.0",
            "name": "subscriptionId",
            "type": 6,
            "isGlobal": true,
            "value": "/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca",
            "typeSettings": {
              "additionalResourceOptions": [
                "value::1"
              ],
              "includeAll": false
            },
            "label": "Subscription for Rule List"
          }
        ],
        "style": "pills",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces"
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "rulemanagement"
      },
      "name": "parameters - 11"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "{\"version\":\"ARMEndpoint/1.0\",\"data\":null,\"headers\":[],\"method\":\"GET\",\"path\":\"{subscriptionId}/providers/Microsoft.Insights/dataCollectionRules\",\"urlParams\":[{\"key\":\"$filter\",\"value\":\"tagname eq 'MonitorStarterPacks'\"},{\"key\":\"api-version\",\"value\":\"2021-09-01-preview\"}],\"batchDisabled\":false,\"transformers\":[{\"type\":\"jsonpath\",\"settings\":{\"tablePath\":\"$.value\",\"columns\":[{\"path\":\"id\",\"columnid\":\"id\"},{\"path\":\"$\",\"columnid\":\"properties\"},{\"path\":\"kind\",\"columnid\":\"kind\"},{\"path\":\"location\",\"columnid\":\"location\"},{\"path\":\"properties.provisioningState\",\"columnid\":\"provisioningState\"},{\"path\":\"name\",\"columnid\":\"name\"},{\"path\":\"properties.dataSources.syslog\",\"columnid\":\"syslog\"},{\"path\":\"properties.dataSources.windowsEventLogs[*]\",\"columnid\":\"windowsEventLogs\"},{\"path\":\"properties.dataSources.windowsEventLogs[*].streams[?(@ ==\\\"Microsoft-SecurityEvent\\\")]\",\"columnid\":\"securityEvents\"},{\"path\":\"properties.dataSources.logFiles[*]\",\"columnid\":\"logsettings\"},{\"path\":\"properties.dataSources.performanceCounters[*]\",\"columnid\":\"performanceCounters\"},{\"path\":\"properties.dataCollectionEndpointId\",\"columnid\":\"dataCollectionEndpointId\"},{\"path\":\"properties.dataFlows[?(@.transformKql != \\\"source\\\")].transformKql\",\"columnid\":\"transformKql\"},{\"path\":\"properties.destinations\",\"columnid\":\"destinations\"},{\"path\":\"properties.dataFlows[*].transformKql\",\"columnid\":\"queries\"},{\"path\":\"properties.dataSources\",\"columnid\":\"dataSources\"},{\"path\":\"properties.dataFlows\",\"columnid\":\"dataFlows\"},{\"path\":\"description\",\"columnid\":\"description\"},{\"path\":\"properties.destinations.logAnalytics.*.name\",\"columnid\":\"destinationName\"},{\"path\":\"systemData.lastModifiedBy\",\"columnid\":\"lastModifiedBy\"},{\"path\":\"properties.destinations.logAnalytics.*.workspaceResourceId\",\"columnid\":\"workspaceResourceId\"},{\"path\":\"tags.MonitorStarterPacks\",\"columnid\":\"packs\"}]}}]}",
        "size": 0,
        "title": "List of Currently Configured Data Collection Rules",
        "showRefreshButton": true,
        "exportedParameters": [
          {
            "parameterName": "selectedRule"
          },
          {
            "fieldName": "destinationName",
            "parameterName": "destinationName",
            "parameterType": 1
          },
          {
            "fieldName": "",
            "parameterName": "resourceGroupName",
            "parameterType": 1
          },
          {
            "fieldName": "workspaceResourceId",
            "parameterName": "workspace",
            "parameterType": 5
          },
          {
            "fieldName": "properties",
            "parameterName": "properties",
            "parameterType": 1
          },
          {
            "fieldName": "name",
            "parameterName": "name",
            "parameterType": 1
          },
          {
            "fieldName": "location",
            "parameterName": "location",
            "parameterType": 1
          },
          {
            "fieldName": "Rule Type",
            "parameterName": "kind",
            "parameterType": 1
          },
          {
            "parameterType": 1
          },
          {
            "fieldName": "id",
            "parameterName": "id",
            "parameterType": 1
          }
        ],
        "showExportToExcel": true,
        "exportToExcelOptions": "all",
        "queryType": 12,
        "gridSettings": {
          "formatters": [
            {
              "columnMatch": "id",
              "formatter": 13,
              "formatOptions": {
                "linkColumn": "id",
                "linkTarget": "Resource",
                "linkIsContextBlade": true,
                "showIcon": true
              }
            },
            {
              "columnMatch": "properties",
              "formatter": 7,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "linkLabel": "📋",
                "linkIsContextBlade": true,
                "customColumnWidthSetting": "5ch"
              }
            },
            {
              "columnMatch": "kind",
              "formatter": 18,
              "formatOptions": {
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "Capture",
                    "text": "{0}{1} Custom"
                  },
                  {
                    "operator": "contains",
                    "thresholdValue": "Linux",
                    "representation": "Console",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": "contains",
                    "thresholdValue": "Windows",
                    "representation": "Initial_Access",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": "contains",
                    "thresholdValue": "WorkspaceTransforms",
                    "representation": "Persistence",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "{0}{1}"
                  }
                ],
                "customColumnWidthSetting": "17ch"
              }
            },
            {
              "columnMatch": "location",
              "formatter": 17,
              "formatOptions": {
                "customColumnWidthSetting": "94px"
              }
            },
            {
              "columnMatch": "provisioningState",
              "formatter": 18,
              "formatOptions": {
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "contains",
                    "thresholdValue": "succeeded",
                    "representation": "success",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "{0}{1}"
                  }
                ],
                "customColumnWidthSetting": "17ch"
              },
              "numberFormat": {
                "unit": 0,
                "options": {
                  "style": "decimal"
                }
              }
            },
            {
              "columnMatch": "name",
              "formatter": 5
            },
            {
              "columnMatch": "syslog",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "subTarget": "2",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Enabled"
                  }
                ],
                "bladeOpenContext": {
                  "bladeName": "DataCollectionRulesDataSourceManagementViewModel",
                  "extensionName": "Microsoft_Azure_Monitoring",
                  "bladeParameters": [
                    {
                      "name": "id",
                      "source": "column",
                      "value": "id"
                    }
                  ]
                },
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "windowsEventLogs",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "securityEvents",
              "formatter": 18,
              "formatOptions": {
                "linkColumn": "windowsEventLogs",
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "logsettings",
              "formatter": 18,
              "formatOptions": {
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "performanceCounters",
              "formatter": 18,
              "formatOptions": {
                "linkColumn": "performanceCounters",
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "dataCollectionEndpointId",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "Resource",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "21.7143ch"
              }
            },
            {
              "columnMatch": "transformKql",
              "formatter": 18,
              "formatOptions": {
                "linkColumn": "queries",
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "stopped",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "contains",
                    "thresholdValue": "Workspace",
                    "representation": "success",
                    "text": "Ingestion KQL"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Custom KQL"
                  }
                ],
                "bladeOpenContext": {
                  "bladeName": "CreateMicrosoftTableTransformBlade",
                  "extensionName": "Microsoft_OperationsManagementSuite_Workspace",
                  "bladeJsonParameters": "{\r\n\t\"workspaceResourceId\" : \"{workspace}\",\r\n\t\"providers\" : \"microsoft.operationalinsights\",\r\n\t\"table\" : { \r\n\t\t\"name\" : \"{selectedTableName}\",\r\n\t\t\"description\":\"Security events collected from windows machines by Azure Security Center or Azure Sentinel.\",\r\n\t\t\"hasData\":true,\r\n\t\t\"tableType\":\"Microsoft\",\r\n\t\t\"tableAPIState\":\"Any\",\r\n\t\t\"solutions\":[\"Security and Audit\",\"Microsoft Sentinel\"],\r\n\t\t\"categories\":[\"Security\"],\r\n\t\t\"retentionInDaysAsDefault\":false,\r\n\t\t\"totalRetentionInDaysAsDefault\":false,\r\n\t\t\"isEditTransformationEnabled\":true,\r\n\t\t\"isCreateTransformationEnabled\":true\r\n\t},\r\n\t\"isMicrosoftTable\" : true,\r\n\t\"isMigrationRequired\" : false\r\n}"
                },
                "customColumnWidthSetting": "22ch"
              }
            },
            {
              "columnMatch": "destinations",
              "formatter": 5
            },
            {
              "columnMatch": "queries",
              "formatter": 5
            },
            {
              "columnMatch": "dataSources",
              "formatter": 5
            },
            {
              "columnMatch": "dataFlows",
              "formatter": 5,
              "formatOptions": {
                "aggregation": "Sum"
              }
            },
            {
              "columnMatch": "description",
              "formatter": 5
            },
            {
              "columnMatch": "destinationName",
              "formatter": 5
            },
            {
              "columnMatch": "lastModifiedBy",
              "formatter": 5
            },
            {
              "columnMatch": "workspaceResourceId",
              "formatter": 13,
              "formatOptions": {
                "linkTarget": "Resource",
                "showIcon": true,
                "customColumnWidthSetting": "16.8571ch"
              }
            },
            {
              "columnMatch": "customEvents",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "is Empty",
                    "representation": "cancelled",
                    "text": "Not Configured"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "success",
                    "text": "Configured"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            },
            {
              "columnMatch": "StepTab",
              "formatter": 5
            }
          ],
          "rowLimit": 1000,
          "filter": true,
          "sortBy": [
            {
              "itemKey": "packs",
              "sortOrder": 2
            }
          ],
          "labelSettings": [
            {
              "columnId": "id",
              "label": "Data Collection Rule"
            },
            {
              "columnId": "properties",
              "label": " "
            },
            {
              "columnId": "kind",
              "label": "Rule Type"
            },
            {
              "columnId": "location",
              "label": "Location"
            },
            {
              "columnId": "provisioningState",
              "label": "Provisioned",
              "comment": "State of configuration "
            },
            {
              "columnId": "syslog",
              "label": "Syslog"
            },
            {
              "columnId": "windowsEventLogs",
              "label": "Windows Events"
            },
            {
              "columnId": "securityEvents",
              "label": "Security Events"
            },
            {
              "columnId": "dataCollectionEndpointId",
              "label": "Collection Endpoint"
            },
            {
              "columnId": "transformKql",
              "label": "Ingestion Transform"
            },
            {
              "columnId": "destinations",
              "label": "Destinations"
            },
            {
              "columnId": "workspaceResourceId",
              "label": "Workspace"
            }
          ]
        },
        "sortBy": [
          {
            "itemKey": "packs",
            "sortOrder": 2
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "rulemanagement"
      },
      "name": "Select Existing DCR",
      "styleSettings": {
        "showBorder": true
      }
    },
    {
      "type": 9,
      "content": {
        "version": "KqlParameterItem/1.0",
        "parameters": [
          {
            "id": "44db682e-1ba1-41c5-91d2-7861edb7e9a2",
            "version": "KqlParameterItem/1.0",
            "name": "packsURL",
            "type": 1,
            "isRequired": true,
            "isGlobal": true,
            "criteriaData": [
              {
                "criteriaContext": {
                  "operator": "Default",
                  "resultValType": "static",
                  "resultVal": "https://azmonstarpacksngqf.blob.core.windows.net/discovery/packs.json?sp=r&st=2023-07-15T12:55:49Z&se=2024-03-09T21:55:49Z&spr=https&sv=2022-11-02&sr=c&sig=KrVS0O3LePHX%2FDkT9HkWFMFqPg5mea1ehf6%2FKZdDl8E%3D"
                }
              }
            ],
            "timeContext": {
              "durationMs": 86400000
            }
          }
        ],
        "style": "pills",
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces"
      },
      "conditionalVisibilities": [
        {
          "parameterName": "tabSelection",
          "comparison": "isEqualTo",
          "value": "rulemanagement"
        },
        {
          "parameterName": "showHidden",
          "comparison": "isEqualTo",
          "value": "yes"
        }
      ],
      "name": "parameters - 13"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "externaldata(PackName: string, RequiredTag:string, Status:string, TemplateLocation:string)\n[ \n   h@'{packsURL}'\n]\nwith(format='multijson', ingestionMapping='[{\"PackName\":\"PackName\",\"RequiredTag\":\"RequiredTag\", \"Status\":\"Status\",\"TemplateLocation\":\"TemplateLocation\"}]')\n| where Status == 'Enabled'\n| extend URLPath=trim_start('.',TemplateLocation)\n",
        "size": 1,
        "title": "Available Packs (Enabled) from Json file in SA",
        "timeContext": {
          "durationMs": 86400000
        },
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "crossComponentResources": [
          "{Workspace}"
        ],
        "gridSettings": {
          "formatters": [
            {
              "columnMatch": "TemplateLocation",
              "formatter": 7,
              "formatOptions": {
                "linkTarget": "ArmTemplate",
                "templateRunContext": {
                  "componentIdSource": "parameter",
                  "templateUriSource": "static",
                  "templateUri": "https://azmonstarpacksngqf.blob.core.windows.net/discovery/packs.json?sp=r&st=2023-07-15T12:55:49Z&se=2024-03-09T21:55:49Z&spr=https&sv=2022-11-02&sr=c&sig=KrVS0O3LePHX%2FDkT9HkWFMFqPg5mea1ehf6%2FKZdDl8E%3D'",
                  "templateParameters": [],
                  "titleSource": "static",
                  "descriptionSource": "static",
                  "runLabelSource": "static"
                }
              }
            }
          ]
        }
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "rulemanagement"
      },
      "name": "availPacks"
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "title": "Policy Assignment Status",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "policyresources | where type == \"microsoft.policyinsights/policystates\" | extend policyName=tostring(properties.policyDefinitionName), complianceState=properties.complianceState\n| join (policyresources | where type == \"microsoft.authorization/policydefinitions\" and isnotempty(properties.metadata.MonitorStarterPacks) | project policyId=id, policyName=name) on policyName\n| project policyId, policyName, complianceState, type='Policy'\n| union( policyresources | where type == \"microsoft.policyinsights/policystates\"| extend policySetName=tostring(properties.policySetDefinitionName),complianceState=properties.complianceState\n| join (policyresources | where type == \"microsoft.authorization/policysetdefinitions\" and isnotempty(properties.metadata.MonitorStarterPacks) | project policySetId=id, policySetName=name) on policySetName\n| project policyId=policySetId, policyName=policySetName, complianceState, type='Set')",
              "size": 1,
              "title": "Assignment Status (Compliance)",
              "exportedParameters": [
                {
                  "parameterName": "policiesToRemediate",
                  "parameterType": 5
                }
              ],
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "complianceState",
                    "formatter": 18,
                    "formatOptions": {
                      "thresholdsOptions": "icons",
                      "thresholdsGrid": [
                        {
                          "operator": "==",
                          "thresholdValue": "Compliant",
                          "representation": "success",
                          "text": "Compliant"
                        },
                        {
                          "operator": "==",
                          "thresholdValue": "Non-compliant",
                          "representation": "2",
                          "text": "Non-Compliant"
                        },
                        {
                          "operator": "Default",
                          "thresholdValue": null,
                          "representation": "warning",
                          "text": "{0}{1}"
                        }
                      ]
                    }
                  }
                ]
              }
            },
            "customWidth": "50",
            "conditionalVisibility": {
              "parameterName": "tabSelection",
              "comparison": "isEqualTo",
              "value": "policystatus"
            },
            "name": "query - 8",
            "styleSettings": {
              "showBorder": true
            }
          },
          {
            "type": 11,
            "content": {
              "version": "LinkItem/1.0",
              "style": "list",
              "links": [
                {
                  "id": "b3bb5a4d-0f95-4e9a-8634-9cb027f860aa",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Remediate (all policies)",
                  "preText": "",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"policymgmt\",\n  \"functionBody\" : {\n    \"SolutionTag\":\"MonitorStarterPacks\",\n    \"Action\": \"Remediate\"\n  }\n}",
                    "httpMethod": "POST",
                    "description": "# Please confirm the change.",
                    "runLabel": "Confirm"
                  }
                },
                {
                  "id": "8dfc5afa-108a-4713-8a0c-651c3a32c5f1",
                  "linkTarget": "ArmAction",
                  "linkLabel": "Check Compliance",
                  "style": "primary",
                  "linkIsContextBlade": true,
                  "armActionContext": {
                    "path": "{logicAppResource}/triggers/manual/run?api-version=2016-06-01",
                    "headers": [],
                    "params": [],
                    "body": "{ \n  \"function\": \"policymgmt\",\n  \"functionBody\" : {\n    \"SolutionTag\":\"MonitorStarterPacks\",\n    \"Action\": \"Scan\"\n  }\n}",
                    "httpMethod": "POST",
                    "title": "Check Policy Compliance",
                    "description": "# Please confirm the scan.",
                    "runLabel": "Confirm"
                  }
                }
              ]
            },
            "customWidth": "50",
            "name": "links - 3"
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "policyresources\n| where type == \"microsoft.authorization/policyassignments\"\n| project AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId), PolicyName=split(properties.PolicyId,\"/\")[8]\n| join (policyresources | where type == \"microsoft.authorization/policydefinitions\" and isnotempty(properties.metadata.MonitorStarterPacks)\n| project Name=name, Type='Policy',['id']) on $left.PolicyId == $right.id\n| project Name,Type, AssignmentDisplayName, scope\n| union (policyresources\n| where type == \"microsoft.authorization/policyassignments\"\n| project AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId), PolicyName=split(properties.PolicyId,\"/\")[8]\n| join (policyresources | where type == \"microsoft.authorization/policysetdefinitions\" and isnotempty(properties.metadata.MonitorStarterPacks)\n| project Name=name, Type='Initiative',['id']) on $left.PolicyId == $right.id\n| project Name, Type, AssignmentDisplayName, scope)\n",
              "size": 1,
              "title": "Installed Policies and Initiatives with Assignments",
              "noDataMessage": "No MonStar policies (packs) installed.",
              "queryType": 1,
              "resourceType": "microsoft.resourcegraph/resources",
              "crossComponentResources": [
                "{Subscriptions}"
              ],
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "Group",
                    "formatter": 1
                  }
                ],
                "filter": true,
                "hierarchySettings": {
                  "treeType": 1,
                  "groupBy": [
                    "Name"
                  ]
                }
              }
            },
            "conditionalVisibility": {
              "parameterName": "tabSelection",
              "comparison": "isEqualTo",
              "value": "policystatus"
            },
            "name": "query - 8 - Copy",
            "styleSettings": {
              "showBorder": true
            }
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "policystatus"
      },
      "name": "policymgmt"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "Resources\n| where type == 'microsoft.compute/virtualmachines'\n| extend\n    JoinID = toupper(id),\n    OSName = tostring(properties.osProfile.computerName),\n    OSType = tostring(properties.storageProfile.osDisk.osType)\n| join kind=leftouter(\n    Resources\n    | where ( type == 'microsoft.compute/virtualmachines/extensions') and name in ('AzureMonitorLinuxAgent', 'AzureMonitorWindowsAgent')\n    | extend\n        VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),\n        ExtensionName = name\n) on $left.JoinID == $right.VMId\n| union (Resources\n| where type == 'microsoft.hybridcompute/machines'\n| extend\n    JoinID = toupper(id),\n    OSName = tostring(properties.osProfile.computerName),\n    OSType = tostring(properties.osType)\n| join kind=leftouter(\n    Resources\n    | where type == 'microsoft.hybridcompute/machines/extensions' and name in ('AzureMonitorLinuxAgent', 'AzureMonitorWindowsAgent')\n    | extend\n        VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),\n        ExtensionName = name\n) on $left.JoinID == $right.VMId)\n| summarize by id, OSName, OSType, ExtensionName\n| order by tolower(OSName) asc",
        "size": 0,
        "title": "Agent Install Status",
        "queryType": 1,
        "resourceType": "microsoft.resourcegraph/resources",
        "visualization": "table",
        "gridSettings": {
          "formatters": [
            {
              "columnMatch": "ExtensionName",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "==",
                    "thresholdValue": "AzureMonitorLinuxAgent",
                    "representation": "success",
                    "text": "Linux Agent"
                  },
                  {
                    "operator": "==",
                    "thresholdValue": "AzureMonitorWindowsAgent",
                    "representation": "success",
                    "text": "Windows Agent"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "stopped",
                    "text": "No Agent"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            }
          ],
          "filter": true
        },
        "sortBy": []
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "agentmgmt"
      },
      "customWidth": "50",
      "name": "query - agent install status",
      "styleSettings": {
        "showBorder": true
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "Resources\n| where type == 'microsoft.compute/virtualmachines'\n| extend\n    JoinID = toupper(id),\n    OSName = tostring(properties.osProfile.computerName),\n    OSType = tostring(properties.storageProfile.osDisk.osType)\n| join kind=leftouter(\n    Resources\n    | where ( type == 'microsoft.compute/virtualmachines/extensions') and name in ('AzureMonitorLinuxAgent', 'AzureMonitorWindowsAgent')\n    | extend\n        VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),\n        ExtensionName = name\n) on $left.JoinID == $right.VMId\n| union (Resources\n| where type == 'microsoft.hybridcompute/machines'\n| extend\n    JoinID = toupper(id),\n    OSName = tostring(properties.osProfile.computerName),\n    OSType = tostring(properties.osType)\n| join kind=leftouter(\n    Resources\n    | where type == 'microsoft.hybridcompute/machines/extensions' and name in ('AzureMonitorLinuxAgent', 'AzureMonitorWindowsAgent')\n    | extend\n        VMId = toupper(substring(id, 0, indexof(id, '/extensions'))),\n        ExtensionName = name\n) on $left.JoinID == $right.VMId)\n| summarize count() by ExtensionName",
        "size": 1,
        "title": "Agent Install Status",
        "queryType": 1,
        "resourceType": "microsoft.resourcegraph/resources",
        "visualization": "piechart",
        "gridSettings": {
          "formatters": [
            {
              "columnMatch": "ExtensionName",
              "formatter": 18,
              "formatOptions": {
                "linkTarget": "CellDetails",
                "linkIsContextBlade": true,
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "==",
                    "thresholdValue": "AzureMonitorLinuxAgent",
                    "representation": "success",
                    "text": "Linux Agent"
                  },
                  {
                    "operator": "==",
                    "thresholdValue": "AzureMonitorWindowsAgent",
                    "representation": "success",
                    "text": "Windows Agent"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": "stopped",
                    "text": "No Agent"
                  }
                ],
                "customColumnWidthSetting": "20ch"
              }
            }
          ],
          "filter": true
        },
        "chartSettings": {
          "seriesLabelSettings": [
            {
              "seriesName": "",
              "label": "No Agent",
              "color": "red"
            }
          ]
        }
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "agentmgmt"
      },
      "customWidth": "50",
      "name": "query - agent install status - Copy",
      "styleSettings": {
        "showBorder": true
      }
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "Heartbeat | where Category == \"Azure Monitor Agent\"\n| summarize arg_max(TimeGenerated, *) by Computer\n| project  Computer,LastHeartbeat=TimeGenerated, ['SecondsAgo']=datetime_diff('second',now(),TimeGenerated)\n| sort by SecondsAgo asc",
        "size": 4,
        "title": "Last Heartbeat (24 hours)",
        "timeContext": {
          "durationMs": 86400000
        },
        "queryType": 0,
        "resourceType": "microsoft.operationalinsights/workspaces",
        "gridSettings": {
          "formatters": [
            {
              "columnMatch": "SecondsAgo",
              "formatter": 18,
              "formatOptions": {
                "thresholdsOptions": "icons",
                "thresholdsGrid": [
                  {
                    "operator": "<=",
                    "thresholdValue": "600",
                    "representation": "success",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": ">",
                    "thresholdValue": "600",
                    "representation": "2",
                    "text": "{0}{1}"
                  },
                  {
                    "operator": "Default",
                    "thresholdValue": null,
                    "representation": null,
                    "text": "{0}{1}"
                  }
                ]
              }
            }
          ],
          "filter": true
        }
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "agentmgmt"
      },
      "customWidth": "50",
      "name": "query - 16",
      "styleSettings": {
        "showBorder": true
      }
    },
    {
      "type": 12,
      "content": {
        "version": "NotebookGroup/1.0",
        "groupType": "editable",
        "title": "ALZ Baseline Alerts Info",
        "items": [
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "policyresources\n| where type == \"microsoft.authorization/policydefinitions\"\n| where properties.metadata.source=='https://github.com/Azure/ALZ-Monitor/'\n| project  id,Name=name, ['Display Name']=properties.displayName",
              "size": 0,
              "queryType": 1,
              "resourceType": "microsoft.resources/tenants",
              "crossComponentResources": [
                "value::tenant"
              ],
              "gridSettings": {
                "formatters": [
                  {
                    "columnMatch": "id",
                    "formatter": 7,
                    "formatOptions": {
                      "linkTarget": "Resource",
                      "linkLabel": "View"
                    }
                  }
                ],
                "filter": true
              }
            },
            "name": "query - 0",
            "styleSettings": {
              "showBorder": true
            }
          },
          {
            "type": 3,
            "content": {
              "version": "KqlItem/1.0",
              "query": "policyresources\n| where type == \"microsoft.authorization/policyassignments\"\n| project AssignmentDisplayName=properties.displayName,scope=properties.scope,PolicyId=tostring(properties.policyDefinitionId), PolicyName=split(properties.PolicyId,\"/\")[8]\n| join (policyresources\n| where type == \"microsoft.authorization/policydefinitions\"\n| where properties.metadata.source=='https://github.com/Azure/ALZ-Monitor/') on $left.PolicyId == $right.id\n| project AssignmentDisplayName, PolicyId, Scope=scope",
              "size": 0,
              "queryType": 1,
              "resourceType": "microsoft.resources/tenants",
              "crossComponentResources": [
                "value::tenant"
              ],
              "gridSettings": {
                "filter": true
              }
            },
            "name": "query - 1",
            "styleSettings": {
              "showBorder": true
            }
          }
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "alzinfo"
      },
      "name": "alzgroup"
    },
    {
      "type": 3,
      "content": {
        "version": "KqlItem/1.0",
        "query": "requests\n| project\n    timestamp,\n    id,\n    operation_Name,\n    success,\n    resultCode,\n    duration,\n    cloud_RoleName\n| where timestamp > ago(30d)\n| where cloud_RoleName =~ 'MonitorStarterPacks-6c64f9ed' //and operation_Name =~ 'tagmgmt'\n| order by timestamp desc\n| take 20",
        "size": 0,
        "title": "Function Runs",
        "timeContext": {
          "durationMs": 86400000
        },
        "queryType": 0,
        "resourceType": "microsoft.insights/components",
        "crossComponentResources": [
          "/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/amonstarterpacks3/providers/Microsoft.Insights/components/MonitorStarterPacks-6c64f9ed"
        ]
      },
      "conditionalVisibility": {
        "parameterName": "tabSelection",
        "comparison": "isEqualTo",
        "value": "backend"
      },
      "name": "query - 15",
      "styleSettings": {
        "showBorder": true
      }
    }
  ],
  "fallbackResourceIds": [
    "Azure Monitor"
  ],
  "$schema": "https://github.com/Microsoft/Application-Insights-Workbooks/blob/master/schema/workbook.json"
}
'''
// var wbConfig2='"/subscriptions/${subscriptionId}/resourceGroups/${rg}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}"]}'
// //var wbConfig3='''
// //'''
// // var wbConfig='${wbConfig1}${wbConfig2}${wbConfig3}'
// var wbConfig='${wb}${wbConfig2}'

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  location: location
  tags: {
    '${solutionTag}': 'mainworkbook'
    '${solutionTag}-Version': solutionVersion
  }
  kind: 'shared'
  name: guid('monstar')
  properties:{
    displayName: 'Azure Monitor Starter Packs'
    serializedData: wbConfig
    category: 'workbook'
    sourceId: lawresourceid
  }
}

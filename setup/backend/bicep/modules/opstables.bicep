param retentionDays int = 7
param availableIaaSPackstablename string = 'AvailableIaaSPacks_CL'
param supportedServicesTableName string = 'SupportedServices_CL'
param monitoredPaaSTableName string = 'MonitoredPaaSTable_CL'
param nonMonitoredPaaSTableName string = 'NonMonitoredPaaSTable_CL'
// param Tags object = {}
// param dceId string
// param location string = resourceGroup().location
// param ruleName string = 'AMP-backendDCR'
param workspaceResourceId string
param wsfriendlyname string = split(workspaceResourceId, '/')[8]

var streamnames = [
  'Custom-${availableIaaSPackstablename}'
  'Custom-${supportedServicesTableName}'
  'Custom-${monitoredPaaSTableName}'
  'Custom-${nonMonitoredPaaSTableName}'
]

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: wsfriendlyname
}

resource availableiaaspackstable 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  name: availableIaaSPackstablename
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: availableIaaSPackstablename
        columns: [
            //Name, Tag, Numberof Rules, Number of Alerts, AlertNames
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'Name'
                type: 'string'
            }
            {
                name: 'Tag'
                type: 'string'
            }
            {
                name: 'NumberofRules'
                type: 'int'
            }
            {
                name: 'NumberofAlerts'
                type: 'int'
            }
            {
                name: 'AlertNames'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

resource supportedServicesTable 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  name: supportedServicesTableName
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: supportedServicesTableName
        columns: [
            //category, service,namespace,metricnamespace,tag,numberofmetrics,details
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'namespace'
                type: 'string'
            }
            {
                name: 'category'
                type: 'string'
            }
            {
                name: 'service'
                type: 'string'
            }
            {
                name: 'metricnamespace'
                type: 'string'
            }
            {
                name: 'tag'
                type: 'string'
            }
            {
                name: 'NumberOfMetrics'
                type: 'int'
            }
            {
                name: 'Details'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

resource monitoredPaaSTable 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  name: monitoredPaaSTableName
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: monitoredPaaSTableName
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'Resource'
                type: 'string'
            }
            {
                name: 'resourcetype'
                type: 'string'
            }
            {
                name: 'resourceGroup'
                type: 'string'
            }
            {
                name: 'location'
                type: 'string'
            }
            {
                name: 'subscriptionId'
                type: 'string'
            }
            {
                name: 'resourcekind'
                type: 'string'
            }
            {
                name: 'AlertCount'
                type: 'int'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

resource nonMonitoredPaaSTable 'Microsoft.OperationalInsights/workspaces/tables@2025-02-01' = {
  name: nonMonitoredPaaSTableName
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: nonMonitoredPaaSTableName
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }// need Resource, type, resourceGroup,location,subscriptionId,kind,tag
            {
                name: 'Resource'
                type: 'string'
            }
            {
                name: 'resourcetype'
                type: 'string'
            }
            {
                name: 'resourceGroup'
                type: 'string'
            }
            {
                name: 'location'
                type: 'string'
            }
            {
                name: 'subscriptionId'
                type: 'string'
            }
            {
                name: 'resourcekind'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

// resource opsDCR 'Microsoft.Insights/dataCollectionRules@2023-03-11' = {
//   location: location
//   dependsOn: [
//     availableiaaspackstable
//     supportedServicesTable
//     monitoredPaaSTable
//     nonMonitoredPaaSTable
//   ]
//   name: '${ruleName}-ops'
//   tags: Tags
//   properties: {
//     description: 'Data collection rule for workload backend management.'
//     dataCollectionEndpointId: dceId
//     streamDeclarations: {
//       '${streamnames[0]}' : {
//         columns: [
//             {
//                 name: 'TimeGenerated'
//                 type: 'datetime'
//             }
//             {
//                 name: 'Name'
//                 type: 'string'
//             }
//             {
//                 name: 'Tag'
//                 type: 'string'
//             }
//             {
//                 name: 'NumberofRules'
//                 type: 'int'
//             }
//             {
//                 name: 'NumberofAlerts'
//                 type: 'int'
//             }
//             {
//                 name: 'AlertNames'
//                 type: 'string'
//             }
//         ]
//       }
//         '${streamnames[1]}' : {
//             columns: [
//                 {
//                     name: 'TimeGenerated'
//                     type: 'datetime'
//                 }
//                 {
//                     name: 'namespace'
//                     type: 'string'
//                 }
//                 {
//                     name: 'category'
//                     type: 'string'
//                 }
//                 {
//                     name: 'service'
//                     type: 'string'
//                 }
//                 {
//                     name: 'metricnamespace'
//                     type: 'string'
//                 }
//                 {
//                     name: 'tag'
//                     type: 'string'
//                 }
//                 {
//                     name: 'NumberOfMetrics'
//                     type: 'int'
//                 }
//                 {
//                     name: 'Details'
//                     type: 'string'
//                 }
//             ]
//         }
//         '${streamnames[2]}' : {
//             columns: [
//                 {
//                     name: 'TimeGenerated'
//                     type: 'datetime'
//                 }
//                 {
//                     name: 'Resource'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourcetype'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourceGroup'
//                     type: 'string'
//                 }
//                 {
//                     name: 'location'
//                     type: 'string'
//                 }
//                 {
//                     name: 'subscriptionId'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourcekind'
//                     type: 'string'
//                 }
//                 {
//                     name: 'AlertCount'
//                     type: 'int'
//                 }
//             ]
//         }
//         '${streamnames[3]}' : {
//             columns: [
//                 {
//                     name: 'TimeGenerated'
//                     type: 'datetime'
//                 }
//                 {
//                     name: 'Resource'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourcetype'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourceGroup'
//                     type: 'string'
//                 }
//                 {
//                     name: 'location'
//                     type: 'string'
//                 }
//                 {
//                     name: 'subscriptionId'
//                     type: 'string'
//                 }
//                 {
//                     name: 'resourcekind'
//                     type: 'string'
//                 }
//             ]
//         }
//     }
//     destinations: {
//         logAnalytics: [
//             {
//                 workspaceResourceId: workspaceResourceId
//                 name: wsfriendlyname
//             }
//         ]
//     }
//     dataFlows: [
//         {
//             streams: [
//                 '${streamnames[0]}'
//             ]
//             destinations: [
//                 wsfriendlyname
//             ]
//             transformKql: 'source'
//             outputStream: streamnames[0]
//         }
//         {
//             streams: [
//                 '${streamnames[1]}'
//             ]
//             destinations: [
//                 wsfriendlyname
//             ]
//             transformKql: 'source'
//             outputStream: streamnames[1]
//         }
//         {
//             streams: [
//                 '${streamnames[2]}'
//             ]
//             destinations: [
//                 wsfriendlyname
//             ]
//             transformKql: 'source | project TimeGenerated, Resource, resourcetype, resourceGroup, location, subscriptionId, resourcekind'
//             outputStream: streamnames[2]
//         }
//         {
//             streams: [
//                 '${streamnames[3]}'
//             ]
//             destinations: [
//                 wsfriendlyname
//             ]
//             transformKql: 'source | project TimeGenerated, Resource, resourcetype, resourceGroup, location, subscriptionId, resourcekind'
//             outputStream: streamnames[3]
//         }

//     ]
//   }
// }
// output RuleId string = opsDCR.id
// output opsdcrimmutableId string = opsDCR.properties.immutableId
output streamNames array = streamnames


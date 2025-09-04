//param vmResourceId string
param vmResourceIds array
param rulename string
param actiongroupid string
param location string
//param vmname string
//var vnetName = last(split(vnetId, '/'))
//var subnetRef = '${vnetId}/subnets/${subnetName}'
var allOfList = [
{
  name: 'Metric1'
  metricName: 'Network In Total'
  metricNamespace: 'Microsoft.Compute/virtualMachines'
  operator: 'GreaterThan'
  timeAggregation: 'Total'
  criterionType: 'StaticThresholdCriterion'
  threshold: 500000000000
}
{
  name: 'Metric1'
  metricName: 'Network Out Total'
  metricNamespace: 'Microsoft.Compute/virtualMachines'
  operator: 'GreaterThan'
  timeAggregation: 'Total'
  criterionType: 'StaticThresholdCriterion'
  threshold: 200000000000
}
]

module virtualMachineName_VmAlertsRules 'virtualMachineName_MetricsAlert.bicep' = [for metricAllOf in allOfList: {
  name: '${rulename}-${replace(metricAllOf.metricName, ' ', '_')}'
  params: {
    name: '${rulename}-${replace(metricAllOf.metricName, ' ', '_')}'
    vmResourceIds: vmResourceIds
    severity: 3
    allOf: [
      metricAllOf
    ]
    actionGroups: [
      {
        actionGroupId: actiongroupid
        webhookProperties: {}
      }
    ]
    location: 'Global'
    resourceLocation: location
    //vmResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachines/${vmname}'
  }
}] 
// module virtualMachineName_VmAlertsRule_0 'virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-0'
//   params: {
//     name: 'Percentage CPU - testalertvm'
//     vmResourceIds: vmResourceIds
//     severity: 3
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'Percentage CPU'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'GreaterThan'
//         timeAggregation: 'Average'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 80
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     resourceLocation: location
//     //vmResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachines/${vmname}'
//   }
// }

// module virtualMachineName_VmAlertsRule_1 'virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-1'
//   params: {
//     name: 'Available Memory Bytes - testalertvm'
//     severity: 3
//     vmResourceIds: vmResourceIds
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'Available Memory Bytes'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'LessThan'
//         timeAggregation: 'Average'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 1000000000
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     //vmResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachines/${vmname}'
//   }
// }

// module virtualMachineName_VmAlertsRule_2 'virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-2'
//   params: {
//     name: 'Data Disk IOPS Consumed Percentage - testalertvm'
//     severity: 3
//     vmResourceIds: vmResourceIds
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'Data Disk IOPS Consumed Percentage'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'GreaterThan'
//         timeAggregation: 'Average'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 95
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     //vmResourceId: vmResourceId
//   }
// }

// module virtualMachineName_VmAlertsRule_3 'virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-3'
//   params: {
//     name: 'OS Disk IOPS Consumed Percentage - testalertvm'
//     severity: 3
//     vmResourceIds: vmResourceIds
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'OS Disk IOPS Consumed Percentage'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'GreaterThan'
//         timeAggregation: 'Average'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 95
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     //vmResourceId: '/subscriptions/${subscription().subscriptionId}/resourceGroups/${resourceGroup().name}/providers/Microsoft.Compute/virtualMachines/${vmname}'
//   }
// }

// module virtualMachineName_VmAlertsRule_4 'virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-4'
//   params: {
//     name: 'Network In Total - testalertvm'
//     severity: 3
//     vmResourceIds: vmResourceIds
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'Network In Total'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'GreaterThan'
//         timeAggregation: 'Total'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 500000000000
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     //vmResourceId: vmResourceId
//   }
// }

// module virtualMachineName_VmAlertsRule_5 './virtualMachineName_MetricsAlert.bicep' = {
//   name: '${rulename}-VmAlertsRule-5'
//   params: {
//     name: 'Network Out Total - testalertvm'
//     severity: 3
//     vmResourceIds: vmResourceIds
//     allOf: [
//       {
//         name: 'Metric1'
//         metricName: 'Network Out Total'
//         metricNamespace: 'Microsoft.Compute/virtualMachines'
//         operator: 'GreaterThan'
//         timeAggregation: 'Total'
//         criterionType: 'StaticThresholdCriterion'
//         threshold: 200000000000
//       }
//     ]
//     actionGroups: [
//       {
//         actionGroupId: actiongroupid
//         webhookProperties: {}
//       }
//     ]
//     location: 'Global'
//     //vmResourceId: vmResourceId
//   }
// }

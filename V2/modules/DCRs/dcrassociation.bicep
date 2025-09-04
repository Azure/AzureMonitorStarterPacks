// @description('The name of the virtual machine.')
// param vmName string
@description('The Id of the virtual machine.')
param vmId string

@description('The name of the association.')
param associationName string

@description('The resource ID of the data collection rule.')
param dataCollectionRuleId string

param osTarget string
param vmOS string

//var vmName = split(vmId, '/')[8]
var serverType = toLower(split(vmId, '/')[7])
var vmResourceGroup = split(vmId, '/')[4]
var vmSubscriptionId = split(vmId, '/')[2]

module applyAssociation 'association.bicep' = if (vmOS == osTarget || osTarget == 'All') {
  name: 'applyAssociation'
  scope: resourceGroup(vmSubscriptionId, vmResourceGroup)
  params: {
    vmId: vmId
    serverType: serverType
    associationName: associationName
    dataCollectionRuleId: dataCollectionRuleId
  }
}

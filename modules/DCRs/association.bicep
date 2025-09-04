
param associationName string
param vmId string
param dataCollectionRuleId string
param serverType string
var vmName=split(vmId, '/')[8]

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' existing = if (serverType == 'virtualmachines') {
  name: vmName
}
resource arcserver 'Microsoft.HybridCompute/machines@2022-11-10' existing = if (serverType == 'machines') {
  name: vmName
}
resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-04-01' = if (serverType == 'virtualmachines'){
  name: associationName
  scope: vm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dataCollectionRuleId
    //dataCollectionEndpointId: vm.id
  }
}
resource associationarc 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = if (serverType == 'machines') {
   name: associationName
   scope: arcserver
   properties: {
     description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
     dataCollectionRuleId: dataCollectionRuleId
     //dataCollectionEndpointId: arcserver.id
   }
 }

@description('The name of the virtual machine.')
param vmName string

@description('The name of the association.')
param associationName string

@description('The resource ID of the data collection rule.')
param dataCollectionRuleId string

resource arcvm 'microsoft.hybridcompute/machines@2021-08-02' existing =  {
  name: vmName
}

resource association 'Microsoft.Insights/dataCollectionRuleAssociations@2021-09-01-preview' = {
  name: associationName
  scope: arcvm
  properties: {
    description: 'Association of data collection rule. Deleting this association will break the data collection for this virtual machine.'
    dataCollectionRuleId: dataCollectionRuleId
  }
}

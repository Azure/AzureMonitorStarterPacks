param location string
param wsId string
param subscriptionId string
param rg string
var logAnalyticsWorkspaceName = split(wsId, '/')[8]

var wb = loadTextContent('mainWB.workbook')
//var wbConfig2='"/subscriptions/${subscriptionId}/resourceGroups/${rg}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}"]}'
//var wbConfig3='''
// //'''
// // var wbConfig='${wbConfig1}${wbConfig2}${wbConfig3}'
// var wbConfig='${wb}${wbConfig2}'

module mainwb 'workbook.bicep' = {
  name: 'mainwb'
  params: {
    location: location
    wsId: wsId
    subscriptionId: subscriptionId
    rg: rg
    wb: wb
    wbDisplayName: 'Azure Monitoring Starter Packs'
    wbName: 'AzureMonitoringStarterPacks'
  }
}

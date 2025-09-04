param location string
param wbName string
param wsId string
param subscriptionId string
param rg string
param wbDisplayName string
param wb string

var logAnalyticsWorkspaceName = split(wsId, '/')[8]

//var wb = loadTextContent(wbFileName)

var wbConfig2='"/subscriptions/${subscriptionId}/resourceGroups/${rg}/providers/Microsoft.OperationalInsights/workspaces/${logAnalyticsWorkspaceName}"]}'
// //var wbConfig3='''
// //'''
// // var wbConfig='${wbConfig1}${wbConfig2}${wbConfig3}'
var wbConfig='${wb}${wbConfig2}'

resource azmonworkbook1 'Microsoft.Insights/workbooks@2021-08-01' = {
  location: location
  kind: 'shared'
  name: guid(wbName)
  properties:{
    displayName: wbDisplayName
    serializedData: wbConfig
    category: 'Azure Monitor Workbooks'
    sourceId: wsId
  }
}

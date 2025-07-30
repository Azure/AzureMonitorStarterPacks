param Tags object
param location string
param lawresourceid string

var wbConfig=string(loadJsonContent('./extendedwb.json'))

resource workbook 'Microsoft.Insights/workbooks@2023-06-01' = {
  location: location
  tags: Tags
  kind: 'shared'
  name: guid('Azure Monitor Starter Packs V2')
  properties:{
    displayName: 'Azure Monitor Starter Packs Extended'
    serializedData: wbConfig
    category: 'workbook'
    sourceId: lawresourceid
    
  }
}

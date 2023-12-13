param Tags object
param location string
param lawresourceid string

var wbConfig = loadTextContent('./workbook.json')

resource workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  location: location
  tags: Tags
  kind: 'shared'
  name: 'Azure Monitor Starter Packs'
  properties:{
    displayName: 'Azure Monitor Starter Packs'
    serializedData: wbConfig
    category: 'workbook'
    sourceId: lawresourceid
  }
}

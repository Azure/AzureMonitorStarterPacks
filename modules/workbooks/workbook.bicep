param LAWResourceId string
param location string

var wbConfig1 ='''

'''
var wbConfig='${wbConfig1}${wbConfig2}${wbConfig3}'

resource Workbook 'Microsoft.Insights/workbooks@2022-04-01' = {
  location: location
  kind: 'shared'
  name: guid('ftamonitoring')
  properties:{
    displayName: 'TBD'
    serializedData: wbConfig
    category: 'ftamonpack'
    sourceId: LAWResourceId
  }
}

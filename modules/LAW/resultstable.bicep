param parentname string
param tableName string
param retentionDays int = 31

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: parentname
}

resource featuresTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  name: tableName
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: tableName
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'Tag'
                type: 'string'
            }
            {
                name: 'ResourceId'
                type: 'string'
            }
            {
                name: 'OS'
                type: 'string'
            }
            {
                name: 'Location'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

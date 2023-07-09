param parentname string
param tableNamePrefix string
param retentionDays int = 31

resource law 'Microsoft.OperationalInsights/workspaces@2022-10-01' existing =  {
  name: parentname
}

resource featuresTable 'Microsoft.OperationalInsights/workspaces/tables@2022-10-01' = {
  name: '${tableNamePrefix}_CL'
  parent: law
  properties: {
    totalRetentionInDays: retentionDays
    plan: 'Analytics'
    schema: {
        name: '${tableNamePrefix}_CL'
        columns: [
            {
                name: 'TimeGenerated'
                type: 'datetime'
            }
            {
                name: 'RawData'
                type: 'string'
            }
        ]
    }
    retentionInDays: retentionDays
  }  
}

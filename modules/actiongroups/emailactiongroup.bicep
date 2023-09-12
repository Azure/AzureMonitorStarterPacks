param actiongroupname string
param location string
param groupshortname string
param emailreceivers array 
param emailreiceversemails array
param solutionTag string

resource ag 'Microsoft.Insights/actionGroups@2023-01-01' = {
    name: actiongroupname
    location: location
    tags: {
      '${solutionTag}': 'AG'
    }
    properties: {
        groupShortName: groupshortname
        enabled: true
        emailReceivers: [ for i in range(0,length(emailreceivers)): {
          name: emailreceivers[i]
          emailAddress: emailreiceversemails[i]
          useCommonAlertSchema: false
        }]
      }
}
output agGroupId string = ag.id

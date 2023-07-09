param actiongroupname string
param location string = 'global'
param groupshortname string
param emailreceivers array 
param emailreiceversemails array

resource ag 'Microsoft.Insights/actionGroups@2022-06-01' = {
    name: actiongroupname
    location: location
    tags: {
      MonitorStarterPacks: 'AG'
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

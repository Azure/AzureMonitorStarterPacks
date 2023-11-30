param actiongroupname string
param location string
param groupshortname string
param emailreceiver string
param emailreiceversemail string
param solutionTag string

resource ag 'Microsoft.Insights/actionGroups@2023-01-01' = {
    name: 'New-AG'
    location: location
    tags: {
      '${solutionTag}': 'AG'
    }
    properties: {
        groupShortName: groupshortname
        enabled: true
        emailReceivers: [ 
          {
          name: emailreceiver
          emailAddress: emailreiceversemail
          useCommonAlertSchema: false
        }
      ]
      }
}
output agGroupId string = ag.id

param location string
param groupshortname string
param emailreceiver string
param emailreiceversemail string
param Tags object

resource ag 'Microsoft.Insights/actionGroups@2023-01-01' = {
    name: 'New-AG'
    location: location
    tags: Tags
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

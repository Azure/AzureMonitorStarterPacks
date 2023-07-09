// Action Group to be created
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
var deploymentName = 'ag-${uniqueString(resourceGroup().id)}'

module ag 'emailactiongroup.bicep' = if (!useExistingAG) {
  name: deploymentName
  params: {
    actiongroupname: actionGroupName
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    groupshortname: actionGroupName
    location: 'global'
    //location: location defailt is global
  }
}
//existing action group

resource age 'Microsoft.Insights/actionGroups@2018-09-01-preview' existing = if (useExistingAG) {
  name: actionGroupName
  scope: resourceGroup(existingAGRG)
}
output actionGroupResourceId string = useExistingAG ? age.id : ag.outputs.agGroupId

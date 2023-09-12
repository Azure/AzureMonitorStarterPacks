targetScope = 'managementGroup'
// Action Group to be created
param subscriptionId string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array = []
param useExistingAG bool 
param existingAGRG string = ''
param newRGresourceGroup string = ''
param solutionTag string
param location string
var deploymentName = 'ag-test'
//new action group
module ag 'emailactiongroup.bicep' = if (!useExistingAG) {
  name: deploymentName
  scope: resourceGroup(subscriptionId, newRGresourceGroup)
  params: {
    actiongroupname: actionGroupName
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    groupshortname: actionGroupName
    location: 'global'
    solutionTag: solutionTag
  }
}
//existing action group
resource age 'Microsoft.Insights/actionGroups@2023-01-01' existing = if (useExistingAG) {
  name: actionGroupName
  scope: resourceGroup(subscriptionId, existingAGRG)
}
output actionGroupResourceId string = useExistingAG ? age.id : ag.outputs.agGroupId

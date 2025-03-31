targetScope = 'managementGroup'
// Action Group to be created
param subscriptionId string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceiver string = ''
param emailreiceversemail string = ''
param useExistingAG bool 
param existingAGRG string = ''
param newRGresourceGroup string = ''
param solutionTag string
param Tags object
param location string

//new action group
module ag 'emailactiongroup.bicep' = if (!useExistingAG) {
  name: 'ag-new-${actionGroupName}-${location}'
  scope: resourceGroup(subscriptionId, newRGresourceGroup)
  params: {
    actiongroupname: actionGroupName
    emailreceiver: emailreceiver
    emailreiceversemail: emailreiceversemail
    groupshortname: actionGroupName
    location: 'global'
    solutionTag: solutionTag
    Tags: Tags
  }
}
//existing action group
resource age 'Microsoft.Insights/actionGroups@2023-01-01' existing = if (useExistingAG) {
  name: actionGroupName
  scope: resourceGroup(subscriptionId, existingAGRG)
}
output actionGroupResourceId string = useExistingAG ? age.id : ag.outputs.agGroupId

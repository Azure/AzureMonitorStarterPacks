//param vmnames array
param vmIDs array
param rulename string
param agname string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool 
var location = resourceGroup().location

module ag '../modules/actiongroups/emailactiongroup.bicep' = if (!useExistingAG) {
  name: agname
  params: {
    actiongroupname: agname
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    groupshortname: agname
    location: 'Global'
    solutionTag: 'vmmon'
  }
}
resource age 'Microsoft.Insights/actionGroups@2018-09-01-preview' existing = if (useExistingAG) {
  name: agname
  //scope: subscription()
  
}

module vmmon1 '../modules/diagnosticssettings/vmbasic/vmwithalertsbasic.bicep' = {
  name: '${rulename}-vmmonperf'
  params: {
    //vmResourceIds: resourceId(vmsrgs[i], 'Microsoft.Compute/virtualMachines', vmname)
    vmResourceIds: vmIDs
    rulename: rulename
    actiongroupid: (useExistingAG ? age.id : ag.outputs.agGroupId)
    location: location
  }
}

module vmmon2 '../modules/diagnosticssettings/vmbasic/vmwithalertsNetwork.bicep' = [ for (vmID,i)  in vmIDs: {
  name: '${rulename}-${i}-vmmonnetwork'
  params: {
    //vmResourceIds: resourceId(vmsrgs[i], 'Microsoft.Compute/virtualMachines', vmname)
    vmResourceIds: [
      vmID
    ]
    rulename: '${rulename}-${split(vmID, '/')[8]}'
    actiongroupid: (useExistingAG ? age.id : ag.outputs.agGroupId)
    location: location
  }
}]

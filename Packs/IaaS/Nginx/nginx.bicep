param rulename string
param actionGroupName string
//param location string= resourceGroup().location
param emailreceivers array = []
param emailreiceversemails array  = []
param useExistingAG bool = false
param existingAGRG string = ''
//param enableBasicVMPlatformAlerts bool = false
param location string = resourceGroup().location
param workspaceId string
param workspaceFriendlyName string
//param osTarget string
param packtag string
param solutionTag string
param solutionVersion string

var facilityNames = [
  'daemon'
]
var logLevels =[
  'Debug'
  'Info'
  'Notice'
  'Warning'
  'Error'
  'Critical'
  'Alert'
  'Emergency'
]

// Action Group
module ag '../../../modules/actiongroups/ag.bicep' =  {
  name: actionGroupName
  params: {
    actionGroupName: actionGroupName
    existingAGRG: existingAGRG
    emailreceivers: emailreceivers
    emailreiceversemails: emailreiceversemails
    useExistingAG: useExistingAG
    solutionTag: solutionTag
    //location: location defailt is global
  }
}

module dataCollectionEndpoint '../../../modules/DCRs/dataCollectionEndpoint.bicep' = {
 name: 'dataCollectionEndpoint-${solutionTag}'
 params: {
   location: location
   packtag: packtag
   solutionTag: solutionTag
   dceName: 'dataCollectionEndpoint-${solutionTag}'
 }
}

module fileCollectionRule '../../../modules/DCRs/filecollectionSyslogLinux.bicep' = {
  name: 'filecollectionrule-${packtag}'
  dependsOn: [
    dataCollectionEndpoint
  ]
  params: {
    location: location
    endpointResourceId: dataCollectionEndpoint.outputs.dceId
    packtag: packtag
    solutionTag: solutionTag
    ruleName: rulename
    filepatterns: [
      '/var/log/nginx/access.log'
    //'/var/log/nginx/error.log'
    ]
    lawResourceId:workspaceId
    tableName: 'NginxLogs'
    facilityNames: facilityNames
    logLevels: logLevels
    syslogDataSourceName: 'NginxLogs-1238219'
  }
}
module Alerts './nginxalerts.bicep' = {
  name: 'Alerts-${packtag}'
  params: {
    location: location
    workspaceId: workspaceId
    AGId: ag.outputs.actionGroupResourceId
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    
  }
}
module policysetup '../../../modules/policies/subscription/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: fileCollectionRule.outputs.ruleId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
  }
}

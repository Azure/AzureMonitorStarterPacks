param enableAMApolicies bool = true
param amaPoliciesScope string
param deployWorkspace bool
param workspaceName string = ''
param workspaceSku string = 'PerGB2018'
param workspaceRetentionDays int = 30

param location // string = resourceGroup().location
param actionGroupName string
//var nsgconfig = loadJsonContent('./Packs/packs.json')
var packs = [
  {
    PackName: 'AzMon-Packs-Windows-VM-Monitoring'
    RuleName: 'AzMonPacks-Basic_VM_Monitoring_WindowsServer'
    ModuleType: 'IaaS'
    Status: 'Enabled'
    RequiredTag : 'OS'
    osTarget : 'Windows'
    DiscoveryType: 'OS'
    RoleName : 'N/A'
    RequireParameters : 'true'
    TemplateLocation : './Packs/IaaS/VMBasic/WinVMMonitoring.bicep'
    moduleParameters: [
      {
        Name: 'insightsRuleName'
        Value: ''
      }
      {
        Name: 'enableInsightsAlerts'
        Value: 'null'
      }
      {
        Name: 'insightsRuleRg'
        Value: ''
      }
    ]     
  }
]
// AMA policies module
// How to determine scope
module amaPolicies './modules/ama/ama.bicep' ={
  name: 'amaPolicies'
  params: {
    location: location
  }
}
// Workspace module
module workspace './modules/workspace/law1.bicep' = {
  name: 'workspace'
  params: {
    location: location
    workspaceName: workspaceName
    workspaceSku: workspaceSku
    workspaceRetentionDays: workspaceRetentionDays
    createWorkspace: deployWorkspace
  }
}
// Packs
// Can we determine automatically which packs are available to be deployed?

module WinVMOSPack './Packs/IaaS/VMBasic/WinVMMonitoring.bicep' = {
  name: 'WinVMMonitoring'
  params: {
    location: location
    actionGroupName: actionGroupName
    osTarget: 'Windows'
    rulename: 'AzMonPacks-Basic_VM_Monitoring_WindowsServer'
    workspaceFriendlyName: workspace.outputs.workspaceFriendlyName
    workspaceId: workspace.outputs.workspaceId
    

  }
}

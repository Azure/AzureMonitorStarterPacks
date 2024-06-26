targetScope = 'managementGroup'

// @description('Name of the Action Group to be used or created.')
// param actionGroupName string = ''
// @description('Email receiver names to be used for the Action Group if being created.')
// param emailreceivers array = []
// @description('Email addresses to be used for the Action Group if being created.')
// param emailreiceversemails array = []
// @description('If set to true, a new Action group will be created')
// param useExistingAG bool
// @description('Name of the existing resource group to be used for the Action Group if existing.')
// param existingAGRG string = ''
param actionGroupResourceId string
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string
param solutionVersion string
// @description('Full resource ID of the data collection endpoint to be used for the deployment.')
// param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string
//param grafanaName string
param customerTags object 
param instanceName string

module KVAlerts './KeyVault/monitoring.bicep' = {
  name: 'KVAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packtag: 'KeyVault'
    // grafanaName: grafanaName
    // dceId: dceId
    // customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
  }
}
module vWan './Network/vWan/monitoring.bicep' = {
  name: 'vWanAlerts-${instanceName}-${location}'
  params: {
    actionGroupResourceId: actionGroupResourceId
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    packtag: 'vWan'
    solutionVersion: solutionVersion
    customerTags: customerTags
    instanceName: instanceName
  }
}
module LoadBalancers './Network/LoadBalancers/monitoring.bicep' = {
  name: 'LoadBalancersAlerts-${instanceName}-${location}'
  params: {
    actionGroupResourceId: actionGroupResourceId
    assignmentLevel: assignmentLevel
    location: location
    mgname: mgname
    resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packtag: 'ALB'
    solutionVersion: solutionVersion
    //dceId: dceId
    //grafanaName: grafanaName
    customerTags: customerTags
    instanceName: instanceName
  }
}
module AA './AA/alerts.bicep' = {
  name: 'AA-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'AA'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Automation/automationAccounts'
  }
}
module AppGW './Network/AppGW/alerts.bicep' = {
  name: 'AppGWAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'AppGW'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/applicationGateways'
  }
}
module AzFW './Network/AzFW/alerts.bicep' = {
  name: 'AzFWAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'AzFW'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/azureFirewalls'
  }
}
module AzFD './Network/AzFD/alerts.bicep' = {
  name: 'AzFDAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'AzFD'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/frontdoors'
  }
}
module PrivZones './Network/PrivZones/alerts.bicep' = {
  name: 'PrivZonesAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'PrivZones'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/privateDnsZones'
  }
}
module PIP './Network/PIP/alerts.bicep' = {
  name: 'PIPAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'PIP'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/publicIPAddresses'
  }
}

module NSG './Network/NSG/alerts.bicep' = {
  name: 'NSGAlerts-${instanceName}-${location}'
  params: {
    assignmentLevel: assignmentLevel
    //location: location
    mgname: mgname
    //resourceGroupId: resourceGroupId
    solutionTag: solutionTag
    subscriptionId: subscriptionId
    //actionGroupResourceId: actionGroupResourceId
    userManagedIdentityResourceId: userManagedIdentityResourceId
    //workspaceId: workspaceId
    packTag: 'NSG'
    //grafanaName: grafanaName
    //dceId: dceId
    //customerTags: customerTags
    instanceName: instanceName
    solutionVersion: solutionVersion
    AGId: actionGroupResourceId
    policyLocation: location
    parResourceGroupName: resourceGroupId
    resourceType: 'Microsoft.Network/networkSecurityGroups'
  }
}

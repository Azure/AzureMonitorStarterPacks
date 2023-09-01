

param grafanaName string
param location string
param solutionTag string
param solutionVersion string
param userObjectId string
param utcValue string = utcNow()
param lawresourceId string

//var lawName = split(lawresourceId, '/')[8]
var lawResourceGroup = split(lawresourceId, '/')[4]

var GrafanaAdminRoleId = '22926164-76b3-42b3-bc55-97df8dab3e41' // Grafana Admin. Need to add to current user.
var ReaderRoleId = 'acdd72a7-3385-48ef-bd42-f606fba81ae7' // Reader
var LogAnalyticsContribuorRoleId ='92aaf0da-9dab-42b6-94a3-d43ce8d16293' // Log Analytics Contributor
var MonitoringContributorRoleId = '749f88d5-cbae-40b8-bcfc-e573ddc772fa' // Monitoring Contributor

resource AzureManagedGrafana 'Microsoft.Dashboard/grafana@2022-08-01' = {
  name: grafanaName
  tags: {
    '${solutionTag}': 'storageaccount'
    '${solutionTag}-Version': solutionVersion
  }
  sku: {
    name: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: location
}

resource amgAdminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id,grafanaName,GrafanaAdminRoleId)
  scope: AzureManagedGrafana
  properties: {
    description: '${solutionTag}-GrafanaAdmin-${userObjectId}-${utcValue}'
    principalId: userObjectId
    principalType: 'User'
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', GrafanaAdminRoleId)
  }
}

module grafanaReadPermissions '../../../../modules/rbac/subscription/roleassignment.bicep' = {
  name: 'grafanaReadPermissions'
  scope: subscription()
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: ReaderRoleId
    roleShortName: 'Reader'
    solutionTag: solutionTag
  }
}
module grafanaLAWPermissions '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = {
  name: 'grafanaLAWPermissions'
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: LogAnalyticsContribuorRoleId
    roleShortName: 'Log Analytics Contributor'
    solutionTag: solutionTag
  }
}
module grafanaMonitorPermissions '../../../../modules/rbac/resourceGroup/roleassignment.bicep' = {
  name: 'grafanaMonitorPermissions'
  params: {
    principalId: AzureManagedGrafana.identity.principalId
    resourcename: grafanaName
    roleDefinitionId: MonitoringContributorRoleId
    roleShortName: 'Monitor Contributor Role'
    solutionTag: solutionTag
  }
}

output grafanaId string = AzureManagedGrafana.id

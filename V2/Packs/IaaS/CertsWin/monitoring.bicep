targetScope = 'managementGroup'

@description('Name of the DCR rule to be created')

param packtag string = 'CrtW'
@description('location for the deployment.')
param location string //= resourceGroup().location
@description('Full resource ID of the log analytics workspace to be used for the deployment.')
param workspaceId string
param solutionTag string = 'MonitorStarterPacks'
param solutionVersion string 
@description('Full resource ID of the data collection endpoint to be used for the deployment.')
param dceId string
@description('Full resource ID of the user managed identity to be used for the deployment')
param userManagedIdentityResourceId string
param mgname string // this the last part of the management group id
param subscriptionId string
param resourceGroupId string
param assignmentLevel string
param instanceName string

var rulename = 'AMP-${instanceName}-${packtag}'
param customerTags object
var tempTags ={
  '${solutionTag}': packtag
  MonitoringPackType: 'IaaS'
  solutionVersion: solutionVersion
}
// if the customer has provided tags, then use them, otherwise use the default tags
var Tags = (customerTags=={}) ? tempTags : union(tempTags,customerTags.All)
var workspaceFriendlyName = split(workspaceId, '/')[8]
var resourceGroupName = split(resourceGroupId, '/')[4]
var kind= 'Windows'

param storageAccountname string
param imageGalleryName string
param tableName string
param tags object

//var workspaceFriendlyName = split(workspaceId, '/')[8]
var ruleshortname = '${packtag}-collection'
var appName = '${packtag}-collection'
var appDescription = '${packtag} Collection - ${instanceName}'
var OS = 'Windows'

var xPathQueries=[
  'Directory Service!*[System[(Eventlevel=1)]]'
  'DNS Server!*[System[(Eventlevel=1)]]'
  'Active Directory Web Services!*[System[(Eventlevel=1)]]'
  'DFS Replication!*[System[(Eventlevel=1)]]'
]
// The performance counters define which counters are collected
var performanceCounters=[
  '\\Memory()\\Available Bytes'
  '\\Memory()\\Committed Bytes'
  '\\DirectoryServices(NTDS)\\DS Search sub-operations/sec'
  '\\Security System-Wide Statistics()\\KDC AS Requests'
  '\\Security System-Wide Statistics()\\KDC TGS Requests'
  '\\Security System-Wide Statistics()\\Kerberos Authentications'
  '\\DirectoryServices(NTDS)\\LDAP Client Sessions'
  '\\DirectoryServices(NTDS)\\LDAP Searches/sec'
  '\\DirectoryServices(NTDS)\\LDAP UDP operations/sec'
  '\\DirectoryServices(NTDS)\\LDAP Writes/sec'
  '\\Process(LSASS)\\Handle Count'
  '\\Process(LSASS)\\Private Bytes'
  '\\Process(LSASS)\\% Processor Time'
  '\\Security System-Wide Statistics()\\NTLM Authentications'
  '\\Memory()\\Pages/sec'
  '\\Processor(_Total)\\% Processor Time'
  '\\Server()\\Server Sessions'
  '\\System()\\System Up Time'
  '\\TCPv4()\\Connections Established'
  '\\TCPv6()\\Connections Established'
  '\\DirectoryServices(NTDS)\\DRA Inbound Bytes Compressed (Between Sites, Before Compression)/sec'
  '\\DirectoryServices(NTDS)\\DRA Inbound Bytes Compressed (Between Sites, After Compression)/sec'
  '\\DirectoryServices(NTDS)\\DRA Inbound Bytes Not Compressed (Within Site)/sec'
  '\\DirectoryServices(NTDS)\\DRA Inbound Bytes Total/sec'
  '\\DirectoryServices(NTDS)\\DRA Outbound Bytes Compressed (Between Sites, After Compression)/sec'
  '\\DirectoryServices(NTDS)\\DRA Outbound Bytes Compressed (Between Sites, Before Compression)/sec'
  '\\DirectoryServices(NTDS)\\DRA Outbound Bytes Not Compressed (Within Site)/sec'
  '\\DirectoryServices(NTDS)\\DRA Outbound Bytes Total/sec'
  '\\Process(dns)\\% Processor Time'
  '\\DNS()\\Total Query Received/sec'
  '\\Process(dns)\\Private Bytes'
  '\\DirectoryServices(NTDS)\\ATQ Outstanding Queued Requests'
  '\\DirectoryServices(NTDS)\\ATQ Request Latency'
  '\\DirectoryServices(NTDS)\\ATQ Threads Other'
  '\\DirectoryServices(NTDS)\\ATQ Threads LDAP'
  '\\DirectoryServices(NTDS)\\ATQ Threads Total'
]

// DCR - the module below ingests the performance counters and the XPath queries and creates the DCR
module dcrbasicvmMonitoring '../../../modules/DCRs/dcr-basicWinVM.bicep' = {
  name: 'dcrPerformance-${packtag}'
  scope: resourceGroup(subscriptionId, resourceGroupName)
  params: {
    location: location
    rulename: rulename
    workspaceId: workspaceId
    wsfriendlyname: workspaceFriendlyName
    kind: kind
    xPathQueries: xPathQueries
    counterSpecifiers: performanceCounters
    Tags: Tags
    dceId: dceId
  }
}

module policysetupDCR '../../../modules/policies/mg/policies.bicep' = {
  name: 'policysetup-${packtag}'
  params: {
    dcrId: dcrbasicvmMonitoring.outputs.dcrId
    packtag: packtag
    solutionTag: solutionTag
    rulename: rulename
    location: location
    userManagedIdentityResourceId: userManagedIdentityResourceId
    mgname: mgname
    ruleshortname: '${ruleshortname}-1'
    assignmentLevel: assignmentLevel
    subscriptionId: subscriptionId
    instanceName: instanceName
  }
}

module client './client.bicep' = {
   name: 'client-${instanceName}-${packtag}'
   params: {
    assignmentLevel: assignmentLevel
    dceId: dceId
    instanceName: instanceName
    location: location
    imageGalleryName: imageGalleryName
    mgname: mgname
    resourceGroupId: resourceGroupId
    storageAccountname: storageAccountname
    subscriptionId: subscriptionId
    tableName: tableName //no _CL suffix
    tags: tags
    userManagedIdentityResourceId: userManagedIdentityResourceId
    workspaceId: workspaceId
    packtag: packtag
    solutionTag: solutionTag
    appDescription: appDescription
    appName: appName
    OS: OS
    ruleshortname: ruleshortname
   }
}


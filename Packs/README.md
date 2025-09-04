# Packs documentation

## IaaS Packs

### Purpose and definition
IaaS packs are focused in monitoring workloads running in Virtual Machines and Arc Servers. They can monitor the following items:
- Events (event viewer)
- Performance Counters (Perfmon)
- Files
- Custom Data (only available for Virtuam machines)
- Syslog
- IIS Logs

### How they work

A packs definition is configured during the setup and stored in the storage account. The definition can be updated by adding json definitions in the interface or by editing the file directly. The file is located in the storage account, under the amba container `(packsdef.json)`

### Available Packs
The available IaaS Packs are:
# Monitoring Pack Summary

This document summarizes the monitoring packs defined in `PacksDef.json`.

| Name                          | Tag        | Target OS | Description                                |
| :---------------------------- | :--------- | :-------- | :----------------------------------------- |
| Windows Failover Cluster 2016 | WSFC2016   | Windows   | Windows Failover Cluster 2016              |
| Azure Monitor VM Insights     | VMI        | All       | Azure Monitor VM Insights                  |
| IIS 2012                      | IIS        | Windows   | IIS 2012 Mangement Pack                    |
| Print Server 2016             | PS2016     | Windows   | Print server 2016 monitoring pack.         |
| DNS Server 2016               | DNS2016    | Windows   | DNS Server 2016 monitoring pack.           |
| Nginx                         | nginx      | Linux     | Nginx monitoring pack.                     |
| ADDS                          | ADDS       | Windows   | Active Directory monitoring pack.          |
| SvcMap                        | SvcMap     | Windows   | Service Map monitoring pack. DCR only      |


## Services Packs

The services packs are fully based on alerts and thresholds available with in the AMBA (aka.ms/amba) project.

A quick summary:

<!-- ...existing code... -->
## Services Packs

The services packs are fully based on alerts and thresholds available with in the AMBA (aka.ms/amba) project.

A quick summary:

# Azure Monitor Baseline Alerts (AMBA) Catalog Summary

This document summarizes the alert definitions available in the `amba-alerts.json` catalog, categorized by Azure service and resource type.

| Service Category        | Resource Type               |
| :---------------------- | :-------------------------- |
| DBforPostgreSQL         | *(No specific types listed)*|
| Sql                     | *(No specific types listed)*|
| KeyVault                | *(No specific types listed)*|
| HealthcareApis          | services                    |
| ContainerInstance       | *(No specific types listed)*|
| DesktopVirtualization   | hostPools                   |
| Batch                   | batchAccounts               |
| ContainerService        | managedClusters             |
| Resources               | subscriptions               |
| RecoveryServices        | vaults                      |
| EventHub                | namespaces                  |
| EventHub                | clusters                    |
| Network                 | azureFirewalls              |
| Network                 | natGateways                 |
| Network                 | virtualNetworks             |
| Network                 | expressRoutePorts           |
| Network                 | vpnGateways                 |
| Network                 | frontDoors                  |
| Network                 | bastionHosts                |
| Network                 | loadBalancers               |
| Network                 | connections                 |
| Network                 | expressRouteCircuits        |
| Network                 | virtualNetworkGateways      |
| Network                 | networkSecurityGroups       |
| Network                 | routeTables                 |
| Network                 | trafficmanagerprofiles      |
| Network                 | expressRouteGateways        |
| Network                 | privateDnsZones             |
| Network                 | applicationGateways         |
| Network                 | publicIPAddresses           |
| Network                 | dnszones                    |
| Network                 | networkWatchers             |
| Compute                 | cloudServices               |
| Compute                 | virtualMachines             |
| Compute                 | virtualMachineScaleSets     |
| Media                   | mediaservices               |
| AVS                     | privateClouds               |
| Relay                   | namespaces                  |
| StorageCache            | AmlFilesystems              |
| AppConfiguration        | configurationStores         |
| Devices                 | IotHubs                     |
| Synapse                 | workspaces                  |
| Synapse                 | sqlPools                    |
| DBforMySQL              | flexibleServers             |
| DBforMySQL              | servers                     |
| ServiceBus              | namespaces                  |
| CognitiveServices       | accounts                    |
| Logic                   | workflows                   |
| StorageSync             | storageSyncServices         |
| Search                  | searchServices              |
| EventGrid               | domains                     |
| EventGrid               | topics                      |
| EventGrid               | systemTopics                |
| DataFactory             | factories                   |
| Web                     | serverFarms                 |
| Web                     | hostingEnvironments         |
| Web                     | sites                       |
| Web                     | slots                       |

**Note:** Some service categories might not have specific resource types listed.


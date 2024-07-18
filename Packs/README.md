# Packs documentation

The recommended experience to deploy the packs is by using the provided interface. You can also use ARM and Bicep Templates. See section below.

To deploy only packs, click the icon below. The solution must have been deployed before in order to deploy the packs.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FAllPacks.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

## Details about the packs

The packs are divided into three categories: IaaS, PaaS and Platform. Each pack contains a set of rules and alerts that are deployed to the Log Analytics workspace. The packs also contain Grafana dashboards that are deployed to the Grafana environment.

- [IaaS Packs](#iaas-packs): These packs are designed to monitor VMs and other IaaS resources. They are based on the AMA agent.
- [Services Packs](#services-packs): These packs are designed to monitor Azure native services.

## IaaS Packs

The IaaS packs implement monitoring based on the AMA agent. Some packs, like the ADDS pack require the VM Application 'client' to be installed. The client is installed by default in the VMs once targetted by the solution.

### VM Insights (VMInsights)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/VMI/alerts.bicep)
- Grafana Dashboards (Windows and Linux)

### IIS (IIS)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 30 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS/monitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/IIS/alerts.bicep).

Note that only the first Virtual SMTP instance has data being collected.

### IIS 2016 (IIS2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.
It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS2016/monitoring.bicep)

It contains the alerts define in [this file](../Packs/IaaS/IIS2016/alerts.bicep).

### Nginx (Nginx) preview

This pack contains a single DCR rule that collect Nginx accesslog as well as syslog specific events. It uses the [/modules/DCRs/filecollectionSyslogLinux.bicep](/modules/DCRs/filecollectionSyslogLinux.bicep) bicep template.

It implements a single alert regarding nginx service being stopped.

### DNS 2016

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/DNS2016/monitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/DNS2016/alerts.bicep).

### PS 2016 (Print Server 2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

### ADDS (ADDS) - Active directory domain services

TBD

### WSFC (WSFC) - Windows Server Failover Cluster

TBD

## Services Packs

### Storage Account (Storage)

[Storage Account Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Storage/storageAccounts/)

### OpenAI (OpenAI)

TBD

### Azure SQL (SQL)

[SQL Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Sql/servers/)

### Azure SQL Managed Instance (SQLMI)

[SQLMI Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Sql/managedInstances/)

### Azure Web Apps (WebApps)

[Web Apps Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Web/sites/)

### Logic Apps (LogicApps)

[Logic Apps Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Logic/workflows/)

### AVD

[AVD Baseline Alerts](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/brownfield/alerts/readme.md)

### vWan (vWan)

## Azure Load balancer (ALB)

[Azure Load Balancer Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/loadBalancers/)

## Key Vault (KV)

[Key Vault Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/KeyVault/vaults/)

## Azure Firewall (AF)
[Firewall Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/azureFirewalls/)

## Azure Application Gateway (AGW)

[Application Gateway Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/applicationGateways/)

## Azure Front Door (AFD)

[Front Door Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/frontdoors/)

## Automation Account (AA)

[Automation Accounts Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Automation/automationAccounts/)

## Network Security Group (NSG)

[NSG Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/networkSecurityGroups/)

## Public IP (PIP)

[Public IP Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/publicIPAddresses/)

## DNS Private Zones (DNSPZ)
[DNS Private Zones Baseline Alerts](https://azure.github.io/azure-monitor-baseline-alerts/services/Network/privateDnsZones/)

# Using ARM and Bicep Templates.

Each pack is composed of a bicep template that contains the rules and alerts. There is an equivalente ARM template that can be used instead. The ARM template is generated from the bicep template. The ARM template is used by the interface to deploy the packs and, same as bicep template, it can be used to deploy the packs using Azure CLI or PowerShell, in a pipeline for example.

# Packs documentation

The recommended experience to deploy the packs is by using the provided interface. You can also use ARM and Bicep Templates. See section below.

To deploy only packs, click the icon below. The solution must have been deployed before in order to deploy the packs.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FFehseCorp%2FAzureMonitorStarterPacks%2FsvcMonitoring%2FPacks%2FAllPacks.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FFehseCorp%2FAzureMonitorStarterPacks%2FsvcMonitoring%2FPacks%2FCustomSetup%2Fsetup.json)

## IaaS Packs

The IaaS packs implement monitoring based on the AMA agent. Some packs, like the ADDS pack require the VM Application 'client' to be installed. The client is installed by default in the VMs once targetted by the solution.

## Active Directory Domain Services (ADDS)

### Windows OS (WinOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/WinOS/VMInsightsAlerts.bicep)
- Grafana Dashboard

### Linux OS (LxOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/LxOS/VMInsightsAlerts.bicep)
- Grafana Dashboard

### IIS (IIS)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 30 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS/WinIISMonitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/IIS/WinIISAlerts.bicep).

Note that only the first Virtual SMTP instance has data being collected.

### IIS 2016 (IIS2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.
It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS2016/WinIIS2016Monitoring.bicep)

It contains the alerts define in [this file](../Packs/IaaS/IIS2016/WinIIS2016Alerts.bicep).

### Nginx (Nginx) preview

This pack contains a single DCR rule that collect Nginx accesslog as well as syslog specific events. It uses the [/modules/DCRs/filecollectionSyslogLinux.bicep](/modules/DCRs/filecollectionSyslogLinux.bicep) bicep template.

It implements a single alert regarding nginx service being stopped.

### DNS 2016

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/DNS2016/WinDns2016Monitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/DNS2016/WinDns2016Alerts.bicep).

### PS 2016 (Print Server 2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

## PaaS Packs

### Storage Account (Storage)

### OpenAI (OpenAI)

## Platform Packs

### vWan (vWan)

## Azure Load balancer (ALB)

## Key Vault (KV)

# Using ARM and Bicep Templates.

Each pack is composed of a bicep template that contains the rules and alerts. There is an equivalente ARM template that can be used instead. The ARM template is generated from the bicep template. The ARM template is used by the interface to deploy the packs and, same as bicep template, it can be used to deploy the packs using Azure CLI or PowerShell, in a pipeline for example.

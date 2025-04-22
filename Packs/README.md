# Packs documentation

## Details about the packs

The packs are divided into three categories: IaaS, PaaS and Platform. Each pack contains a set of rules and alerts that are deployed to the Log Analytics workspace. The packs also contain Grafana dashboards that are deployed to the Grafana environment.

- [IaaS Packs](#iaas-packs): These packs are designed to monitor VMs and other IaaS resources. They are based on the AMA agent.
- [Services Packs](#paas-packs): These packs are designed to monitor any service other than Virtual machines, Arc Servers and VMSS resources. They are based on the Azure Monitor metrics and diagnostics settings (optional) and are deployed as per the definitions in the AMBA API.

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

Please refer to aka.ms/amba for a full reference of provided monitor configurations.

# Using ARM and Bicep Templates.

Each IaaS pack is composed of a bicep template that contains the rules and alerts. There is an equivalente ARM template that can be used instead. The ARM template is generated from the bicep template. The ARM template is used by the interface to deploy the packs and, same as bicep template, it can be used to deploy the packs using Azure CLI or PowerShell, in a pipeline for example.

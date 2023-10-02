# Packs documentation

## Windows OS (WinOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/WinOS/VMInsightsAlerts.bicep)
- Grafana Dashboard


## Linux OS (LxOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/LxOS/VMInsightsAlerts.bicep)
- Grafana Dashboard

## IIS (IIS)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 30 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS/WinIISMonitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/IIS/WinIISAlerts.bicep).

Note that only the first Virtual SMTP instance has data being collected.

## IIS 2016 (IIS2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.
It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS2016/WinIIS2016Monitoring.bicep)

It contains the alerts define in [this file](../Packs/IaaS/IIS2016/WinIIS2016Alerts.bicep).

[Deploy](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FFehseCorp%2FAzureMonitorStarterPacks%2Fdocsupdate%2FPacks%2FIaaS%2FIIS2016%2FWinIIS2016Monitoring.json)

## Nginx (Nginx) preview

This pack contains a single DCR rule that collect Nginx accesslog as well as syslog specific events. It uses the [/modules/DCRs/filecollectionSyslogLinux.bicep](/modules/DCRs/filecollectionSyslogLinux.bicep) bicep template.

It implements a single alert regarding nginx service being stopped.

## DNS 2016

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/DNS2016/WinDns2016Monitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/DNS2016/WinDns2016Alerts.bicep).


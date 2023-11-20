# Packs documentation

The recommended experience to deploy the packs is by using the provided interface. You can also use ARM and Bicep Templates. See section below.

To deploy all IaaS packs, click the icon below:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FAllIaaSPacks.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)
## Windows OS (WinOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/WinOS/VMInsightsAlerts.bicep)
- Grafana Dashboard

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FWinOS%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

## Linux OS (LxOS)

This pack leverage the VM Insights rules. It implements the following:
- VMInsights Rule (DCR)
- Alerts (6) - Memory, Disk, Heartbeat, CPU. See details [here](./IaaS/LxOS/VMInsightsAlerts.bicep)
- Grafana Dashboard

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FLxOS%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

## IIS (IIS)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 30 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS/WinIISMonitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/IIS/WinIISAlerts.bicep).

Note that only the first Virtual SMTP instance has data being collected.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FIIS%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)


## IIS 2016 (IIS2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.
It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/IIS2016/WinIIS2016Monitoring.bicep)

It contains the alerts define in [this file](../Packs/IaaS/IIS2016/WinIIS2016Alerts.bicep).

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FIIS2016%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

## Nginx (Nginx) preview

This pack contains a single DCR rule that collect Nginx accesslog as well as syslog specific events. It uses the [/modules/DCRs/filecollectionSyslogLinux.bicep](/modules/DCRs/filecollectionSyslogLinux.bicep) bicep template.

It implements a single alert regarding nginx service being stopped.

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FNginx%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)


## DNS 2016

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has around 50 event rule collection items. It also has the following performance counters being collected. See [this file](../Packs/IaaS/DNS2016/WinDns2016Monitoring.bicep) for the complete list.

It contains the alerts define in [this file](../Packs/IaaS/DNS2016/WinDns2016Alerts.bicep).
[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FDNS2016%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

## PS 2016 (Print Server 2016)

This pack uses the 'modules/DCRs/dcr-basicWinVM.bicep' bicep template to implement event collection and performance collection rules.

It has about 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#view/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FIaaS%2FS2016%2Fmonitoring.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2FAzureMonitorStarterPacks%2Fmain%2FPacks%2FCustomSetup%2Fsetup.json)

# Using ARM and Bicep Templates.

Each pack is composed of a bicep template that contains the rules and alerts. There is an equivalente ARM template that can be used instead. The ARM template is generated from the bicep template. The ARM template is used by the interface to deploy the packs and, same as bicep template, it can be used to deploy the packs using Azure CLI or PowerShell, in a pipeline for example.

# Azure Monitor Starter Packs Components

## Pre-requisites

- Azure Subscription - an azure subscription to deploy the components
- Log Analytics Workspace - a Log Analytics Workspace to send the data to. If not provided, a workspace will be requested. If required a new workspace can be created in the wizard.

## Agent Configuration

The agent install is done by assigning a custom initiative that will install the agent and configure it to send data to the provided workspace. During Setup, the initiative will be assigned to the subscription and all the VMs in the subscription will be targeted. The initiative will be assigned to new VMs as they are created. Remediation can be done after once the backend components are deployed (via workbook).

## Basic Solution Components (Backend)

The basic solution is composed of the following components:

## Azure Workbook

Central admin interface for the solution. The workbook is used to enable/disable packs and to manage the solution.
  
## Tabs

### Getting Started
  
![Welcome Screen](image-9.png)

### Status
  Used to review the status of the solution.
![Alt text](image-10.png)

### Servers 
  Used to enable or disable monitoring for one or more servers.
![Alt text](image-11.png)
When a server is selected, the list of available packs is offered:
![Alt text](image-12.png)

### Alert Setup
  Used to enable or disable alerts per monitoring pack, as well as to Configure the action group to the alerts.

![Alt text](image-13.png)
### Policy Management
  General policy status (initiatives and policies). This tab can also be used to assign or unassign policies to management groups or subscriptions.
![Alt text](image-14.png)
- Pack Status - Review installed packs and VMs associated with each pack.
![Alt text](image-15.png)
- Agent Info - Review agent status (installed or not).
![Alt text](image-16.png)

## Backend Components

### Azure Logic App - responsible for routing requests coming from the workbook to the proper function in the function app.
### Function app - resposible fore the following activities
    - Alert Management - enable/disable alerts
    - Policy Management - scan for compliance and remediate
    - Tag management - add/remove tags to/from VMs.
### Application Insights - used by the function app for logging and telemetry.
### Storage Account - supporting the function app.
### Log Analytics Workspace - supporting the data collection
### Azure Monitor Action Group - supporting the alerts
### Azure Managed Grafana

## Packs

Packs are in general composed of:

- Data Collection Rule(s) - responsible for collecting the data from the VMs
- Policies - responsible for assigning the DCRs to the VMs (based on tags)
- Alerts - responsible for alerting on the collected data
- Data Collection Endpoints - responsible for sending the data to the Log Analytics Workspace for specific packs that require file collection or syslog.
- Action Groups - although not part of the pack per se, the action group is required for notification. The action group can be created during setup and can be used for all packs or a different one can be used for each pack.


### AMA Policy Set (Initative)

The AMA Policy Set is an initiative that contains all the policies required for installing the Azure Monitor Agent. The initiative is assigned to the subscription or Management group during setup. The initiative contains the following Builtin policies:

![Alt text](image-17.png)

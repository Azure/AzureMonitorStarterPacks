# FastTrack for Azure - Monitoring Starter Packs (MonStar Packs)

## Objectives

- Minimize the initial ramp up required for customers, in multiple aspects of the Azure technologies to deploy basic monitoring.

- Minimize the need for the Customer tto determine the minimal monitoring items for a certain type of workload 

- Provide best practices out of the box on items that need monitoring for different workloads 

- Create a framework for collaboration that will make it easy to add new monitored technologies. 

For a detailed solution anatomy, please refer to [Solution Anatomy](./Docs/solution-anatomy.md)

## Pre-requisites and recommendations

- Azure Subscription - an Azure subscription to deploy the components
- **Recommended**: [Azure Cloud Shell](https://shell.azure.com) access to deploy the components. Azure Cloud Shell is recommended since most of the required are pre-installed. 
- Alternative: deploy from a local workstation with the following components installed:

    - PowerShell 7.1 or later
    - Azure Powershell Az module (v10 or later)
    - Bicep CLI (our Azure CLI, which will include  Bicep)
    - git

## Setup

### Download the Solution

1. Clone the repository to a local folder:

    `git clone https://github.com/Azure/AzureMonitorStarterPacks.git`

2. Change directory to the repository folder:

    `cd AzureMonitorStarterPacks`

3. Run ./setup.ps1 as per below instructions.

### Deploy the Solution

Setup can be separated in 3 steps:

1. AMA Policy Initiative Setup
2. Main Solution Setup (Workbook, Logic App, Function)
3. Monitoring Packs Setup

Setup has the following parameters:

| Parameter Name | Description | Default Value |
| --- | --- |  --- |
| solutionResourceGroup (Mandatory) | Monitor components resource Group. This is where DCRs and Log Analytics Workspace will be created. ||
| location (Mandatory) | Location for deployment. (i.e. eastus, uksouth, centralindia) | |
| grafanalocation (optional)| Location to deploy the Azure Grafana workspace. If not specified, the previous specific location will be used. | same as location |
| skipAMAPolicySetup | skips AMA policy setup. Default is false. | false |
| skipMainSolutionSetup | skips deployment of the main components (in case more packs are added later). Default is false. | false |
| skipPacksSetup | skips packs setup altogether. Default is false. | false |
| workspaceResourceId | Log Analytics workspace to send the data to. If not provided, a workspace will be requested. If required a new workspace can be created in the wizard. | |
| solutionTag | tag to be user for discovery. Default value: 'MonitorStarterPacks'. If any value is found in the tag, machines will be targeted for the basic VM Monitoring. The content of the tag is a comma separated list of applications that are installed on the machine (IIS, ADDS,etc.) | 'MonitorStarterPacks' |
| packsFilePath | path to local packs.json file. Default is the one in the repo. | "./Packs/packs.json" |
| useExistingAG | Use existing Action Group for notification. Default is false. If set to true, the following parameters are required: | false |
| confirmeeachpack | if specified, the setup procedure will ask for confirmation for each pack. | false|

New Action Group parameters (when useExistingAg is 'false'):
| Parameter Name | Description | Default Value |
| --- | --- |  --- |
| emailreceivers=@() | Array of email receiver names (not emails) | |
| emailreceiversEmails=@() | Array of email receiver emails (respectively to the previous array) | |
| subscriptionId | Subscription ID. Default is the one in the context. | _current context_ |
| useSameAGforAllPacks | Use the same Action Group for all packs. Default is false.  | false |

### Examples

**Minimal parameters:**

```powershell
.\setup.ps1 -solutionResourceGroup 'rg-xxxxxxx' -location 'eastus'
```

This example will deploy the enabled packs in the packs.json file to the resource group rg-xxxxxxx in the eastus location. It will deploy the basic solution and any enabled packs.

More examples of setup can be found [here](./Docs/setup-examples.md).

## Starter Packs

Review Packs documentation [here](./Packs/README.md).

## Authoring Guide

Click [here](./Docs/authoring.md) for guidance on how to create new packs.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

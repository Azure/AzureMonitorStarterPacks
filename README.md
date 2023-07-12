# FastTrack for Azure - Monitoring Starter Packs (MonStar Packs)

## Objectives

- Minimize the initial ramp up required for customers, in multiple aspects of the Azure technologies to deploy basic monitoring.

- Minimize the need for the Customer tto determine the minimal monitoring items for a certain type of workload 

- Provide best practices out of the box on items that need monitoring for different workloads 

- Create a framework for collaboration that will make it easy to add new monitored technologies. 

## Setup 
    Setup has the following parameters:
    $resourceGroup (Mandatory) - Monitor components resource Group. This is where DCRs and Log Analytics Workspace will be created.
    $skipAMAPolicySetup - skips AMA policy setup. Default is false.
    $skipMainSolutionSetup - skips deployment of the main components (in case more packs are added later). Default is false.
    $skipPacksSetup - skips packs setup altogether. Default is false.
    $workspaceResourceId - Log Analytics workspace to send the data to. If not provided, a workspace will be requested. If required a new workspace can be created in the wizard.
    $EnableTagName - tag to be user for discovery. Default value: 'MonitorStarterPacks. If any value is found in the tag, machines will be targeted for the basic VM Monitoring. The content of the tag is a comma separated list of applications that are installed on the machine (IIS, ADDS,etc.)
    $location - location for deployment. Default is 'eastus'
    $useExistingAG - Use existing Action Group for notification. Default is false. If set to true, the following parameters are required:
    $emailreceivers=@() - Array of email receiver names (not emails)
    $emailreceiversEmails=@() - Array of email receiver emails (respectively to the previous array)
    $subscriptionId - Subscription ID. Default is the one in the context.
    $useSameAGforAllPacks - Use the same Action Group for all packs. Default is false. 
    $packsFilePath="./Packs/packs.json" - path to local packs.json file. Default is the one in the repo.
    
### Examples

    Minimal parameters:
    .\setup.ps1 -resourceGroup 'rg-xxxxxxx' -location 'eastus'

    This example will deploy the enabled packs in the packs.json file to the resource group rg-xxxxxxx in the eastus location. It will deploy the basic solution and any enabled packs.
    The basic solution is composed of the following components:
    - Log Analytics Workspace (if not using existing)
    - Action Group (if not using existing)
    - Logic App (for management)
    - Function (for management)
    - Workbook (for management)
  - Packs
    - DCR(s), Alerts, policies and assignments (with remediation tasks), Grafana Dashboards.
    
## Starter Packs

### Basic Windows VM Monitoring (TBD)

### IIS VM Monitoring (Beta)

See details.

## Authoring Guide

Click here for guidance on how to create new packs.

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

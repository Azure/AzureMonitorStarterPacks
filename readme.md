# Azure FTA - Monitoring Starter Packs (MonStar Packs)

Objectives

Minimize the initial ramp up required for customers, in multiple aspects of the Azure technologies to deploy basic monitoring 

Minimize the need for the Customer tto determine the minimal monitoring items for a certain type of workload 

Provide best practices out of the box on items that need monitoring for different workloads 

Create a framework for collaboration that will make it easy to add new monitored technologies. 

## Setup 
    Setup has the following parameters:
    $workspaceResourceId (Mandatory) - Log Analytics workspace to send the data to.
    $resourceGroup (Mandatory) - Monitor components resource Group. This is where DCRs and Log Analytics Workspace will be created.
    $EnableTagName - tag to be user for discovery. Default value: 'AppList. If any value is found in the tag, machines will be targeted for the basic VM Monitoring. The content of the tag is a comma separated list of applications that are installed on the machine (IIS, ADDS,etc.)
    $location - location for deployment. Default is 'eastus'
    $useExistingAG - Use existing Action Group for notification. Default is false. If set to true, the following parameters are required:
    $emailreceivers=@() - Array of email receiver names (not emails)
    $emailreceiversEmails=@() - Array of email receiver emails (respectively to the previous array)
    $autoInstallAMA - Install Azure Monitor Agent. Default is false. If set to true, it won't ask for confirmation
    $useExistingDCR=$false - Use existing DCR. Default is false. If set to true, it won´t look for an existing DCR and will ask you to select a DCR from the list.
    $subscriptionId - Subscription ID. Default is the one in the context.
    $useSameAGforAllPacks - Use the same Action Group for all packs. Default is false. 
    $packsFilePath="./Packs/packs.json" - path to local packs.json file. Default is the one in the repo.
    
### Examples

    Basic VM Monitoring
    .\setup.ps1 -workspaceResourceId '/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/rg-xxxxxxx/providers/Microsoft.OperationalInsights/workspaces/xxxxxxx' -resourceGroup 'rg-xxxxxxx' -tagName 'AppList' -location 'eastus'

    This example will deploy the basic VM monitoring pack to all machines that have the tag 'AppList' in the resource group 'rg-xxxxxxx'. The data will be sent to the workspace 'xxxxxxx' in the resource group 'rg-xxxxxxx'. The deployment location is 'eastus'.
    
## Starter Packs

### Basic Windows VM Monitoring

### Basic Linux VM Monitoring

### IIS VM Monitoring

## Authoring Guide

Click here for guidance on how to create new packs.

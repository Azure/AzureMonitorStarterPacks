## Removing the solution

In order to remove the solution, you can run the following script in this [link](https://github.com/Azure/AzureMonitorStarterPacks/raw/main/setup/Cleanup/cleanup.ps1). The script will remove all the resources created by the solution.

- Open the Azure CLI with PowerShell to remove the whole solution.

```powershell
wget https://raw.githubusercontent.com/Azure/AzureMonitorStarterPacks/main/tools/cleanup.ps1
./cleanup.ps1 -RG <Resource Group Name> -RemoveAll
```

Alternatively, you can select to remove specific components of the solution by using the following parameters:

- RemovePacks : Removes all the packs deployed by the solution
- RemoveAMAPolicySet : Removes the policy set deployed by the solution
- RemoveMainSolution : Removes the main components of the deployed solution
- RemoveDiscovery : Removes the discovery deployed by the solution

Once completed, some resources will remain in the resource group. These resources are not removed by the script and need to be removed manually. The resources are:

- Storage Account
- Log Analytics Workspace
- Action Group(s)

Note: If the gallery is not removed in the first run, please run the command again.

Note: The Azure Managed Grafana environment requires about 10 minutes to be removed. Once finished, the resource group can be removed.

Note 2: To completeley remove the Log Analytics workspace, use the -ForceDelete parameter. This will remove the workspace and all the data in it (ignoring the retention period).

Example:

```powershell
remove-AzOperationalInsightsWorkspace -ResourceGroupName <Resource Group> -Name <Workspace name> -ForceDelete -force
```

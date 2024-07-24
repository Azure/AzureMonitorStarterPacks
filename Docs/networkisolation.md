# Network Isolation

The solution can work with network isolation. By default, the components are deployed with public endpoints. The following components can be isolated (click the links for details):
- [Log Analytics Workspace](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security) 
- [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/private-link-security)
- [Storage Account](https://docs.microsoft.com/en-us/azure/storage/common/storage-private-endpoints)
- [Azure Function](https://learn.microsoft.com/en-us/azure/azure-functions/functions-create-vnet) - The function will require a higher SKU in order to work with network isolation.
- [Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/general/private-link-service)
- [Azure Managed Grafana](https://learn.microsoft.com/en-us/azure/managed-grafana/how-to-set-up-private-access?tabs=azure-portal)

The Compute Gallery and the VM Application Gallery are not supported with network isolation. 
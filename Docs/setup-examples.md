Basic setup (minimal parameters):
.\setup.ps1 -resourceGroup 'rg-xxxxxxx' -location 'eastus'
This example will deploy the enabled packs in the packs.json file to the resource group rg-xxxxxxx in the eastus location. It will deploy the basic solution and any enabled packs. What will happen:

- If a subscription was not provided, a list of subscriptions will be presented and the user can select one of them.
- If the Resource Group does not exist, it will be created.
- A log analytics workspace will be created in the resource group or an existing one can be used. If the parameters was not provided, a list of existing workspaces will be presented and the user can select one of them or create a new one.
- When deploying the packs, if an action group was not provided, a new one can be created or an existing one can be used. If the parameters was not provided, a list of existing action groups will be presented and the user can select one of them or create a new one.
- If the usesameAGforallPacks parameter was not provided, the user will be asked which action group to use for each pack.

More examples:

Setup with existing workspace and action group:

`./setup.ps1 -useExistingAG -solutionresourceGroup rg-xxxxxxxx -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx -useSameAGforAllPacks -location eastus -workspaceResourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/rg-xxxxxxxx/providers/Microsoft.OperationalInsights/workspaces/ws-xxxxxxxx"`

Setup with existing workspace and action group and using the same action group for all packs:
  
`./setup.ps1 -useExistingAG -solutionresourceGroup rg-xxxxxxxx -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx -useSameAGforAllPacks -location eastus -workspaceResourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/rg-xxxxxxxx/providers/Microsoft.OperationalInsights/workspaces/ws-xxxxxxxx"`

Setup only the packs:

`./setup.ps1 -useExistingAG -solutionresourceGroup rg-xxxxxxxx -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx -useSameAGforAllPacks -location eastus -workspaceResourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/rg-xxxxxxxx/providers/Microsoft.OperationalInsights/workspaces/ws-xxxxxxxx" -skipAMAPolicySetup -skipMainSolutionSetup`

Setup only the AMA Policy Initiative:
  
`./setup.ps1 -useExistingAG -solutionresourceGroup rg-xxxxxxxx -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx -useSameAGforAllPacks -location eastus -workspaceResourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/rg-xxxxxxxx/providers/Microsoft.OperationalInsights/workspaces/ws-xxxxxxxx" -skipMainSolutionSetup -skipPacksSetup`

Setup only the main solution:

`./setup.ps1 -useExistingAG -solutionresourceGroup rg-xxxxxxxx -subscriptionId xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx -useSameAGforAllPacks -location eastus -workspaceResourceId "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxx/resourceGroups/rg-xxxxxxxx/providers/Microsoft.OperationalInsights/workspaces/ws-xxxxxxxx" -skipAMAPolicySetup -skipPacksSetup`
# Functions and operations

|Function | Description|
|---------|------------|
|[config](#config)| Provides information for the workbook|
|[agentMgmt](#agentmgmt)| used to managed agents (AMA)|
|[alertConfigMgmt](#alertconfigmgmt)| used to manage alert rules|
|[policyMgmt](#policymgmt)| used to manage policies|
|[policyCompliance](#policycompliance-timer-triggered)| used to check frequently and enforce compliance|
|[tagmgmt](#tagmgmt)| used to manage tags and install agents if needed|

## Config

|Action|Description|
|------|-----------|
|getTagbyService|returns a tag for each supported service|
|getAllServiceTags|returns tags for name services|
|getDiscoveryMappings|returns the specific tag based on application role name|
|getdiscoveryresults|return the discovered items|
|getPaaSquery|returns a specific ARG piece that represents the supported services.|
|getPlatformquery|deprecated|
|getNonMonitoredPaaS|Returns the list of supported PaaS resources that are not being monitored|
|getMonitoredPaaS|Returns the list of supported PaaS resources that are being monitored (tagged)|
|getSupportedServices|returns only the namespaces of the supported services|

## AgentMgmt

|Action|Description|Parameters|
|------|-----------|------|
|AddAgent|Installs AMA on a server| resourcelist|
|RemoveAgent|Removes AMA from a server|resourcelist|

## AlertConfigMgmt

|Action|Description|
|------|-----------|
|Enable|Enables an alert rule|
|Disable|Disables an alert rule|
|Update|Update|
|Delete|Deletes and alert rule|

## PolicyMgmt

|Action|Description|
|------|-----------|
|Remediate|Remediates a specific policy|
|Scan|Scan for compliance changes|
|Assign|Assigns a policy or policy set|
|Unassign|Unassings a policy or policy set|

## PolicyCompliance (Timer Triggered)

|Action|Description|
|------|-----------|
|N/A| This function is triggered by a timer and remediates the compliance of the policies|

## TagMgmt

|Action|Description|
|------|-----------|
|AddTag|Adds a tag to a resource. Additionally, it will install AMA if not present|
|RemoveTag|Removes a tag from a resource|

## Common Module

A common module is used to provide common functions to the other modules. The common module is used to provide the following functions:

|Action|Description|
|------|-----------|
|Install-azMonitorAgent|Effective installs the agent using the API. It also creates a System Managed Identity for the VM(s)|
|get-discovermappings|used internally to provide the mappings based on the config|
|Add-Agent|Install the agent|
|Add-Tag|Adds the tag to a resource (and configures AVD monitoring).|
|Remove-DCRa|Removes a DCR association|
|Remove-Tag|Removes a tag|
|get-alertApiVersion|gets the current API version to support other functions|
|Config-AVD|Configures the AVD monitoring|
|get-serviceTag||
|get-paasquery|returns the current paas ARG query for supported services|

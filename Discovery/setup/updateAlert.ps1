$subscriptionId="6c64f9ed-88d2-4598-8de6-7a9527dc16ca"
$resourceGroupName="amonstarterpacks3"
$rulename="AMSP-Lx-VMI-HeartbeatAlert"
$apiver="2018-04-16"
$getScheduledQueryRuleURL="https://management.azure.com/subscriptions/$subscriptionId/resourcegroups/{1}/providers/Microsoft.Insights/scheduledQueryRules/{0}?api-version=$apiver" -f $rulename,$resourceGroupName
$alertConfig=(Invoke-AzRestMethod -Method Get -Uri $getScheduledQueryRuleURL).Content | ConvertFrom-Json
$alertConfig.properties.enabled=$false
$alertproperties=$alertConfig.properties | ConvertTo-Json -Depth 100
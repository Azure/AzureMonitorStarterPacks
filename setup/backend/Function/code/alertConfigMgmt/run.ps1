using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$alerts = $Request.Body.Alerts
$action = $Request.Body.Action

#$TagValue = $Request.Body.Pack

if ($alerts) {
        #$TagName='MonitorStarterPacks'
    $TagName=$env:TagName
    if ([string]::isnullorempty($TagName)) {
        $TagName='MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    "Working on $($alerts.count) server(s). Action: $action. "
    switch ($action) {
        'Enable' {
            $bodyAction=@"
            {
                "properties": {
                  "enabled": "true"
                }
            }
"@
<#
{"id":"/subscriptions/6c64f9ed-88d2-4598-8de6-7a9527dc16ca/resourceGroups/Amonstarterpacks3/providers/microsoft.insights/activityLogAlerts/Deploy_activitylog_KeyVault_Delete","MP":"Keyvault","Enabled":true,"Description":"AMSP policy to Deploy Activity Log Key Vault Delete Alert","Action Group":"VMAdmins","location":"global","Target":"6c64f9ed-88d2-4598-8de6-7a9527dc16ca"}#>
            foreach ($alert in $alerts) {
                
                $alertinfo=$alert.id.split("/") #2 is subscription, 4 is resource group, 6 will be alert type, #8 is alert name
                "Running $action for $($alertinfo[8]) alert."
                $apiversion="2023-03-15-preview"
                if ($alertinfo[7] -eq 'activityLogAlerts') {
                    $apiversion="2020-10-01"
                }
                $patchURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.Insights/{3}/{2}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[8], $alertinfo[7]
                Invoke-AzRestMethod -Method PATCH -Uri $patchURL -Payload $bodyAction
            }
        }
        'Disable' {
            $bodyAction=@"
            {
                "properties": {
                  "enabled": "false"
                }
            }
"@
            foreach ($alert in $alerts) {
                $alertinfo=$alert.id.split("/") #2 is subscription, 4 is resource group, 6 will be alert type, #8 is alert name
                $apiversion="2023-03-15-preview"
                if ($alertinfo[7] -eq 'activityLogAlerts') {
                    $apiversion="2020-10-01"
                }
                "Running $action for $($alertinfo[8]) alert."
                $patchURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/Microsoft.Insights/{3}/{2}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[8],$alertinfo[7]
                Invoke-AzRestMethod -Method PATCH -Uri $patchURL -Payload $bodyAction
            }
        }
        'Update' {
            $actionGroupId = $Request.Body.aGroup.id
            # "Body:"
            # $Request.Body
            foreach ($alert in $alerts) {
                $alertinfo=$alert.id.split("/") #2 is subscription, 4 is resource group, 6 will be alert type, #8 is alert name
                $apiversion="2023-03-15-preview"
                if ($alertinfo[7] -eq 'activityLogAlerts') {
                    $apiversion="2020-10-01"
                }
                "Running $action for $($alertinfo[8]) alert. AG Id: $actionGroupId"
                switch ($alertinfo[7]) {
                    'activityLogAlerts' {
                        $apiversion="2020-10-01"
                        # have to first get the alert to get the current action group list
                        $getURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/{2}/{3}/{4}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[6], $alertinfo[7], $alertinfo[8]
                        $alertConfig=(Invoke-AzRestMethod -Method GET -Uri $getURL).Content | convertfrom-json
                        # then replace the action group list with the new one
                        $alertConfig.properties.actions.actionGroups[0].actionGroupId=$actionGroupId
                        # then PUT the new alert config.
                        $putURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/{2}/{3}/{4}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[6], $alertinfo[7], $alertinfo[8]
                        $bodyAction=$alertConfig | convertto-json -Depth 15
                        
                        Invoke-AzRestMethod -Method PUT -Uri $putURL -Payload $bodyAction
                    }
                    'metricAlerts' {
                        $apiversion="2018-03-01"
                        $patchURL="https://management.azure.com/subscriptions/{0}/resourcegroups/{1}/providers/{2}/{3}/{4}?api-version=$apiversion" -f $alertinfo[2],$alertinfo[4], $alertinfo[6], $alertinfo[7], $alertinfo[8]
                        $bodyAction=@"
                        {
                            "properties": {
                                "actions": [{
                                    "actionGroupId": "$actionGroupId"
                                }]
                            }
                        }
"@
                        Invoke-AzRestMethod -Method PATCH -Uri $patchURL -Payload $bodyAction
                    }
                    default { #scheduled Query rules
                        Update-AzScheduledQueryRule -ResourceGroupName $alertinfo[4] -Name $alertinfo[8] -ActionGroupResourceId $actionGroupId
                    }
                }
                
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }

}
else
{
    "No alerts provided."
}
$body = "This HTTP triggered function executed successfully. $($alerts.count) were altered ($action)."
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

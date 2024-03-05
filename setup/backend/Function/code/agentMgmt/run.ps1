
using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)
# Function to add AMA to a VM or arc machine
# The tags added to the extension are copied from the resource.
# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
"Resources"
$resources
$action = $Request.Body.Action

if ($resources) {
    "Working on $($resources.count) resource(s). Action: $action. Altering AMA configuration."
    switch ($action) {
        'AddAgent' {
            foreach ($resource in $resources) {
                # $resourceName=$resource.id.split('/')[8]
                # $resourceSubcriptionId=$resource.id.split('/')[2]
                "Running $action for $resourceName resource."
                Add-Agent -resourceId $resource.id -ResourceOS $resource.OSType -location $resource.location
            }
        }
        'RemoveAgent' {
            foreach ($resource in $resources) {
                # $resourceName=$resource.id.split('/')[8]
                # $resourceSubcriptionId=$resource.id.split('/')[2]
                "Running $action for $resourceName resource."
                Remove-Agent -resourceId $resource.id -ResourceOS $resource.OSType -location $resource.location
            }
        }
        default {
            Write-Host "Invalid Action"
        }
    }
}
else
{
    "No resources provided."
}
$body = "This HTTP triggered function executed successfully. $($resources.count) were altered ($action)."
#Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$resources = $Request.Body.Resources
$action = $Request.Body.Action
$TagValue = $Request.Body.Pack
$PackType = $Request.Body.PackType

if ($resources) {
        #$TagName='MonitorStarterPacks'
    $TagName=$env:SolutionTag
    if ([string]::isnullorempty($TagName)) {
        $TagName='MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    "Working on $($resources.count) resource(s). Action: $action. Altering $TagName in the resource."
    switch ($action) {
        'AddTag' {
            foreach ($resource in $resources) {
                "Running $action for $($resource.Resource) resource. TagValue: $TagValue"
                #$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                $tag=(get-aztag -ResourceId $resource.Resource).Properties.TagsProperty
                #"Current tags: $($tag)"
                if ($null -eq $tag) { # initializes if no tag is there.
                    $tag = @{}
                }
                if ($tag.Keys -notcontains $TagName) { # doesn´t have the monitoring tag
                    $tag.Add($TagName, $TagValue)
                    Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                }
                else { #Monitoring Tag exists  
                    if ($tag.$tagName.Split(',') -notcontains $TagValue) {
                        $tag[$TagName] += ",$TagValue"
                        #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
                        Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                    }
                    else {
                        "$($tag[$TagName]) already has the $TagValue value"
                    }
                }
                #Set-AzResource -ResourceId $resource.Resource -Tag $tag -Force
            }
        }
        'RemoveTag' {
            foreach ($resource in $resources) {
                "Running $action for $($resource.Resource) resource. TagValue: $TagValue"
                #[System.Object]$tag = (Get-AzResource -ResourceId $resource.Resource).Tags
                [System.Object]$tag=(get-aztag -ResourceId $resource.Resource).Properties.TagsProperty
                if ($null -eq $tag) { # initializes if no tag is there.
                    $tag = @{}
                }
                else {
                    if ($tag.Keys -notcontains $TagName) { # doesn´t have the monitoring tag
                        "No monitoring tag, can't delete the value. Something is wrong"
                    }
                    else { #Monitoring Tag exists. Good.  
                        if ($TagValue -eq 'All') { # Request to remove all monitoring. All associations need to be removed as well as diagnostics settings. 
                            #Tricky to remove only diagnostics settings that were created by this solution (name? tag?)
                            #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                            
                            $tag.Remove($tagName)
                            Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                        }
                        else {
                            if ($tag.$tagName.Split(',') -notcontains $TagValue) {
                                "Tag exists, but not the value. Can't remove it. Something is wrong."
                            }
                            else {
                                [System.Collections.ArrayList]$tagarray=$tag[$tagName].split(',')
                                $tagarray.Remove($TagValue)
                                if ($tagarray.Count -eq 0) {
                                    "Removing tag since it has no values."
                                    $tag.Remove($tagName)
                                    #$tagToRemove=@{"$($TagName)"="$($tag.$tagValue)"}
                                    Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                                }
                                else {
                                    $tag[$tagName]=$tagarray -join ','
                                    Update-AzTag -ResourceId $resource.Resource -Tag $tag -Operation Replace
                                }
                                if ($PackType -ne 'Paas') {
                                    # Remove association for the rule with the monitoring pack. PlaceHolder. Function will need to have monitoring contributor role.
                                    # Find the specific rule by the tag with ARG
                                    # Find association with the monitoring pack and that resource
                                    # Remove association
                                    # find rule
                                    $DCRQuery=@"
resources
| where type == "microsoft.insights/datacollectionrules"
| extend MPs=tostring(['tags'].MonitorStarterPacks)
| where MPs=~'$TagValue'
| summarize by name, id
"@
                                    $DCR=Search-AzGraph -Query $DCRQuery
                                    "Found rule $($DCR.name)."
                                    "DCR id : $($DCR.id)"
                                    "resource: $($resource.Resource)"
                                    $associationQuery=@"
insightsresources
| where type == "microsoft.insights/datacollectionruleassociations"
| extend resourceId=split(id,'/providers/Microsoft.Insights/')[0], ruleId=properties.dataCollectionRuleId
| where isnotnull(properties.dataCollectionRuleId)
| where resourceId =~ '$($resource.Resource)' and
ruleId =~ '$($DCR.id)'
"@
                                    $associationQuery
                                    $association=Search-AzGraph -Query $associationQuery
                                    "Found association $($association.name). Removing..."
                                    if ($association.count -gt 0) {
                                        Remove-AzDataCollectionRuleAssociation -TargetResourceId $resource.Resource -AssociationName $association.name
                                    }
                                    else {
                                        "No association Found."
                                    }
                                }
                                else {
                                    "Paas Pack. No need to remove association."
                                    $diagnosticConfig=Get-AzDiagnosticSetting -ResourceId $resource.Resource -Name "AMSP-$TagValue"
                                    if ($diagnosticConfig) {
                                        "Found diagnostic setting. Removing..."
                                        Remove-AzDiagnosticSetting -ResourceId $resource.Resource -Name "AMSP-$TagValue"
                                    }
                                    else {
                                        "No diagnostic setting found."
                                    }
                                }
                            }
                        #Update-AzTag -ResourceId $resource.Resource -Tag $tag
                        }
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
    "No resources provided."
}
$body = "This HTTP triggered function executed successfully. $($resources.count) were altered ($action)."
Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

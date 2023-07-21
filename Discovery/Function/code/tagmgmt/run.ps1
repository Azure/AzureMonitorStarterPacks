using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.
$servers = $Request.Body.Servers
$action = $Request.Body.Action
$TagValue = $Request.Body.Pack

if ($servers) {
        #$TagName='MonitorStarterPacks'
    $TagName=$env:SolutionTag
    if ([string]::isnullorempty($TagName)) {
        $TagName='MonitorStarterPacks'
        "Missing TagName. Please set the TagName environment variable. Setting to Default"
    }
    "Working on $($servers.count) server(s). Action: $action. Altering $TagName in the machines."
    switch ($action) {
        'AddTag' {
            foreach ($server in $servers) {
                "Running $action for $($server.Server) server. TagValue: $TagValue"
                $tag = (Get-AzResource -ResourceId $server.Server).Tags
                #"Current tags: $($tag)"
                if ($tag -eq $null) { # initializes if no tag is there.
                    $tag = @{}
                }
                if ($tag.Keys -notcontains $TagName) { # doesn´t have the monitoring tag
                    $tag.Add($TagName, $TagValue)
                }
                else { #Monitoring Tag exists  
                    if ($tag.$tagName.Split(',') -notcontains $TagValue) {
                        $tag[$TagName] += ",$TagValue"
                        Set-AzResource -ResourceId $server.Server -Tag $tag -Force
                    }
                    else {
                        "$($tag[$TagName]) already has the $TagValue value"
                    }
                }
                Set-AzResource -ResourceId $server.Server -Tag $tag -Force
            }
        }
        'RemoveTag' {
            foreach ($server in $servers) {
                "Running $action for $($server.Server) server. TagValue: $TagValue"
                [System.Object]$tag = (Get-AzResource -ResourceId $server.Server).Tags
                if ($tag -eq $null) { # initializes if no tag is there.
                    $tag = @{}
                }
                else {
                    if ($tag.Keys -notcontains $TagName) { # doesn´t have the monitoring tag
                        "No monitoring tag, can't delete the value. Something is wrong"
                    }
                    else { #Monitoring Tag exists. Good.  
                        if ($TagValue -eq 'All') { # Request to remove all monitoring. All associations need to be removed.                         
                            #Remove all associations with all monitoring packs.PlaceHolder. Function will need to have monitoring contributor role.
                            #Will need a list with all the previous tags to find the proper associations.
                            #$previousTags = $tag[$tagName].split(',')
                            $tag.Remove($tagName)
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
                                }
                                else {
                                    $tag[$tagName]=$tagarray -join ','
                                }
                                # Remove association for the rule with the monitoring pack. PlaceHolder. Function will need to have monitoring contributor role.
                                # Find the specific rule by the tag with ARG
                                # Find association with the monitoring pack
                                # Remove association
                            }
                        }
                        Set-AzResource -ResourceId $server.Server -Tag $tag -Force
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
    "No servers provided."
}
$body = "This HTTP triggered function executed successfully. $($servers.count) were altered ($action)."
# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

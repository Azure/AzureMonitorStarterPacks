# Define the path to your JSON file
param (
    [string]$jsonFilePath,
    [string]$jsoutOutputPath
)

# Read the JSON file and convert it to a PowerShell object
$jsonContent = Get-Content -Path $jsonFilePath -Raw | ConvertFrom-Json

function Clear-SubscriptionValues {
    param (
        [object]$obj
    )

    if ($obj -is [System.Array] -or $obj -is [System.Collections.ArrayList]) {
        # If the object is an array, iterate through each item
        for ($i = 0; $i -lt $obj.Count; $i++) {
            if ($obj[$i] -is [string] -and $obj[$i] -match '/subscriptions/') {
                $obj[$i] = ""
            } elseif ($obj[$i] -is [System.Object]) {
                Clear-SubscriptionValues -obj $obj[$i]
            }
        }
    } elseif ($obj -is [System.Collections.Hashtable] -or $obj -is [System.Management.Automation.PSCustomObject]) {
        # If the object is a hashtable or custom object, iterate through its properties
        foreach ($property in $obj.PSObject.Properties) {
            if ($property.Value -is [string] -and $property.Value -match '/subscriptions/') {
                $property.Value = ""
            } elseif ($property.Value -is [System.Array] -or $property.Value -is [System.Collections.ArrayList]) {
                Clear-SubscriptionValues -obj $property.Value
            } elseif ($property.Value -is [System.Object]) {
                Clear-SubscriptionValues -obj $property.Value
            }
        }
    }
}
# Call the function to clear subscription values
Clear-SubscriptionValues -obj $jsonContent

# Convert the modified object back to JSON
$jsonContent | ConvertTo-Json -Depth 100 | Set-Content -Path $jsoutOutputPath
# Get all Cognitive Services accounts
$query = "resources | where type has 'Microsoft.CognitiveServices/accounts' | project name, kind, sku=sku.name, id"
$accounts = Search-AzGraph -Query $query

# Group accounts by kind and select one of each kind
$selectedAccounts = $accounts | Group-Object -Property Kind,sku | ForEach-Object { $_.Group | Select-Object -First 1 }

# Create a hashtable to hold the results
$results = @{}

# Get metrics for each kind of selected account
foreach ($account in $selectedAccounts) {
    $metrics = Get-AzMetricDefinition -ResourceId $account.Id

    foreach ($metric in $metrics) {
        # If this metric is not in the results yet, add it
        if (-not $results.ContainsKey($metric.Name.Value)) {
            $results[$metric.Name.Value] = @()
        }

        # Add this kind to the list of kinds for this metric
        $results[$metric.Name.Value] += "$($account.Kind)-$($account.Sku)"
    }
}

# Convert the results to JSON
$results.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [PSCustomObject]@{
        Metric = $_.Name
        Kinds = $_.Value
    }
} #| ConvertTo-Json

$results

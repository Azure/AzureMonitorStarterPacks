# Get all Cognitive Services accounts
$query = "resources | where type has 'Microsoft.CognitiveServices/accounts' | project name, kind, id"
$accounts = Search-AzGraph -Query $query

# Group accounts by kind and select one of each kind
$selectedAccounts = $accounts | Group-Object -Property Kind | ForEach-Object { $_.Group | Select-Object -First 1 }

# List metrics for selected accounts
foreach ($account in $selectedAccounts) {
    #Write-Host "Metrics for $($account.Name):"
    $metrics = Get-AzMetricDefinition -ResourceId $account.Id
    Write-Host "$($account.Name):" -ForegroundColor Green
    Write-Host "$($metrics.Name.Value)"
}
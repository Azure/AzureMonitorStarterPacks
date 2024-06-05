# Get all Load Balancers
$query = "resources | where type has 'Microsoft.Network/loadBalancers' | project name, sku=sku.name, tier=sku.tier,id"
$loadBalancers = Search-AzGraph -Query $query

# Group Load Balancers by SKU and select one of each SKU
$selectedLoadBalancers = $loadBalancers | Group-Object -Property sku,tier | ForEach-Object { $_.Group | Select-Object -First 1 }

# Create a hashtable to hold the results
$results = @{}

# Get metrics for each SKU of selected Load Balancer
foreach ($loadBalancer in $selectedLoadBalancers) {
    $metrics = Get-AzMetricDefinition -ResourceId $loadBalancer.id

    foreach ($metric in $metrics) {
        # If this metric is not in the results yet, add it
        if (-not $results.ContainsKey($metric.Name.Value)) {
            $results[$metric.Name.Value] = @()
        }

        # Add this SKU to the list of SKUs for this metric
        $results[$metric.Name.Value] += "$($loadBalancer.sku)-$($loadBalancer.tier)"
    }
}

# Convert the results to JSON
$results.GetEnumerator() | Sort-Object Name | ForEach-Object {
    [PSCustomObject]@{
        Metric = $_.Name
        SKUs = $_.Value
    }
}# | ConvertTo-Json
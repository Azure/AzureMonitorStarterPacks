param (
    $key
)
$ErrorActionPreference='stop'
$storageAccountName='amonsterpacks2321'
$tableName = "supportedServices"
$inventoryTime=(Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
#$key=$env:key

# Create a storage context
#$ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
$ctx= New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key

# Get a reference to the table
$table = (Get-AzStorageTable -Name $tableName -Context $ctx).CloudTable
$catalog=get-ambacatalog | convertfrom-json
$supportedNamespaces = $catalog.categories.namespace #| where {$_ -eq 'microsoft.desktopvirtualization/hostpools'}
#old way to get the catalog
#$fc=Invoke-WebRequest -uri $ambaJsonURL | convertfrom-json # gets the whole catalog with all metrics
$fc=get-AMBAJsonContent | convertfrom-json
# Get the cata
#$resourcesWithAlerts=@()
foreach ($ns in $supportedNamespaces) {
    Write-host "Looking for objects in namespace $ns" -ForegroundColor Yellow
    # get all azure resources using resource graph that are in the catalog by using the categories.namespace output
    $resources = Search-AzGraph -Query "resources | where type =~ '$ns' | project id, name, kind, sku=sku.name, tier=sku.tier, location, resourceGroup, type"
    # need now to find all the metrics that are in the catalog for this namespace
    foreach ($res in $resources) {
        $resourceCategory=$res.type.split('/')[0].split('.')[1]
        $resourceType=$res.type.split('/')[1]
        $metricsInAMBA = $fc.$resourceCategory.$resourceType.name # only available alerts in AMBA for that type of resource| where-object { $_.namespace -eq $ns } | select -ExpandProperty metrics
        # Now lets check if that metric is in fact available for that resource. We will only present the metrics that are available in AMBA
        try {
            $avaiableMetrics=Get-AzMetricDefinition -ResourceId $res.id | Where-Object {$_.Name.Value -in $metricsInAMBA} -ErrorAction SilentlyContinue
        }
        catch [Exception] {
            Write-Warning "Error getting metrics for $($res.name) kind: $($res.kind). Sku/Tier: $($res.sku)/$($res.tier):" #-ForegroundColor Red
            $avaiableMetrics=$null
            continue
        }
        if ($avaiableMetrics) {
            #Write-Host "$($avaiableMetrics.Name.Value.count) Metrics available for $($res.name) kind: $($res.kind). Sku/Tier: $($res.sku)/$($res.tier):" -ForegroundColor Green
            # add the resource to the supported list as an array of objects containing the id, name, kind, sku, tier, location, resourceGroup, type and subscription
            # $resourcesWithAlerts+=[PSCustomObject]@{
            #     id=$res.id
            #     name=$res.name
            #     kind=$res.kind
            #     sku=$res.sku
            #     tier=$res.tier
            #     location=$res.location
            #     resourceGroup=$res.resourceGroup
            #     type=$res.type
            #     subscription=$res.id.split('/')[2]
            #     metrics=$avaiableMetrics.Name.Value
            # }
            # Convert the object to a hashtable
            $resource=[PSCustomObject]@{
                id=$res.id
                name=$res.name
                kind=$res.kind
                sku=$res.sku
                tier=$res.tier
                location=$res.location
                resourceGroup=$res.resourceGroup
                type=$res.type
                subscription=$res.id.split('/')[2]
                metrics=$avaiableMetrics.Name.Value
                inventoryTime=$inventoryTime
            }
            # #$entity.Add($res.id, $resource)
            $rowkey=$res.id.split('/')[4]+'-'+$res.id.split('/')[8]
            $entity=New-Object -TypeName Microsoft.Azure.Cosmos.Table.DynamicTableEntity -ArgumentList $res.id.split('/')[2], $rowkey #, $null, $property
            $resource.PSObject.Properties | ForEach-Object { 
                #$property= @{ "$($_.Name)" = "$($_.Value)"}
                $entity.Properties.Add("$($_.Name)","$($_.Value)")
                # Add-AzTableRow -table $table `
                #         -property $property `
                #         -partitionKey "partition1" `
                #         -RowKey "$($res.id)"
            }
            $table.Execute([Microsoft.Azure.Cosmos.Table.TableOperation]::InsertOrReplace($entity)) | Out-Null
            # Create a new entity
                # $entity = New-Object -TypeName Microsoft.Azure.Cosmos.Table.DynamicTableEntity -ArgumentList "partition1", "Row1"
                # $entity.Properties.Add("id", $res.id)
                # #create OperationsContext
                # # $entity.Properties.Add("name", $res.name)
                # # $entity.Properties.Add("kind", $res.kind)
                # # $entity.Properties.Add("sku", $res.sku)
                # # $entity.Properties.Add("tier", $res.tier)
                # # $entity.Properties.Add("location", $res.location)
                # # $entity.Properties.Add("resourceGroup", $res.resourceGroup)
                # # $entity.Properties.Add("type", $res.type)
                # # $entity.Properties.Add("subscription", $res.id.split('/')[2])
                # # $entity.Properties.Add("metrics", $avaiableMetrics.Name.Value)
                # # $entity.Properties.Add("inventoryTime", $inventoryTime)
                # # # Create a TableOperation to insert the entity
                # $operation = [Microsoft.Azure.Cosmos.Table.TableOperation]::Insert($entity)

                # # Execute the operation
                # $table.Execute($operation)
            }
    }
}
#$resourcesWithAlerts


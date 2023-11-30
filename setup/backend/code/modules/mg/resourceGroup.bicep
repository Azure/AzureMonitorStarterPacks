targetScope = 'subscription'

param resourceGroupName string
param location string
param Tags object

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: Tags
}
output newResourceGroupId string = resourceGroup.id

targetScope = 'subscription'

param resourceGroupName string
param location string
param solutionVersion string
param solutionTag string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
  tags: {
    solutionTag: solutionTag
    solutionVersion: solutionVersion
  }
}
output newResourceGroupId string = resourceGroup.id

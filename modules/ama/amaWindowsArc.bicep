param vmName string
param location string

resource windowsAgent 'Microsoft.HybridCompute/machines/extensions@2021-12-10-preview' = {
  name: '${vmName}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    autoUpgradeMinorVersion: true
  }
}

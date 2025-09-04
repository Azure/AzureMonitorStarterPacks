param vmName string
param location string

resource linuxAgent 'Microsoft.HybridCompute/machines/extensions@2021-12-10-preview'= {
  name: '${vmName}/AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    autoUpgradeMinorVersion: true
  }
}

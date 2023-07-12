resource azfunctionsite 'Microsoft.Web/sites@2021-03-01' existing = {
name: 'MonitorStarterPacksDiscovery'

}
output keys string = listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion).masterKey

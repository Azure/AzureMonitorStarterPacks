resource azfunctionsite 'Microsoft.Web/sites@2021-03-01' existing = {
  name: 'MonitorStarterPacks-6c64f9ed'
}
// resource function 'Microsoft.Web/sites/functions@2022-09-01' existing = {
//   name: 'tagmgmt'
//   parent: azfunctionsite
// }
// resource funkeys 'Microsoft.Web/sites/functions/keys@2022-09-01' existing = {
//   name: 'default'
//   parent: function
// }
output masterkey object = listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'default'), azfunctionsite.apiVersion)
//output tagmgmtkey string = listKeys(resourceId('Microsoft.Web/sites/host', azfunctionsite.name, 'tagmgmt'), azfunctionsite.apiVersion).default


@description('The name of the function app.')
param functionName string

@description('The new application settings to be added or updated.')
param appSettings object

param currentAppSettings object

resource webApp 'Microsoft.Web/sites@2024-04-01' existing = {
  name: functionName
}
//var currentAppSettings= list(resourceId('Microsoft.Web/sites/config', webApp.name, 'appsettings'), webApp.apiVersion).properties

resource siteconfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: webApp
  name: 'appsettings'
  properties: union(currentAppSettings, appSettings)
}

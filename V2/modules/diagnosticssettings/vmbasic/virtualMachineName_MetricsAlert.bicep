param name string
param severity int
param actionGroups array
param allOf array
param location string
param vmResourceIds array
param resourceLocation string

resource name_resource 'microsoft.insights/metricAlerts@2018-03-01' = {
  name: name
  location: location
  properties: {
    severity: severity
    enabled: true
    scopes: vmResourceIds    
    evaluationFrequency: 'PT5M'
    windowSize: 'PT5M'
    criteria: {
      allOf: allOf
      'odata.type': 'Microsoft.Azure.Monitor.MultipleResourceMultipleMetricCriteria'
    }
    targetResourceType: 'Microsoft.Compute/virtualMachines'
    targetResourceRegion: resourceLocation
    actions: actionGroups
  }
}

param location string
param aigname string
param osType string 
param appDescription string
param appName string

resource aig 'Microsoft.Compute/galleries@2022-03-03' existing = {
  name: aigname
  scope: resourceGroup()
}

resource app1 'Microsoft.Compute/galleries/applications@2022-03-03' = {
  parent: aig
  name: appName
  location: location
  properties: {
    supportedOSType: osType
    description: appDescription
  }
}

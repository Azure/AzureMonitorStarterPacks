param location string
param resourceGroupName string
param grafanaResourceId string
param fileName string
param packsManagedIdentityResourceId string
param customerTags object
param solutionTag string
param solutionVersion string
param instanceName string
param subscriptionId string

var grafanaName = split(grafanaResourceId, '/')[8]
var grafanaResourceGroup = split(grafanaResourceId, '/')[4]
var grafanaSubscriptionId = split(grafanaResourceId, '/')[2]

var tempfilename = '${fileName}.tmp'

var Tags = (customerTags=={}) ? {'${solutionTag}': solutionTag
solutionVersion: solutionVersion
} : union({
  '${solutionTag}': solutionTag
  solutionVersion: solutionVersion
  instanceName: instanceName
},customerTags.All)

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-Grafana'
  tags: Tags
  location: location
  identity: {
    type: 'userAssigned'
    userAssignedIdentities: {
      '${packsManagedIdentityResourceId}': {}
    }
  }
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.42.0'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'CONTENT'
        value: loadFileAsBase64('./Grafana.zip')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${fileName} && az extension add --name amg && az login --identity && unzip ${fileName} && for file in *.json; do az grafana dashboard import -g ${grafanaResourceGroup} -n ${grafanaName} --subscription ${grafanaSubscriptionId} --definition "$file" --overwrite true;done'
  }
}

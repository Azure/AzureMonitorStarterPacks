param solutionTag string
param solutionVersion string
param location string
param resourceGroupName string
param grafanaName string
param fileName string
param packsManagedIdentityResourceId string

var tempfilename = '${fileName}.tmp'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-MonstarPacks'
  tags: {
    '${solutionTag}': 'deploymentScript'
    '${solutionTag}-Version': solutionVersion
  }
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
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${fileName} && az extension add --name amg && az login --identity && unzip ${fileName} && for file in *.json; do az grafana dashboard import -g ${resourceGroupName} -n ${grafanaName} --definition "$file" --overwrite true;done'
  }
}

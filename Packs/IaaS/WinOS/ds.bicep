param solutionTag string
param solutionVersion string
param location string
param resourceGroupName string
param grafanaName string
param fileName string

var tempfilename = '${fileName}.tmp'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-MonstarPacks'
  tags: {
    '${solutionTag}': 'deploymentScript'
    '${solutionTag}-Version': solutionVersion
  }
  location: location
  kind: 'AzureCLI'
  properties: {
    azCliVersion: '2.26.1'
    timeout: 'PT5M'
    retentionInterval: 'PT1H'
    environmentVariables: [
      {
        name: 'CONTENT'
        value: loadFileAsBase64('./Azure Monitor Start Pack - Windows Operating System-1692086853589.json')
      }
    ]
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${fileName} && az extension add --name amg && az grafana dashboard import -g ${resourceGroupName} -n ${grafanaName} --definition ${fileName} --overwrite true'
  }
}

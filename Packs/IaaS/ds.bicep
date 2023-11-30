param location string
param resourceGroupName string
param grafanaName string
param fileName string
param packsManagedIdentityResourceId string
param customerTags object
param solutionTag string
param solutionVersion string

var tempfilename = '${fileName}.tmp'
var Tags = (customerTags== null) ? {'solutionTag': solutionTag
'solutionVersion': solutionVersion} : union({
  'solutionTag': solutionTag
  'solutionVersion': solutionVersion
},customerTags['All'])
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'deployscript-MonstarPacks'
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
    scriptContent: 'echo "$CONTENT" > ${tempfilename} && cat ${tempfilename} | base64 -d > ${fileName} && az extension add --name amg && az login --identity && unzip ${fileName} && for file in *.json; do az grafana dashboard import -g ${resourceGroupName} -n ${grafanaName} --definition "$file" --overwrite true;done'
  }
}

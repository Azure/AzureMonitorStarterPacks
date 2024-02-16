param (
    [Parameter(Mandatory=$true)]
    [string] 
    $alertsFileURL,
    [Parameter(Mandatory=$true)]
    [string]
    $packTag,
    [Parameter(Mandatory=$true)]
    [string]
    $packType, # IaaS, PaaS, Platform,
    # [Parameter(Mandatory=$true)]
    # [string]
    # $outputPackPath,
    [Parameter(Mandatory=$false)]
    [string]
    $subfolder # optional subfolder to store the pack at the top level under the PackType folder

)
if ([string]::IsNullOrEmpty($subfolder)) {
  $pathFileFolder="./$packType/$packTag"
  $packFolder="./$packtag/alerts.bicep"
}
else {
  $pathFileFolder="./Packs/$packType/$subfolder/$packTag"
  $packFolder="./$subfolder/$packtag/alerts.bicep"
}
#$alertsFile=Get-Content -Path $alertsFilePath | Out-String #/home/jofehse/git/azure-monitor-baseline-alerts/services/Web/sites/alerts.yaml | out-string
$alertsFile=Invoke-WebRequest -Uri $alertsFileURL | Select-Object -ExpandProperty Content | Out-String
$alertst=ConvertFrom-Yaml $alertsFile
$alerts=ConvertTo-Yaml -JsonCompatible $alertst | ConvertFrom-Json

$packContent=@'

param location string
param workspaceId string
param AGId string
param packtag string
param Tags object
param instanceName string
//var moduleprefix = 'AMSP-Win-VMI'
var moduleprefix = 'AMP-${instanceName}-${packtag}'

param deploymentRoleDefinitionIds array = [
    '/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
]
// param parResourceGroupTags object = {
//     environment: 'test'
// }
param parAlertState string = 'true'

var alertlist = [

'@


$i=1
if (($alerts | Where-Object {$_.visible -eq $true}).count -eq 0) {
  Write-Host "No visible alerts found in the file"
  exit
}

$alerts | Where-Object {$_.visible -eq $true -and $_.type -eq 'Log'} | ForEach-Object {
$packContent+=@"
  {
    alertRuleDescription: '$($_.description)'
    alertRuleDisplayName: '$($_.Name)'
    alertRuleName:'$($_.Name.replace(' ',''))'
    alertRuleSeverity: $($_.Properties.severity)
    autoMitigate: $($_.Properties.autoMitigate.tostring().tolower())
    evaluationFrequency: '$($_.Properties.evaluationFrequency)'
    windowSize: '$($_.Properties.windowSize)'
    alertType: 'Aggregated'
    metricMeasureColumn: '$($_.Properties.metricMeasureColumn)'
    operator: '$($_.Properties.operator)'
    threshold: $($_.Properties.threshold)
    query: '''
    $($_.Properties.query)'''
  }
"@
}

$packContent+=@'

]
module alertsnew '../../../modules/alerts/alerts.bicep' = {
  name: '${moduleprefix}-Alerts'
  params: {
    alertlist: alertlist
    AGId: AGId
    location: location
    moduleprefix: moduleprefix
    packtag: packtag
    Tags: Tags
    workspaceId: workspaceId
  }
}

'@
# module Alert${i} '../../../modules/alerts/PaaS/metricAlertStaticThreshold.bicep' = {
#     name: '`${uniqueString(deployment().name)}-$($_.name.replace(' ',''))'
#     params: {
#     assignmentLevel: assignmentLevel
#       policyLocation: policyLocation
#       mgname: mgname
#       packTag: packTag
#       resourceType: resourceType
#       solutionTag: solutionTag
#       subscriptionId: subscriptionId
#       userManagedIdentityResourceId: userManagedIdentityResourceId
#       deploymentRoleDefinitionIds: deploymentRoleDefinitionIds
#       alertname: '$($_.Name) - $($_.Properties.metricNameSpace.split("/")[1].replace("/", "-"))'
#       alertDisplayName: '$($_.Name) - $($_.Properties.metricNameSpace)'
#       alertDescription: '$($_.description)'
#       metricNamespace: '$($_.Properties.metricNameSpace)'
#       parAlertSeverity: '$($_.Properties.severity)'
#       metricName: '$($_.Properties.metricName)'
#       operator: '$($_.Properties.operator)'
#       parEvaluationFrequency: '$($_.Properties.evaluationFrequency)'   
#       parWindowSize: '$($_.Properties.windowSize)'
#       parThreshold: '$($_.Properties.threshold)'
#       assignmentSuffix: 'Met$($_.properties.metricNamespace.split("/")[1])${i}'
#       parAutoMitigate: '$($_.Properties.autoMitigate).tolower)'
#       parPolicyEffect: 'deployIfNotExists'
#       AGId: AGId
#       parAlertState: parAlertState
#       initiativeMember: false
#       packtype: '$packType'
#       instanceName: instanceName
#       timeAggregation: '$($_.Properties.timeAggregation)'
#     }
#   }
# "@        



$i++    
$packContent
break
if (!(Test-Path -Path $pathFileFolder)) {
  New-Item -Path $pathFileFolder -ItemType Directory 
}
$packContent | out-file -FilePath "$pathFileFolder/alerts.bicep" -Encoding utf8
$alertconfig | out-file "./Packs/$packType/All$($packType)Packs.bicep" -Encoding utf8 -Append




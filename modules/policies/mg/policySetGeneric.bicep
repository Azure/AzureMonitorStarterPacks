targetScope = 'managementGroup' 

@maxLength(64)
@description('PolicySet name')
param initiativeName string 

@maxLength(128)
@description('PolicySet display Name')
param initiativeDisplayName string

@description('PolicySet description')
param initiativeDescription string

@minLength(1)
@description('array of policy IDs')
//param initiativePoliciesID array
param solutionTag string
param category string = 'Monitoring' 
param version string = '1.0.0'
param policyDefinitions array
param assignmentLevel string
param location string
param userManagedIdentityResourceId string
param subscriptionId string
param packtag string
param instanceName string

resource policySetDef 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'AMP-${instanceName}-${initiativeName}'
  properties: {
    description: 'AMP-${instanceName}-${initiativeDescription}'
    displayName: 'AMP-${instanceName}-${initiativeDisplayName}'
    metadata: {
      category: category
      version: version
      '${solutionTag}': packtag
    }
    parameters: {}
    policyDefinitions:  policyDefinitions
    policyType: 'Custom'
  }
}

module assignment './assignment.bicep' = if (assignmentLevel == 'ManagementGroup'){
  name: 'assignment-${initiativeName}'
  // dependsOn: [
  //   policySetDef
  // ]
  params: {
    policyDefinitionId: policySetDef.id
    location: location
    assignmentName: 'A-${instanceName}-${packtag}-S'
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
    // roledefinitionIds: [
    //   '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c' 
    // ]
  }
}
module assignmentsub '../subscription/assignment.bicep' = if (assignmentLevel != 'ManagementGroup') {
  name: 'assignment--${initiativeName}'
  // dependsOn: [
  //   policySetDef
  // ]
  scope: subscription(subscriptionId)
  params: {
    policyDefinitionId: policySetDef.id
    location: location
    assignmentName: 'AMP-AMA-${initiativeName}-Set'
    solutionTag: solutionTag
    userManagedIdentityResourceId: userManagedIdentityResourceId
    // roledefinitionIds: [
    //   '/providers/microsoft.authorization/roleDefinitions/9980e02c-c2be-4d73-94e8-173b1dc7cf3c' 
    // ]
  }
}

output policySetDefId string = policySetDef.id

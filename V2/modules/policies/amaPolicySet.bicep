var policyIDs = [
  '/providers/Microsoft.Authorization/policyDefinitions/d367bd60-64ca-4364-98ea-276775bddd94'
  '/providers/Microsoft.Authorization/policyDefinitions/ae8a10e6-19d6-44a3-a02d-a2bdfc707742'
  '/providers/Microsoft.Authorization/policyDefinitions/637125fd-7c39-4b94-bb0a-d331faf333a9'
]

module amaPolicy 'policySet.bicep' = {
  name: 'amaPolicy'
  scope: subscription()
  params: {
    initiativeDescription: 'This initiative deploys the AMA policy set'
    initiativeDisplayName: 'AMA Policy Set'
    initiativeName: 'amaPolicy'
    category: 'Monitoring'
    version: '1.0.0'
    initiativePoliciesID: policyIDs
  }
}

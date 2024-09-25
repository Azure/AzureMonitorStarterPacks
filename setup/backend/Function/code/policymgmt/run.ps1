using namespace System.Net
# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."
$userIdentityId=$ENV:PacksUserManagedId # Comes from the Function App settings (Configuration)
if ([string]::IsNullOrEmpty($userIdentityId)) {
    "Error - PacksUserManagedId is not set."
    break
}
$SolutionTag=$Request.Body.SolutionTag
$action=$Request.Body.Action
"Action Selected: $action"
# Interact with query parameters or the body of the request.
switch ($action) {
    'Remediate' {
        "Into selected Remediate action."
        "Policy List provided? Let's see..."
        $Request.Body.Policies
        $policylist=$Request.Body.Policies
        if ([string]::IsNullOrEmpty($policylist)) {
            "No policy list provided. Getting all policies and initiatives."
            $SolutionTag=$env:SolutionTag
            $polStateQuery=@"
policyresources
| where ['type'] == 'microsoft.policyinsights/policystates'
| extend ComplianceState=tostring(properties.complianceState), PolicySetDefinitionName=tostring(properties.policySetDefinitionName)
| where isnotempty(PolicySetDefinitionName)
| where ComplianceState =~ "NonCompliant"
| summarize by PolicySetDefinitionName
| join kind= innerunique   (policyresources
| where ['type'] =~ "microsoft.authorization/policysetdefinitions" and isnotnull(properties.metadata.MonitorStarterPacks)
| project PolicySetDefinitionName=name, PolicySetDefinitionId=id, policyDefinitions=properties.policyDefinitions) on PolicySetDefinitionName
| project-away PolicySetDefinitionName1
"@
            $inits=Search-AzGraph -Query $polStateQuery -UseTenantScope
            #$inits=Get-AzPolicySetDefinition | Where-Object {$_.Metadata.$SolutionTag -ne $null} | Where-Object {$_.Name -in $polState.PolicySetDefinitionName}
            $polStateQuery=@"
policyresources
| where ['type'] == 'microsoft.policyinsights/policystates'
| extend ComplianceState=tostring(properties.complianceState), PolicySetDefinitionName=tostring(properties.policySetDefinitionName), PolicyDefinitionName=tostring(properties.policyDefinitionName)
| where ComplianceState =~ "NonCompliant"
| summarize by PolicyDefinitionName
| join kind= innerunique   (policyresources
| where ['type'] =~ "microsoft.authorization/policydefinitions" and isnotnull(properties.metadata.MonitorStarterPacks) 
 and properties.metadata.initiativeMember != true
| project  PolicyDefinitionName=name, PolicyDefinitionId=id) on PolicyDefinitionName
| project-away PolicyDefinitionName1
"@
            $pols=Search-AzGraph -Query $polStateQuery -UseTenantScope
            #$pols=Get-AzPolicyDefinition | Where-Object {($_.Metadata.$SolutionTag -ne $null -or $_.Metadata.MonitorStarterPacksComponents -ne $null) -and $_.Metadata.initiativeMember -ne $true} | Where-Object {$_.Name -in $polState.PolicyDefinitionName}
            "Found $($pols.Count) policies and $($inits.Count) policy sets to remediate"
            # $pols=Get-AzPolicyDefinition | Where-Object {$_.properties.Metadata.$SolutionTag -ne $null -or $_.properties.Metadata.MonitorStarterPacksComponents -ne $null}
            # $inits=Get-AzPolicySetDefinition | ? {$_.properties.Metadata.MonitorStarterPacks -ne $null}
        }
        else {
            "Policy list provided. Getting only those policies and initiatives."
            $pols=Get-AzPolicyDefinition | Where-Object {($_.Metadata.$SolutionTag -ne $null -or $_.Metadata.MonitorStarterPacksComponents -ne $null) -and $_.ResourceId -in $policylist.policyId} 
            $inits=Get-AzPolicySetDefinition | Where-Object {$_.Metadata.MonitorStarterPacks -ne $null -and $_.ResourceId -in $policylist.policyId}
        }
        foreach ($pol in $pols) {
            "Policy $($pol.PolicyDefinitionId) is non-compliant"
            $assignmentsQuery=@"
            policyresources
            | where type == 'microsoft.authorization/policyassignments'
            | extend policyDefinitionId=properties.policyDefinitionId, Scope=properties.scope
            | where policyDefinitionId == '$($pol.PolicyDefinitionId)'
"@
            #$assignments=Get-AzPolicyAssignment -PolicyDefinitionId $pol.PolicyDefinitionId
            $assignments=Search-AzGraph -Query $assignmentsQuery -UseTenantScope
            foreach ($assignment in $assignments) {
                "Starting remediation for $($assignment.DisplayName)"
                Start-AzPolicyRemediation -Name "$($pol.PolicyDefinitionName) remediation" -PolicyAssignmentId $assignment.id -ResourceDiscoveryMode ExistingNonCompliant -Scope $assignment.Scope
            }
        }
        foreach ($init in $inits) {
            "Policy set $($init.PolicySetDefinitionId) is non-compliant"
            #$assignment=Get-AzPolicyAssignment -PolicyDefinitionId $init.PolicySetDefinitionId -Scope "IntermediateRoot"
            $assignmentsQuery=@"
policyresources
| where type == 'microsoft.authorization/policyassignments'
| extend policyDefinitionId=properties.policyDefinitionId, Scope=properties.scope
| where policyDefinitionId == '$($init.PolicySetDefinitionId)'
"@
            $assignments=Search-AzGraph -Query $assignmentsQuery -UseTenantScope
            if ($assignments.Count -gt 0) {
                "Found $($assignments.Count) assignments for $($init.PolicySetDefinitionId)"
                $policiesInSet=$init.PolicyDefinitions | Select-Object -ExpandProperty policyDefinitionReferenceId
                #$policiesInSet
                foreach ($pol in $policiesInSet) {
                    "Starting remediation for $($assignment.Id) policy $pol"
                    foreach ($assignment in $assignments) {
                        Start-AzPolicyRemediation -Name "$($pol) remediation" -PolicyAssignmentId $assignment.Id -PolicyDefinitionReferenceId $pol -Scope $assignment.Scope
                    }
                }
            }
            else {
                "No assignment found for $($init.PolicySetDefinitionId)"
            }
        }
    }
    'Scan' {
        Start-AzPolicyComplianceScan -AsJob
    }
    'Assign' {
        "Into selected Assign action."
        $policies=$Request.Body.policies | ConvertFrom-Json
        $scopes=$Request.Body.Scopes | ConvertFrom-Json
        $policies
        $scopes
        foreach ($policy in $policies) {
            $policyName=$policy.Name
            $policyDefinition=Get-AzPolicyDefinition -Id $policy.PolicyId
            foreach ($scope in $scopes) {
                $assignment=New-AzPolicyAssignment -Name "Assign-$policyName" -DisplayName "Assignment-$policyName" -Scope $scope.id `
                -PolicyDefinition $policyDefinition -IdentityType UserAssigned -IdentityId $userIdentityId -Location eastus
                "Created assignment:"
                $assignment
            }
        }
    }
    'Unassign' {
        "Into selected Assign action."
        $policies=$Request.Body.policies | ConvertFrom-Json
        #$scopes=$Request.Body.Scopes | ConvertFrom-Json
        $policies
        #$scopes
        foreach ($policy in $policies) {
            $policyName=$policy.Name
            "Scope: $($policy.scope)"
            "Assignment Name: $($policy.AssignmentName)"
            "Assignment Level: $($policy.ScopeLevel)"
            if ($policy.ScopeLevel -eq 'Sub') {
                $subId=$policy.Scope.split('/')[2]
                "Sub Id: $subId"
                if ($subId -ne (get-azcontext).Subscription.Id) {
                    "Changing subscription to $($policy.Scope)."
                    Select-AzSubscription -subscriptionId $subId
                }
            }
            else {
                "Keeping current context. "
            }
            Get-AzPolicyAssignment -Name $policy.AssignmentName -Scope $policy.scope | Remove-AzPolicyAssignment
        }
    }
    'Default' {
        "No action specified. Bye."
    }
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
    StatusCode = [HttpStatusCode]::OK
    Body = $body
})

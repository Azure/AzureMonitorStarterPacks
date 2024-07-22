# Add a parameter to the script to specify the Management Group ID
param (
    [Parameter(Mandatory = $true)]
    [string]$ManagementGroupId
)
"Found $(Get-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId  | Where-Object -Property Timestamp -LT -Value ((Get-Date).AddDays(-15)) | Measure-Object).Count old deployments."
# 15 days or older deployments will be deleted
Get-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId  | Where-Object -Property Timestamp -LT -Value ((Get-Date).AddDays(-15)) | Remove-AzManagementGroupDeployment

# Count old deployments
Get-AzManagementGroupDeployment -ManagementGroupId $ManagementGroupId  | Where-Object -Property Timestamp -LT -Value ((Get-Date).AddDays(-15)) | Measure-Object
$vmlist=Get-AzVM
foreach ($vm in $vmlist | where $vm.OSProfile -eq 'Windows') {
    $vm.Name
}
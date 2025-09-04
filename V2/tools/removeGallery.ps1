param (
    [Parameter(Mandatory=$true)]
    [string]$RG
)
Get-AzGallery -ResourceGroupName $RG | Where-Object {$_.Tags.MonitorStarterPacksComponents -ne $null} | ForEach-Object {
    "Finding apps..."
    $galleryApps=Get-AzGalleryApplication -GalleryName $_.Name -ResourceGroupName $RG
    "Found $($galleryApps.Count) apps."
    foreach ($ga in $galleryApps) {
        $gavs=Get-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -ResourceGroupName $RG
        "Found $($gavs.Count) versions of $($ga.Name)"
        "Finding VMs with $($ga.Name)"
        foreach ($gav in $gavs) {
            # Find vms with that app
            $vms=Get-AzVM | where {$_.ApplicationProfile -ne $null} | where {$_.ApplicationProfile.Applications -ne $null} | where {$_.ApplicationProfile.Applications.Name -eq $ga.Name}
            foreach ($vm in $vms) {
                # Remove Application from VM - Remove-AzVMGalleryApplication
                "Removing $($ga.Name) from $($vm.Name)"
                Remove-AzVMGalleryApplication -VM $vm -Name $ga.Name -Version $gav.Name -ResourceGroupName $vm.ResourceGroupName
            }
            # Remove Application Version - Remove-AzGalleryApplicationVersion
            "Removing $($gav.Name) from $($ga.Name)"
            Remove-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -Name $gav.Name -ResourceGroupName $RG
        }
        # Remove Application - Remove-AzGalleryApplication
        "Removing $($ga.Name) from gallery."
        Remove-AzGalleryApplication -GalleryName $_.Name -Name $ga.Name -ResourceGroupName $RG
        # Find VMs with that app
        #$vms=get-azVM | where {$_.ApplicationProfile -ne $null} | where {$_.ApplicationProfile.Applications -ne $null} | where {$_.ApplicationProfile.Applications.Name -eq $ga.Name}
        # Remove Application from VM - Remove-AzVMGalleryApplication
        # Remove Application Version - Remove-AzGalleryApplicationVersion
        #Get-AzGalleryApplicationVersion -GalleryName $_.Name -GalleryApplicationName $ga.Name -ResourceGroupName $RG | Remove-AzGalleryApplicationVersion
        # Remove Application - Remove-AzGalleryApplication
        #remove-AzGalleryApplication -GalleryName $_.Name -Name $ga.Name -ResourceGroupName $RG  
    }
    #Remove Gallery
    "Removing gallery $($_.Name)"
    Remove-AzGallery -Name $_.Name -ResourceGroupName $RG
}
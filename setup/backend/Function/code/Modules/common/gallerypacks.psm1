# This module has functions to manage packs that have gallery components
# How to find if a pack has a gallery component? Maybe gallery applications have tags.
# When adding the tag an creating associated mappings, we need to check if there is an application in the gallery with the same tag.
# If so, also install the application in the VM.

function New-vmApp {
    param (
        [Parameter(Mandatory = $true)]
        [string]$instanceName,
        [Parameter(Mandatory = $true)]
        [string]$packtag,
        [Parameter(Mandatory = $true)]
        [string]$resourceId # VM Resource ID to receive the application
    )
    #Find gallery by instanceName tag
    $gallery=Get-AzGallery | Where-Object { $_.Tags.instanceName -eq $instanceName }
    # Find gallery application by packtag
    $galleryapplications=(Get-AzGalleryApplication -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName) | where {$_.Tag.AdditionalProperties.MonitorStarterPacks -eq $packtag -and $_.Tag.AdditionalProperties.instanceName -eq $instanceName}
    if ($galleryapplications.Count -eq 0) {
        Write-Warning "No gallery applications found for $($packtag). No need to install."
        return $true
    }
    foreach ($ga in $galleryapplications) {
        # get latest application version
        $appversion=(Get-AzGalleryApplicationVersion -GalleryApplicationName $galleryapplications.Name -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName | Sort-Object -Descending PublishingProfilePublishedDate)[0]
        # install version to VM
        if ($appversion) {
            Write-Host "Installing $($appversion.Name) version $($appversion.PublishingProfile.PublishedDate) to $($resourceId)"
        }
        else {
            Write-Error "No application version found"
            return $false
        }
        $newAppConfig=New-AzVmGalleryApplication -PackageReferenceId $appversion.Id
        $VM=Get-AzVM -ResourceId $resourceId
        if ($VM) {
            Add-AzVmGalleryApplication -VM $VM -GalleryApplication $newAppConfig -TreatFailureAsDeploymentFailure
            $VM | Update-AzVM
            Write-Host "Installed $($appversion.Name) version $($appversion.PublishingProfile.PublishedDate) to $($resourceId)"
        }
        else {
            Write-Error "VM not found"
            return $false
        }
    }
    return $true
}
function remove-vmapp {
    [Parameter(Mandatory = $true)]
        [string]$resourceId, # VM Resource ID to delete the application from.
    [Parameter(Mandatory = $true)]
    [string]$packtag

    #find application related to the tag
    # remove the application from the VM
    $gallery=Get-AzGallery | Where-Object { $_.Tags.instanceName -eq $instanceName }
    # Find gallery application by packtag
    $galleryapplications=(Get-AzGalleryApplication -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName) | where {$_.Tag.AdditionalProperties.MonitorStarterPacks -eq $packtag -and $_.Tag.AdditionalProperties.instanceName -eq $instanceName}
    if ($galleryapplications.Count -eq 0) {
        Write-Warning "No gallery applications found for $($packtag). No need to install."
        return $false
    }
    foreach ($ga in $galleryapplications) {
        # get latest application version
        #$appversion=(Get-AzGalleryApplicationVersion -GalleryApplicationName $galleryapplications.Name -GalleryName $gallery.Name -ResourceGroupName $gallery.ResourceGroupName | Sort-Object -Descending PublishingProfilePublishedDate)[0]
        # install version to VM
        #
        $VM=Get-AzVM -ResourceId $resourceId
        if ($VM) {
            $installedApp=$VM.ApplicationProfile.GalleryApplications | Where-Object { $_.PackageReferenceId.Contains($ga.id)}
            "Removing $($ga.Name) from $($resourceId)"
            try {
                Remove-AzVmGalleryApplication -VM $VM -GalleryApplicationsReferenceId $installedApp.PackageReferenceId
                $VM | Update-AzVM
            }
            catch {
                Write-Error "Error removing application $($ga.Name) from $($resourceId)"
                return $false
            }
        }
        else {
            Write-Error "VM not found"
            return $false
        }
    }
    return $true
}
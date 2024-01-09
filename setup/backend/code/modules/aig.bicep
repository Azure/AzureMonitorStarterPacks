param location string
param galleryname string
param tags object
resource aig 'Microsoft.Compute/galleries@2022-03-03' = {
  location: location
  name: galleryname
  tags: tags
  properties: {
    description: 'Monitoring gallery'
  }
}

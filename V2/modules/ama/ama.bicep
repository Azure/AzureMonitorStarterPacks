param serverOs string
param serverId string
param serverType string
param location string

//var serverRG=split(serverId,'/')[4]
var serverName=split(serverId,'/')[8]


module vmlinux './amaLinux.bicep'= if(serverType=='vm' && serverOs=='Linux') {
  name: 'amaLinux'
  params: {
    location: location
    vmName: serverName
  }
}
module vmWindows './amaWindows.bicep'= if(serverType=='vm' && serverOs=='Windows') {
  name: 'amaWindows'
  params: {
    location: location
    vmName: serverName
  }
}
module vmWindowsArc './amaWindows.bicep'= if(serverType=='arc' && serverOs=='Windows') {
  name: 'amaWindowsArc'
  params: {
    location: location
    vmName: serverName
  }
}
module vmLinuxArc './amaWindows.bicep'= if(serverType=='arc' && serverOs=='Linux') {
  name: 'amaLinuxArc'
  params: {
    location: location
    vmName: serverName
  }
}




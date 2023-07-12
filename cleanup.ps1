#remove log analytics - optional
#remove resource group or remove each component by Tag.
#remove policies
#ARG Query:
# resources
# | where isnotempty(tags.MonitorStarterPacks)
# | project ['id'], type
# | union (policyresources
# | where isnotempty(properties.metadata.MonitorStarterPacks)|
# project id,type=tostring(split(id,"/")[4]))


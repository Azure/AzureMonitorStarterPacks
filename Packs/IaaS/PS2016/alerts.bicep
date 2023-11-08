param location string
param workspaceId string
param AGId string
param packtag string
param solutionTag string
param solutionVersion string
param moduleprefix string = 'AMSP-Win-PS2016'
// Alert list

var alertlist = [
  {
      alertRuleDescription: 'Ensure the server is accessible.'
      alertRuleDisplayName:'Ensure the server is accessible.'
      alertRuleName:'AlertRule-PS-2016-1'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (83) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and (Source == \'Microsoft-Windows-PrintBRM\' or Source == \'PrintBrm\')'
    }
  {
      alertRuleDescription: 'Manually install the color profile.'
      alertRuleDisplayName:'Manually install the color profile.'
      alertRuleName:'AlertRule-PS-2016-2'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (360) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Retry printing or restart the print server.'
      alertRuleDisplayName:'Retry printing or restart the print server.'
      alertRuleName:'AlertRule-PS-2016-3'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (701,702,703,704) and EventLog == \'Microsoft-Windows-PrintService/Operational!*\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Install the Printer Driver.'
      alertRuleDisplayName:'Install the Printer Driver.'
      alertRuleName:'AlertRule-PS-2016-4'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (364,365,367) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Restart the print spooler fix sharing problems and check Group Policy.'
      alertRuleDisplayName:'Restart the print spooler fix sharing problems and check Group Policy.'
      alertRuleName:'AlertRule-PS-2016-5'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (315) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Restart the print spooler and unshare the printer.'
      alertRuleDisplayName:'Restart the print spooler and unshare the printer.'
      alertRuleName:'AlertRule-PS-2016-6'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (371) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Update the printer driver.'
      alertRuleDisplayName:'Update the printer driver.'
      alertRuleName:'AlertRule-PS-2016-7'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (356) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Check Group Policy and network connectivity.'
      alertRuleDisplayName:'Check Group Policy and network connectivity.'
      alertRuleName:'AlertRule-PS-2016-8'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (513,514) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Try again or install an updated printer driver.'
      alertRuleDisplayName:'Try again or install an updated printer driver.'
      alertRuleName:'AlertRule-PS-2016-9'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (600,601) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Check network connectivity and Group Policy.'
      alertRuleDisplayName:'Check network connectivity and Group Policy.'
      alertRuleName:'AlertRule-PS-2016-10'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (515,516,517,518,519,520) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
  {
      alertRuleDescription: 'Check resource availability.'
      alertRuleDisplayName:'Check resource availability.'
      alertRuleName:'AlertRule-PS-2016-11'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
alertType: 'rows'
      query: 'Event | where  EventID in (502,503,504,505,506,507,508,509,510,511,512) and EventLog == \'Microsoft-Windows-PrintService/Admin\' and Source == \'Microsoft-Windows-PrintService\''
    }
]

module alertsnew '../../../modules/alerts/alerts.bicep' = {
  name: '${moduleprefix}-Alerts'
  params: {
    alertlist: alertlist
    AGId: AGId
    location: location
    moduleprefix: moduleprefix
    packtag: packtag
    solutionTag: solutionTag
    solutionVersion: solutionVersion
    workspaceId: workspaceId
  }
}

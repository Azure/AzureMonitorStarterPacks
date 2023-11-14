param location string
param workspaceId string
param AGId string
param packtag string
param solutionTag string
param solutionVersion string
param moduleprefix string = 'AMSP-IIS2016'
// Alert list

var alertlist = [
  {
      alertRuleDescription: 'A server side include file has included itself or the maximum depth of server side includes has been exceeded'
      alertRuleDisplayName:'A server side include file has included itself or the maximum depth of server side includes has been exceeded'
      alertRuleName:'AlertRule-IIS-2012-1'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2221) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'Application Pool has an IdleTimeout equal to or greater than the PeriodicRestart time'
      alertRuleDisplayName:'Application Pool has an IdleTimeout equal to or greater than the PeriodicRestart time'
      alertRuleName:'AlertRule-IIS-2012-2'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5152) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  {
      alertRuleDescription: 'Application Pool worker process is unresponsive'
      alertRuleDisplayName:'Application Pool worker process is unresponsive'
      alertRuleName:'AlertRule-IIS-2012-3'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5010,5011,5012,5013) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  {
      alertRuleDescription: 'Application Pool worker process terminated unexpectedly'
      alertRuleDisplayName:'Application Pool worker process terminated unexpectedly'
      alertRuleName:'AlertRule-IIS-2012-4'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5009) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  {
      alertRuleDescription: 'ASP application error occurred'
      alertRuleDisplayName:'ASP application error occurred'
      alertRuleName:'AlertRule-IIS-2012-5'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (500,499,23,22,21,20,19,18,17,16,9,8,7,6,5) and EventLog == \'Application\' and Source == \'Active Server Pages\''
    }
  {
      alertRuleDescription: 'HTTP control channel for the WWW Service did not open'
      alertRuleDisplayName:'HTTP control channel for the WWW Service did not open'
      alertRuleName:'AlertRule-IIS-2012-6'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1037) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
    }
  {
      alertRuleDescription: 'HTTP Server could not create a client connection object for user'
      alertRuleDisplayName:'HTTP Server could not create a client connection object for user'
      alertRuleName:'AlertRule-IIS-2012-7'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2208) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'HTTP Server could not create the main connection socket'
      alertRuleDisplayName:'HTTP Server could not create the main connection socket'
      alertRuleName:'AlertRule-IIS-2012-8'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2206) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'HTTP Server could not initialize its security'
      alertRuleDisplayName:'HTTP Server could not initialize its security'
      alertRuleName:'AlertRule-IIS-2012-9'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2201) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'HTTP Server could not initialize the socket library'
      alertRuleDisplayName:'HTTP Server could not initialize the socket library'
      alertRuleName:'AlertRule-IIS-2012-10'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2203) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'HTTP Server was unable to initialize due to a shortage of available memory'
      alertRuleDisplayName:'HTTP Server was unable to initialize due to a shortage of available memory'
      alertRuleName:'AlertRule-IIS-2012-11'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2204) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'ISAPI application error detected'
      alertRuleDisplayName:'ISAPI application error detected'
      alertRuleName:'AlertRule-IIS-2012-12'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2274,2268,2220,2219,2214) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'Job object associated with the application pool encountered an error'
      alertRuleDisplayName:'Job object associated with the application pool encountered an error'
      alertRuleName:'AlertRule-IIS-2012-13'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5088,5061,5060) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  {
      alertRuleDescription: 'Module has an invalid precondition'
      alertRuleDisplayName:'Module has an invalid precondition'
      alertRuleName:'AlertRule-IIS-2012-14'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2296) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'Module registration error detected (failed to find RegisterModule entrypoint)'
      alertRuleDisplayName:'Module registration error detected (failed to find RegisterModule entrypoint)'
      alertRuleName:'AlertRule-IIS-2012-15'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2295) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'Module registration error detected (module returned an error during registration)'
      alertRuleDisplayName:'Module registration error detected (module returned an error during registration)'
      alertRuleName:'AlertRule-IIS-2012-16'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2293) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'Only one type of logging can be enabled at a time'
      alertRuleDisplayName:'Only one type of logging can be enabled at a time'
      alertRuleName:'AlertRule-IIS-2012-17'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1133) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
    }
  {
      alertRuleDescription: 'SF_NOTIFY_READ_RAW_DATA filter notification is not supported in IIS 8'
      alertRuleDisplayName:'SF_NOTIFY_READ_RAW_DATA filter notification is not supported in IIS 8'
      alertRuleName:'AlertRule-IIS-2012-18'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2261) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The configuration manager for WAS did not initialize'
      alertRuleDisplayName:'The configuration manager for WAS did not initialize'
      alertRuleName:'AlertRule-IIS-2012-19'
      alertRuleSeverity:2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5036) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  {
      alertRuleDescription: 'The directory specified for caching compressed content is invalid'
      alertRuleDisplayName:'The directory specified for caching compressed content is invalid'
      alertRuleName:'AlertRule-IIS-2012-20'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2264) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The Global Modules list is empty'
      alertRuleDisplayName:'The Global Modules list is empty'
      alertRuleName:'AlertRule-IIS-2012-21'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2298) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The HTTP server encountered an error processing the server side include file'
      alertRuleDisplayName:'The HTTP server encountered an error processing the server side include file'
      alertRuleName:'AlertRule-IIS-2012-22'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2218) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The server failed to close client connections to URLs during shutdown'
      alertRuleDisplayName:'The server failed to close client connections to URLs during shutdown'
      alertRuleName:'AlertRule-IIS-2012-23'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2258) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The server was unable to acquire a license for a SSL connection'
      alertRuleDisplayName:'The server was unable to acquire a license for a SSL connection'
      alertRuleName:'AlertRule-IIS-2012-24'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2227) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The server was unable to allocate a buffer to read a file'
      alertRuleDisplayName:'The server was unable to allocate a buffer to read a file'
      alertRuleName:'AlertRule-IIS-2012-25'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2233) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'The server was unable to read a file'
      alertRuleDisplayName:'The server was unable to read a file'
      alertRuleName:'AlertRule-IIS-2012-26'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2226,2230,2231,2232) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  {
      alertRuleDescription: 'WAS detected invalid configuration data'
      alertRuleDisplayName:'WAS detected invalid configuration data'
      alertRuleName:'AlertRule-IIS-2012-27'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5174,5179,5180) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
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



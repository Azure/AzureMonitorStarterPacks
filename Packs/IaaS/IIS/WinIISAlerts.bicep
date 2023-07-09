param location string
param workspaceId string
param AGId string
param packtag string

var moduleprefix = 'AMSP-Win-IIS'
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
      query: 'Event | where  EventID in (2221) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
    }
  // {
  //     alertRuleDescription: 'Application Pool has an IdleTimeout equal to or greater than the PeriodicRestart time'
  //     alertRuleDisplayName:'Application Pool has an IdleTimeout equal to or greater than the PeriodicRestart time'
  //     alertRuleName:'AlertRule-IIS-2012-2'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5152) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Application Pool worker process is unresponsive'
  //     alertRuleDisplayName:'Application Pool worker process is unresponsive'
  //     alertRuleName:'AlertRule-IIS-2012-3'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5010,5011,5012,5013) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Application Pool worker process terminated unexpectedly'
  //     alertRuleDisplayName:'Application Pool worker process terminated unexpectedly'
  //     alertRuleName:'AlertRule-IIS-2012-4'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5009) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'ASP application error occurred'
  //     alertRuleDisplayName:'ASP application error occurred'
  //     alertRuleName:'AlertRule-IIS-2012-5'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (500,499,23,22,21,20,19,18,17,16,9,8,7,6,5) and EventLog == \'Application\' and Source == \'Active Server Pages\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP control channel for the WWW Service did not open'
  //     alertRuleDisplayName:'HTTP control channel for the WWW Service did not open'
  //     alertRuleName:'AlertRule-IIS-2012-6'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1037) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP Server could not create a client connection object for user'
  //     alertRuleDisplayName:'HTTP Server could not create a client connection object for user'
  //     alertRuleName:'AlertRule-IIS-2012-7'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2208) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP Server could not create the main connection socket'
  //     alertRuleDisplayName:'HTTP Server could not create the main connection socket'
  //     alertRuleName:'AlertRule-IIS-2012-8'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2206) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP Server could not initialize its security'
  //     alertRuleDisplayName:'HTTP Server could not initialize its security'
  //     alertRuleName:'AlertRule-IIS-2012-9'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2201) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP Server could not initialize the socket library'
  //     alertRuleDisplayName:'HTTP Server could not initialize the socket library'
  //     alertRuleName:'AlertRule-IIS-2012-10'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2203) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'HTTP Server was unable to initialize due to a shortage of available memory'
  //     alertRuleDisplayName:'HTTP Server was unable to initialize due to a shortage of available memory'
  //     alertRuleName:'AlertRule-IIS-2012-11'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2204) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'ISAPI application error detected'
  //     alertRuleDisplayName:'ISAPI application error detected'
  //     alertRuleName:'AlertRule-IIS-2012-12'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2274,2268,2220,2219,2214) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Job object associated with the application pool encountered an error'
  //     alertRuleDisplayName:'Job object associated with the application pool encountered an error'
  //     alertRuleName:'AlertRule-IIS-2012-13'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5088,5061,5060) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Module has an invalid precondition'
  //     alertRuleDisplayName:'Module has an invalid precondition'
  //     alertRuleName:'AlertRule-IIS-2012-14'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2296) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Module registration error detected (failed to find RegisterModule entrypoint)'
  //     alertRuleDisplayName:'Module registration error detected (failed to find RegisterModule entrypoint)'
  //     alertRuleName:'AlertRule-IIS-2012-15'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2295) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Module registration error detected (module returned an error during registration)'
  //     alertRuleDisplayName:'Module registration error detected (module returned an error during registration)'
  //     alertRuleName:'AlertRule-IIS-2012-16'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2293) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Only one type of logging can be enabled at a time'
  //     alertRuleDisplayName:'Only one type of logging can be enabled at a time'
  //     alertRuleName:'AlertRule-IIS-2012-17'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1133) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'SF_NOTIFY_READ_RAW_DATA filter notification is not supported in IIS 8'
  //     alertRuleDisplayName:'SF_NOTIFY_READ_RAW_DATA filter notification is not supported in IIS 8'
  //     alertRuleName:'AlertRule-IIS-2012-18'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2261) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The configuration manager for WAS did not initialize'
  //     alertRuleDisplayName:'The configuration manager for WAS did not initialize'
  //     alertRuleName:'AlertRule-IIS-2012-19'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5036) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'The directory specified for caching compressed content is invalid'
  //     alertRuleDisplayName:'The directory specified for caching compressed content is invalid'
  //     alertRuleName:'AlertRule-IIS-2012-20'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2264) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The Global Modules list is empty'
  //     alertRuleDisplayName:'The Global Modules list is empty'
  //     alertRuleName:'AlertRule-IIS-2012-21'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2298) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The HTTP server encountered an error processing the server side include file'
  //     alertRuleDisplayName:'The HTTP server encountered an error processing the server side include file'
  //     alertRuleName:'AlertRule-IIS-2012-22'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2218) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The server failed to close client connections to URLs during shutdown'
  //     alertRuleDisplayName:'The server failed to close client connections to URLs during shutdown'
  //     alertRuleName:'AlertRule-IIS-2012-23'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2258) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The server was unable to acquire a license for a SSL connection'
  //     alertRuleDisplayName:'The server was unable to acquire a license for a SSL connection'
  //     alertRuleName:'AlertRule-IIS-2012-24'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2227) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The server was unable to allocate a buffer to read a file'
  //     alertRuleDisplayName:'The server was unable to allocate a buffer to read a file'
  //     alertRuleName:'AlertRule-IIS-2012-25'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2233) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'The server was unable to read a file'
  //     alertRuleDisplayName:'The server was unable to read a file'
  //     alertRuleName:'AlertRule-IIS-2012-26'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2226,2230,2231,2232) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  {
      alertRuleDescription: 'WAS detected invalid configuration data'
      alertRuleDisplayName:'WAS detected invalid configuration data'
      alertRuleName:'AlertRule-IIS-2012-27'
      alertRuleSeverity:1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      query: 'Event | where  EventID in (5174,5179,5180) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
    }
  // {
  //     alertRuleDescription: 'WAS did not apply configuration changes to application pool'
  //     alertRuleDisplayName:'WAS did not apply configuration changes to application pool'
  //     alertRuleName:'AlertRule-IIS-2012-28'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5085) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS did not run the automatic shutdown executable for application pool'
  //     alertRuleDisplayName:'WAS did not run the automatic shutdown executable for application pool'
  //     alertRuleName:'AlertRule-IIS-2012-29'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5054,5091) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered a failure requesting IIS configuration store change notifications'
  //     alertRuleDisplayName:'WAS encountered a failure requesting IIS configuration store change notifications'
  //     alertRuleName:'AlertRule-IIS-2012-30'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5063) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered a failure while setting the affinity mask of an application pool'
  //     alertRuleDisplayName:'WAS encountered a failure while setting the affinity mask of an application pool'
  //     alertRuleName:'AlertRule-IIS-2012-31'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5058) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered an error attempting to configure centralized logging'
  //     alertRuleDisplayName:'WAS encountered an error attempting to configure centralized logging'
  //     alertRuleName:'AlertRule-IIS-2012-32'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5174,5179,5180) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered an error attempting to look up the built in IIS_IUSRS group'
  //     alertRuleDisplayName:'WAS encountered an error attempting to look up the built in IIS_IUSRS group'
  //     alertRuleName:'AlertRule-IIS-2012-33'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5085) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered an error trying to read configuration'
  //     alertRuleDisplayName:'WAS encountered an error trying to read configuration'
  //     alertRuleName:'AlertRule-IIS-2012-34'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5054,5091) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS encountered an internal error in while managing a worker process'
  //     alertRuleDisplayName:'WAS encountered an internal error in while managing a worker process'
  //     alertRuleName:'AlertRule-IIS-2012-35'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5063) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS failed to create application pool'
  //     alertRuleDisplayName:'WAS failed to create application pool'
  //     alertRuleName:'AlertRule-IIS-2012-36'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5058) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS failed to issue recycle request to application pool'
  //     alertRuleDisplayName:'WAS failed to issue recycle request to application pool'
  //     alertRuleName:'AlertRule-IIS-2012-37'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5066) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS is stopping because it encountered an error'
  //     alertRuleDisplayName:'WAS is stopping because it encountered an error'
  //     alertRuleName:'AlertRule-IIS-2012-38'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5005) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS received a change notification but was unable to process it correctly'
  //     alertRuleDisplayName:'WAS received a change notification but was unable to process it correctly'
  //     alertRuleName:'AlertRule-IIS-2012-39'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5053) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WAS terminated unexpectedly and the system was not configured to restart it'
  //     alertRuleDisplayName: 'WAS terminated unexpectedly and the system was not configured to restart it'
  //     alertRuleName:'AlertRule-IIS-2012-40'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5030) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Worker process failed to initialize communication with the W3SVC service and therefore could not be started'
  //     alertRuleDisplayName:'Worker process failed to initialize communication with the W3SVC service and therefore could not be started'
  //     alertRuleName:'AlertRule-IIS-2012-41'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2281) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Worker process for application pool encountered an error while trying to read global module configuration'
  //     alertRuleDisplayName:'Worker process for application pool encountered an error while trying to read global module configuration'
  //     alertRuleName:'AlertRule-IIS-2012-42'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (2297) and EventLog == \'Application\' and Source == \'Microsoft-Windows-IIS-W3SVC-WP\''
  //   }
  // {
  //     alertRuleDescription: 'Worker process serving an application pool reported a failure'
  //     alertRuleDisplayName:'Worker process serving an application pool reported a failure'
  //     alertRuleName:'AlertRule-IIS-2012-43'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5039) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Worker process serving application pool was orphaned'
  //     alertRuleDisplayName:'Worker process serving application pool was orphaned'
  //     alertRuleName:'AlertRule-IIS-2012-44'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5015) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'Worker process serving the application pool is no longer trusted by WAS'
  //     alertRuleDisplayName:'Worker process serving the application pool is no longer trusted by WAS'
  //     alertRuleName:'AlertRule-IIS-2012-45'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5127) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }
  // {
  //     alertRuleDescription: 'WWW Service did not initialize the HTTP driver and was unable to start'
  //     alertRuleDisplayName:'WWW Service did not initialize the HTTP driver and was unable to start'
  //     alertRuleName:'AlertRule-IIS-2012-46'
  //     alertRuleSeverity:2
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1173) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service encountered an error when it tried to secure the handle of the application pool'
  //     alertRuleDisplayName:'WWW service encountered an error when it tried to secure the handle of the application pool'
  //     alertRuleName:'AlertRule-IIS-2012-47'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1026) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service failed to configure the centralized W3C logging properties'
  //     alertRuleDisplayName:'WWW service failed to configure the centralized W3C logging properties'
  //     alertRuleName:'AlertRule-IIS-2012-48'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1135,1134) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW Service failed to configure the HTTP.SYS control channel property'
  //     alertRuleDisplayName:'WWW Service failed to configure the HTTP.SYS control channel property'
  //     alertRuleName:'AlertRule-IIS-2012-49'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1020) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service failed to configure the logging properties for the HTTP control channel'
  //     alertRuleDisplayName:'WWW service failed to configure the logging properties for the HTTP control channel'
  //     alertRuleName:'AlertRule-IIS-2012-50'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1062) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW Service failed to copy a change notification for processing'
  //     alertRuleDisplayName:'WWW Service failed to copy a change notification for processing'
  //     alertRuleName:'AlertRule-IIS-2012-51'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1126) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW Service failed to enable end point sharing for the HTTP control channel'
  //     alertRuleDisplayName:'WWW Service failed to enable end point sharing for the HTTP control channel'
  //     alertRuleName:'AlertRule-IIS-2012-52'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1175) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service failed to enable global bandwidth throttling'
  //     alertRuleDisplayName:'WWW service failed to enable global bandwidth throttling'
  //     alertRuleName:'AlertRule-IIS-2012-53'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1071,1073) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service failed to properly configure the application pool queue length'
  //     alertRuleDisplayName:'WWW service failed to properly configure the application pool queue length'
  //     alertRuleName:'AlertRule-IIS-2012-54'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1087) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service failed to properly configure the load balancer capabilities on application pool'
  //     alertRuleDisplayName:'WWW service failed to properly configure the load balancer capabilities on application pool'
  //     alertRuleName:'AlertRule-IIS-2012-55'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (1086) and EventLog == \'System\' and Source == \'Microsoft-Windows-IIS-W3SVC\''
  //   }
  // {
  //     alertRuleDescription: 'WWW service property failed range validation'
  //     alertRuleDisplayName:'WWW service property failed range validation'
  //     alertRuleName:'AlertRule-IIS-2012-56'
  //     alertRuleSeverity:1
  //     autoMitigate: true
  //     evaluationFrequency: 'PT15M'
  //     windowSize: 'PT15M'
  //     query: 'Event | where  EventID in (5067) and EventLog == \'System\' and Source == \'Microsoft-Windows-WAS\''
  //   }

]


module Alerts '../../../modules/alerts/scheduledqueryrule.bicep' = [for alert in alertlist:  {
  name: '${moduleprefix}-${alert.alertRuleName}'
  params: {
    location: location
    actionGroupResourceId: AGId
    alertRuleDescription: alert.alertRuleDescription
    alertRuleDisplayName: '${moduleprefix}-${alert.alertRuleDisplayName}'
    alertRuleName: '${moduleprefix}-${alert.alertRuleName}'
    alertRuleSeverity: alert.alertRuleSeverity
    autoMitigate: alert.autoMitigate
    evaluationFrequency: alert.evaluationFrequency
    windowSize: alert.windowSize
    scope: workspaceId
    query: alert.query
    packtag: packtag
  }
}]

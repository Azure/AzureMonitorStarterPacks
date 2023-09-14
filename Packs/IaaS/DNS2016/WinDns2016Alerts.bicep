param location string
param workspaceId string
param AGId string
param packtag string
param solutionTag string
param solutionVersion string
param moduleprefix string = 'AMSP-Win-Dns-2016'
// Alert list  

var alertlist = [
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.DependencyFailed'
      alertRuleName: 'AlertRule-Dns-2016-10'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (10) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.FileOpenError'
      alertRuleName: 'AlertRule-Dns-2016-1000'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1000) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.CouldNotOpenDatabase'
      alertRuleName: 'AlertRule-Dns-2016-1004'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1004) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.BootFileNotFound'
      alertRuleName: 'AlertRule-Dns-2016-1200'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1200) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.ZoneCreationFailed'
      alertRuleName: 'AlertRule-Dns-2016-1201'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1201) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.NoForwardingAddresses'
      alertRuleName: 'AlertRule-Dns-2016-1203'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1203) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.WINSConnector.Initialize.Failed'
      alertRuleName: 'AlertRule-Dns-2016-131'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (131) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Remote Procedure Calls.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.RPC.Initialize.Failed'
      alertRuleName: 'AlertRule-Dns-2016-140'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (140) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.PluginInitFailed'
      alertRuleName: 'AlertRule-Dns-2016-150'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (150) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.DomainNodeCreationError'
      alertRuleName: 'AlertRule-Dns-2016-1540'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1540) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.OpenFailed'
      alertRuleName: 'AlertRule-Dns-2016-4000'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4000) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.LoadFailed'
      alertRuleName: 'AlertRule-Dns-2016-4006'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4006) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.OpenPartitionFailed'
      alertRuleName: 'AlertRule-Dns-2016-4007'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4007) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.RecordLoadFailed'
      alertRuleName: 'AlertRule-Dns-2016-4010'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4010) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.WriteFailed'
      alertRuleName: 'AlertRule-Dns-2016-4011'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4011) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.WriteTimeout'
      alertRuleName: 'AlertRule-Dns-2016-4012'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4012) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.SecurityInterfaceFailed'
      alertRuleName: 'AlertRule-Dns-2016-4014'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4014) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.InterfaceError'
      alertRuleName: 'AlertRule-Dns-2016-4015'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4015) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.LDAPTimeout'
      alertRuleName: 'AlertRule-Dns-2016-4016'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4016) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.DNSAdminsError'
      alertRuleName: 'AlertRule-Dns-2016-4017'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4017) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.OpenSocketForAddress'
      alertRuleName: 'AlertRule-Dns-2016-408'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (408) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.UpdateListenAddresses'
      alertRuleName: 'AlertRule-Dns-2016-409'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (409) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.InvalidListenAddresses'
      alertRuleName: 'AlertRule-Dns-2016-410'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (410) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.SingleLabelHostname'
      alertRuleName: 'AlertRule-Dns-2016-414'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (414) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.FSMOUnavailable'
      alertRuleName: 'AlertRule-Dns-2016-4510'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4510) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.DeleteError'
      alertRuleName: 'AlertRule-Dns-2016-4511'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4511) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.PartitionCreateError'
      alertRuleName: 'AlertRule-Dns-2016-4512'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4512) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.InvalidZoneType'
      alertRuleName: 'AlertRule-Dns-2016-501'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (501) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.NoZoneFile'
      alertRuleName: 'AlertRule-Dns-2016-502'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (502) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.SecondaryRequiresMasters'
      alertRuleName: 'AlertRule-Dns-2016-503'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (503) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.RegZoneCreationFailed'
      alertRuleName: 'AlertRule-Dns-2016-504'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (504) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.Memory.Warning'
      alertRuleName: 'AlertRule-Dns-2016-5051'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (5051) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.ZoneExpiration'
      alertRuleName: 'AlertRule-Dns-2016-6527'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (6527) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.UpdateDSPeersFailure'
      alertRuleName: 'AlertRule-Dns-2016-6702'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (6702) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Root Hints.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.RootHints.NoRootNameServer'
      alertRuleName: 'AlertRule-Dns-2016-706'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (706) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.ConnectionError'
      alertRuleName: 'AlertRule-Dns-2016-7060'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7060) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNSSEC Trust Anchors Zone Loading'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.DNSSEC.TALoadFailed'
      alertRuleName: 'AlertRule-Dns-2016-7616'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7616) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNSSEC Trust Point'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.DNSSEC.TPDeleted'
      alertRuleName: 'AlertRule-Dns-2016-7636'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7636) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNSSEC Trust Anchor'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.DNSSEC.InvalidTA'
      alertRuleName: 'AlertRule-Dns-2016-7642'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7642) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNSSEC Active Refresh Query'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.DNSSEC.TARefreshFailed'
      alertRuleName: 'AlertRule-Dns-2016-7644'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7644) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNSSEC Zone Unsign'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.DNSSEC.ZoneUnSignFailure'
      alertRuleName: 'AlertRule-Dns-2016-777'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (777) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.ThreadCreationFailed'
      alertRuleName: 'AlertRule-Dns-2016-111'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (111,6533) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.BackgroundLoadFailure'
      alertRuleName: 'AlertRule-Dns-2016-4018'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4018,4019) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.EnlistmentFailed'
      alertRuleName: 'AlertRule-Dns-2016-4513'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4513,4514) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Active Directory Integration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.ADI.RetryableZoneOperationFailed'
      alertRuleName: 'AlertRule-Dns-2016-4520'
      alertRuleSeverity: 1
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (4520,4521) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Root Hints.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.RootHints.CacheFileError'
      alertRuleName: 'AlertRule-Dns-2016-707'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (707,1003) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for DNS Server EDNS options.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.Server.EDNS0.ZoneTransfer.OptionInvalid'
      alertRuleName: 'AlertRule-Dns-2016-7692'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7692,790) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Client Subnet.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.ClientSubnet.LoadFail'
      alertRuleName: 'AlertRule-Dns-2016-796'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (796,799) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.RegistryOperationFailed'
      alertRuleName: 'AlertRule-Dns-2016-2200'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (2200,2202,2203) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.Memory.Error'
      alertRuleName: 'AlertRule-Dns-2016-7502'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (7502,7503,7504) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Server Level Policies.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Rules.Policy.ServerLevel.LoadFail'
      alertRuleName: 'AlertRule-Dns-2016-792'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (792,795,797) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.FileError'
      alertRuleName: 'AlertRule-Dns-2016-1001'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (1001,1008,3151,3152,3153) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for the DNS Service.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Service.SocketFailure'
      alertRuleName: 'AlertRule-Dns-2016-403'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (403,404,405,406,407) and EventLog == \'DNS Server\''
  }
  {
      alertRuleDescription: 'Alert generating rule for Configuration.'
      alertRuleDisplayName: 'Microsoft.Windows.DNSServer.2016.Configuration.InvalidRegistrySetting'
      alertRuleName: 'AlertRule-Dns-2016-500'
      alertRuleSeverity: 2
      autoMitigate: true
      evaluationFrequency: 'PT15M'
      windowSize: 'PT15M'
      alertType: 'rows'
      query: 'Event | where  EventID in (500,505,506,507,2204) and EventLog == \'DNS Server\''
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



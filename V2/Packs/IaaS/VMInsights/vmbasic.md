# Monitoring Starter Pack

## Basic VM Monitoring

Agent Policy Installation (Initiative):

https://portal.azure.com/#view/Microsoft_Azure_Policy/InitiativeDetailBlade/id/%2Fproviders%2FMicrosoft.Authorization%2FpolicySetDefinitions%2F9575b8b7-78ab-4281-b53b-d3c1ace2260b/scopes~/%5B%22%2Fsubscriptions%2F6c64f9ed-88d2-4598-8de6-7a9527dc16ca%22%2C%22%2Fsubscriptions%2Fb1e924f9-d16f-4260-a3c8-ff1ee462956b%22%5D 

### Performance

Alert me if:

- Percentage CPU is greater than 80 %
- Available Memory Bytes is less than 1 GB
- Data Disk IOPS Consumed Percentage is greater than 95 %
- OS Disk IOPS Consumed Percentage is greater than 95 %
- Network In Total is greater than 500 GB
- Network Out Total is greater than 200 GB

### Availability

Alert me if:
    VM is failed in the platform or stopped altogether (maybe)
    VM is just not responsive from a general network standpoint.
    key Services are stopped (or not responding)

## Basic Networking Monitoring

    Basic scenarios:
        From azure to on-prem
        VPN/ER GW events
        NSG events
        Flowlog...
        
## Dashboard

    Basic dashboard with the following metrics:
        CPU
        Memory
        Disk
        Network
        Availability
        
        Alerts 
        Events

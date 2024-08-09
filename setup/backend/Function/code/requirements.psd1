# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    #'Az' = '10.*' # need to reduce this to make it for a faster start
    'Az.Accounts' = '2.10.1'
    'Az.Resources' = '6.12.1'
    'Az.ResourceGraph' = '0.13.0'
    'Az.Monitor' = '4.5.0'
    'Az.PolicyInsights' = '1.6.2'
    'Az.ConnectedMachine' = '0.5.2'
    'Az.Compute' = '6.2.0'
    'Az.OperationalInsights' = '3.2.1'
}

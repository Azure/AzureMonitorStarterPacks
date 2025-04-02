# This file enables modules to be automatically managed by the Functions service.
# See https://aka.ms/functionsmanageddependency for additional information.
#
@{
    # For latest supported version, go to 'https://www.powershellgallery.com/packages/Az'. 
    # To use the Az module in your function app, please uncomment the line below.
    #'Az' = '10.*' # need to reduce this to make it for a faster start
    'Az.Accounts' = '4.0.2'
    'Az.Resources' = '7.9.0'
    'Az.ResourceGraph' = '1.2.0'
    'Az.Monitor' = '6.0.1'
    'Az.PolicyInsights' = '1.7.1'
    'Az.ConnectedMachine' = '1.1.1'
    'Az.Compute' = '9.1.0'
    'Az.OperationalInsights' = '3.3.0'
}

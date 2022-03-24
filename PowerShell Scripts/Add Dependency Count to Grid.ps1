#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000); Module = 'Applications' }

## Script Start
#----------------------------------------------------------------

<#

## USE CASE ## 
Add a count of the number of Apps that use this App as their Dependency to the Grid Column 'CustomInt1'

## SOLUTION ## 
User a script to update the Dependency count of all Applications each time a Dependency is added or removed

## STEPS ## 
1. Go To : Administration\Applications\Grid Config
    Make CustomInt1 visible and name it e.g. 'Dependency Of Count'
        Note: Fields other than CustomInt1 can be used but require the script to be edited            

2. Go To : Administration\Applications\PowerShell Scripts
    1. Create an App PowerShell script using the code below. 

    2. Set the Trigger for this Script to:
        Trigger: Dependency
        Sub Trigger: Added or Removed

#>



## CODE START ##
 
## Get a list of All (accepted) Applications Ids
$appIds = Get-MSApplications -All -IdsOnly


## Datamine the Apps for their Dependencies
$dependsTier = New-MSDataminingTier -Module Dependencies -Fields @('InstanceId')
$dmr = Get-MSDataminingReport -Module Applications -Ids $appIds -Fields @('Id') -AdditionalTiers @($dependsTier)
if(-not $dmr.Status.IsSuccess){ return }


## Count the number of 'parent' Apps a Dependency has
$appParentCount = @{}
foreach($id in $appIds) { $appParentCount.Add($id, 0) } ## Init Hash to hold counters

foreach($row in $dmr.Data.Rows){
    if([string]::IsNullOrWhiteSpace($row.Dependencies_InstanceId)){ continue }
    if(-not $appParentCount.ContainsKey($row.Dependencies_InstanceId)) { continue }

    $appParentCount[$row.Dependencies_InstanceId] += 1
}


## Create an Update array to send back to MS
$appUpdates = @()
foreach($appId in $appParentCount.Keys){
    $appUpdates += @{ Id = $appId; CustomInt1 = $appParentCount[$appId] }
}

## Update MS with the new Dependency info
Update-MSApplications -Updates $appUpdates | Out-Null
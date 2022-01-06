#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

<#

------------------------
 DMR Structure
------------------------  
  - TopTier
   - AdditionalTiers
   - ReadinessTiers
   - ExpressionColumns
   - BlueprintColumns

  - DataSource
  - HeaderFormat
  - FilterExpression
  - SortExpression

------------------------
 DMR Params
------------------------  

-HeaderFormat <string>
 By default, the dmr will return the internal column name prefixed by the module it belongs too e.g. "Applications_AppVendor"
 Setting the HeaderFormat to DisplayName will rename the columns to the names as in the UI. e.g. "Vendor"

--DataSource <object>
 A DMR can be called using -All or -Ids to scope the Apps,User,Devices etc that will be included in the report. However it's possible to create a more complex scope using 'New-MSDataminingDataSource' 
 New-MSDataminingDataSource allows for Process, Status, Blueprint and DeployUnit filters. It returns an DataSource object that can be passed to the DMR as its scope


------------------------
  Result Object
------------------------
$dmr = Get-MSDataminingReport ...
    $dmr.Status     # Info on was the report successful and the error message if it was not. Also Row/Column counts
    $dmr.Data       # The Report data. Use the $dmr.Data.Rows to iterate over the report data
    $dmr.Columns    # Info on the column name, and alt names, module, and data type

#>

#==============================================================================================

# Ex 1. Create DMR in PowerShell Verbose

## Get a list of Apps and include a count of Users requiring those Apps
$appsTier = New-MSDataminingTier -Module Applications -Fields @("AppId", "AppVendor", "AppName", "AppVersion", "Process", "SubProcess")
$userReadinessTier = New-MSReadinessTier -Module UserMigrations -Fields @("Total") 
$dmr = Get-MSDataminingReport -Module Applications -All $true -TopTier $appsTier -ReadinessTiers @($userReadinessTier) -HeaderFormat DisplayName 

$dmr.Status

#==============================================================================================

# Ex 2. Create DMR in PowerShell Inline

## Same report as Ex 1 but all in one line
## Get a list of Apps and include a count of Users requiring those Apps
$dmr = Get-MSDataminingReport -Module Applications -All $true -Fields ("AppId", "AppVendor", "AppName", "AppVersion", "Process", "SubProcess") -ReadinessTiers @((New-MSReadinessTier -Module UserMigrations -Fields @("Total"))) -HeaderFormat DisplayName

$dmr.Status
New-MSDataminingDataSource
#==============================================================================================

# Ex 3. Use existing DMR saved in the UI

## A DMR that is defined in the UI and saved there can be called in PowerShell by using its Id. The Id is shown in the Window Title of the DRM report. 
$dmr = Get-MSDataminingReportById -ReportId 9

$dmr.Status
$dmr.Data | Format-List

## It's possible to supply your own Ids/DataSource to run against this saved DMR. 
$customDataSource = New-MSDataminingDataSource -BlueprintIds @(1,2,3) -ExcludeProcesses @("Live", "Retired")
$dmr = Get-MSDataminingReportById -ReportId 9 -DataSource $customDataSource

$dmr.Status
$dmr.Data | Format-List

#==============================================================================================
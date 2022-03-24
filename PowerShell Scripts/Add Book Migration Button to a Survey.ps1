#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000); Module = 'UserMigrations' }

## Script Start
#----------------------------------------------------------------

<#

## USE CASE ## 
Add a Button to a Survey that allows a User/BA to pick the Migration Slot of a User

## ACTIONS ##
Basic validation that the User is in a DU and the booking links have not expired
Checks if the Users current Slot is locked and if so, unlocks it
Redirects the User to the booking page.

## STEPS ## 
1. Go To : Administration\User Migrations\PowerShell Scripts
    Create an App PowerShell script using the code below. 
    Take note of the ScriptId

2. Go To : Administration\User Migrations\Surveys
    Add a 'Script Button' to your survey
    Set 'Special Control Test' : e.g. 'Change User's Slot' 
    Set 'Special Control Args' : ScriptId: XX;  Where XX is the ScriptId from step 1. 

#>



## CODE START ##

## Get the UserMigrationId from the Script Args
$migrationId = $ScriptArgs.Items[0] 

## Datamine the User for their DU, SelfSchedule Url, and Schedule Locked Status
$selfScheduleTier = New-MSDataminingTier -Module SelfSchedule -Fields @('SelfScheduleIsLocked', 'LinkExpiryDate', 'ScheduleUrl')
$dmr = Get-MSDataminingReport -Module UserMigrations -Ids @($migrationId) -Fields @('Id', 'DeployUnitId') -AdditionalTiers @($selfScheduleTier)

## DMR Error?
if($dmr.Status.IsSuccess -eq $false){
    New-MSApiResult -Header "Error" -Content $dmr.Status.ErrorMessage -Status Error
    return
}

## User not in a DU?
if([string]::IsNullOrWhiteSpace($dmr.Data.Rows[0].UserMigrations_DeployUnitId)){
    New-MSApiResult -Header "Error" -Content "User is not a DU" -Status Error
    return
}

## Self-Schedule Links have expired
if($dmr.Data.Rows[0].SelfSchedule_LinkExpiryDate -lt (Get-Date)){
    New-MSApiResult -Header "Error" -Content "Self-Schedule Links have expired" -Status Error
    return
}

## Unlock Slot if it's locked
if($dmr.Data.Rows[0].SelfSchedule_SelfScheduleIsLocked -eq $true){
    $duId = $dmr.Data.Rows[0].UserMigrations_DeployUnitId
    Update-MSDeployUnitMigrationSlots -DeployUnitId $duId -InstanceIds $migrationId -IsLocked $false | Out-Null
}


## Return the SelfSchedule Url as the RedirectUrl
$redirectUrl = $dmr.Data.Rows[0].SelfSchedule_ScheduleUrl
New-MSApiResult -Header "SelfSchedule" -Status Success -RedirectUrl $redirectUrl

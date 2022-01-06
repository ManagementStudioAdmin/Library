#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000, 1001, 1002); Module = 'UserMigrations' }

## Script Start
#----------------------------------------------------------------

## This script can be used as the target of a Custom Button on the User Grid to unlock the Surveys of the selected Users.

## Unlock the Surveys of a given list of Users
$surveyIdToUnlock = 99
Update-MSLockSurveyForModuleItems -Module $ScriptArgs.Module -InstanceIds $ScriptArgs.Items -SurveyId $surveyIdToUnlock -UnLock | Out-Null

## An MSApiResult will show as a notification in the UI to the User that initiated the script
New-MSApiResult -Header "Survey Unlocked" -Content "$($ScriptArgs.Items.Count) Surveys Unlocked" -Status Success

#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000, 1001, 1002); Module = 'UserMigrations' }

## Script Start
#----------------------------------------------------------------

## This script can be used as the target of a Custom Button on DU-Survey to allow a SPOC to unlock User's migration slots for editing.


# Ex 1. Fixed Survey (i.e. Hard coded Survey Id)



# Ex 2. Any Survey (i.e. Use an argument from the clicked button to pick the Survey to unlock)
## Create one Button per Survey you want to be able to unlock from the main grid. In Args 1 of the button put the Survey Id to unlock
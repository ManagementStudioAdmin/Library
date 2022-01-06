#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000); AltItems = @(2000); Module = 'UserMigrations' }

## Script Start
#----------------------------------------------------------------

## This Script can be used as the Custom Button on a Survey Link Table.
## e.g. Display a list of Devices linked to a User and ask them to choose their Primary Device. 
##       Copy the Hostname of the selected Device to an arbitrary field 


## Where to write the selected Hostname
$writebackCustomFieldId = 9999

## Script Args holds the active User in 'Items' and the Selected Device in 'AltItems' 
$userId = $ScriptArgs.Items[0]
$deviceId = $ScriptArgs.AltItems[0]

## Get Hostname of selected Device
$hostname = Get-MSDevices -DeviceIds $deviceId | Select-Object -ExpandProperty HostName -First 1

## Save Hostname to a Custom Field
Update-MSUserMigrationsCustomFields -FieldId $writebackCustomFieldId -FieldInstanceId $userId -DataValue $hostname | Out-Null

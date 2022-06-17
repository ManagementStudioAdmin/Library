<#
---------------------------------------------------------------------------------------------------------------------------
If a device has a user link set as "Primary" affinity, add the user's email to the device as the Primary Contact
---------------------------------------------------------------------------------------------------------------------------

USE CASE
In a scenario where a device-based Deployment Units will be used, it's very useful to be able to email the devices. This can be
achieved if the device has a Pimary Contact email address.

SOLUTION
Look for the Primary User of each device. Add their email to the "Primary Contact" of each device

VERSION
v1.0 - 2022-05-20

Change Log:
v1.0 - Initial Release

---------------------------------------------------------------------------------------------------------------------------

USAGE
1.  Admin -> Devices -> Details Config -> Create new CustomProperty 
2.  Label this "User First Name"
3.  Make a note of which CustomProperty was used (eg. CustomProperty1)
4.  Admin -> Devices -> Powershell Scripts -> Devices -> Click here to add new item -> Script Name: "Machine Primary User"
5.  Paste in script (below)
6.  Set $Device_FirstName = 'CustomProperty1' (custom property used in step 1)
7.  Save
8.  With the column picker turn on column "Grant Access 2"
9.  Add the "Project Admin" role
10. Save
11. Run the script
12. Validate that the Primary User Email has been populated for Devices with a Primary User link
13. Add a Schedule to the "Schedule 1" column for that script
14. Save

---------------------------------------------------------------------------------------------------------------------------
#>

$Device_Email = 'Email'
$Device_FirstName = 'CustomProperty1'


$UserTier = New-MSDataminingTier -Module UserMigrations -Fields @('Email','FirstName','Id')
$Devices = Get-MSDataminingReport -Module Devices -All $true -HeaderFormat PrefixedName -Fields @('Id','Hostname') -AdditionalTiers $UserTier -Options @("Link_DeviceInfo") -FilterExpression "Link_AffinityLabel = 'Primary'"


$Updates = @()
Foreach($Device in $Devices.data.rows)
        {
        $updates += @{ 
            Id = $($Device.Devices_Id)
            $Device_Email = $Device.UserMigrations_Email
            $Device_FirstName = $Device.UserMigrations_FirstName
                }

    }

Update-MSDevices -Updates $updates 
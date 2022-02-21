#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################


<#
    Custom Housekeeping Rule - Remove Archived Users from Deployment Units
    
#>



## Get a list of UserIds that are both Archived and in an DeployUnit
$userIds = Get-MSUserMigrations -Archived | Where-Object { $_.DeployUnitId -ne $null } | Select-Object -ExpandProperty Id


## Settings required to send an email. 
$sendEmailCfg = @{
        OverrideSendTo = 'richard.hynes@managementstudio.com'; ## List of users to email, use ; to separate email addresses
        Module = 'ManagementStudio';  EmailTemplateName = 'Default Event Email';  ## Which email to send (use the system default)
        CustomKeyWords = @();  ## Set the email content
        ToIds = 0; ScheduleSendAt = (Get-Date); SpreadOverHours = 0; # Send the email right away
    }



## Remove Archived Users from their DeployUnit
if($userIds.Count -gt 0)
{
    Remove-MSUserMigrationsFromDeployUnit -MigrationIds $userIds | Out-Null

    Write-MSDebug -LogText "$($userIds.Count) archived Users removed from DUs. Ids: $($userIds -join ',')"
    $sendEmailCfg.CustomKeyWords =  @((@{ Keyword = "[Email-Body]"; Value = "$($userIds.Count) archived Users removed from DUs. <br/> Ids: $($userIds -join ',')"}), (@{ Keyword = "[MS-Account-FirstName]"; Value = ''}));  ## Set the email content
    
}
else{
    Write-MSDebug -LogText "No archived Users found in DUs"
    $sendEmailCfg.CustomKeyWords =  @((@{ Keyword = "[Email-Body]"; Value = 'No archived Users found in DUs'}), (@{ Keyword = "[MS-Account-FirstName]"; Value = ''}));  ## Set the email content
}


## Send the email
Send-MSEmails @sendEmailCfg | Out-Null 


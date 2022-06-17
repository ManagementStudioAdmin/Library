#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

## Example Input. ($ScriptArgs is provided by MS)
$ScriptArgs = @{ Items = @(1000, 1001, 1002); Module = 'UserMigrations' }



<#
    On Survey Submit - Prevent New App Links and Reject Links to Rejected Apps

    Use Case:
    After a User as submitted their Apps Survey prevent new Apps being added to their list by Connectors or Apps comming out of the Rejected Queue

    Usage: 
        Add the following code to the On Survey Submit PS Code block. 
#>

## Script Start
#----------------------------------------------------------------

$migrationIds = $ScriptArgs.Items

foreach($migrationId in $migrationIds){

    ## Set the 'Prevent New Links Flag' so that this User can not get any new Apps
    Update-MSUserMigrations -Updates @( @{ Id = $migrationId; PreventNewLinks = $true }) | Out-Null


    ## Get a list of LinkIds of Apps that are Rejected and linked to this User
    $linkIds = Get-MSUserMigrationLinksTo -MigrationId $migrationId -ToApps -AddPendingQueue -AddLinkInfo `
                | Where-Object { $_.AppStatus -eq 'Rejected'} | Select-Object -ExpandProperty LinkId

    ## Reject User-App Links for Rejected Apps on this User
    if($null -ne $linkIds -and $linkIds.Count -gt 0){
        $rpt = (Get-MSApi).UserMigrations.Links.RejectByLinkIds($linkIds)
        Write-MSDebug -LogText $($rpt.Content)
    }

}

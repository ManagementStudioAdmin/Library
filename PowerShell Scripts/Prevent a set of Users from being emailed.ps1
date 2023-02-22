<#
    ## USE CASE ## 
    Prevent ManagementStudio from Emailing a specific set of Users.
    In the example below we exclude VIP Users based on CustomFlag1 being set to True, this however could be any field, or a Blueprint, Process etc.


    ## ACTIONS ##
    The script hooks into the ManagementStudio Email Queued event and allows examination of the email before it is sent out. 
    The $ScriptArgs.EventData contains a list of Emails to be added to the Queue with some useful properties such as: EmailId, InstanceId, Subject, ToAddress
    If we don't want to send the email, we can return a hash set of @{ EmailId = xx; AddToQueue = $false;} to remove it from the Email Queue.


    ## SETUP STEPS ## 
    1.	Go To : Administration\PS Scripts, Emails, Buttons
    2.	Create a PowerShell script.
        a.  Name the script, e.g. 'VIPs Do Not Email'
        b.	Set the Trigger to 'Email Queued'
        c.	Set the Module to 'ManagementStudio' (if not already set)
        d.	Optionally set 'Log Args' to false to reduce the size of log files created.
    3.	Copy and paste the code below into the new PowerShell Script in MS
    4.	Save

#> 


## Script Start
#----------------------------------------------------------------

## List of emails not to send
$blockedEmails = @()

## Extract a list of User Ids that are being Emailed
$userIds = @()
foreach($item in $ScriptArgs.EventData)
{
    if($item.ModuleId -ne 2) { continue }
    $userIds += $item.InstanceId
}


## ------------------------------------------------
## Rule Example - Don't email Users that are VIPs
## ------------------------------------------------

## Get a list of UserIds we are not allowed to Email
##   i.e. Users that have CustomFlag1 set to true 
$rpt = Get-MSUserMigrationDataminingReport -MigrationIds $userIds -Fields @("Id", "CustomFlag1") -HeaderFormat PrefixedName -FilterExpression "UserMigrations_CustomFlag1 = 1"

## No Users found to not email, exit
if($rpt.Status.Rows -eq 0){ return }

## Convert DMR result to a list of UserIds we can't email
$userIdsToNotEmail = $rpt.Data | Select-Object -ExpandProperty UserMigrations_Id 


## For each email MS is about to send, check if the target User is on the blocked list
foreach($item in $ScriptArgs.EventData)
{
    ## If this is not a User email then skip the Id check (slightly more efficient)
    if($item.ModuleId -ne 2) { continue }

    ## Is this email being sent to a blocked User? 
    if($userIdsToNotEmail -contains $item.InstanceId) 
    { 
        $blockedEmails += @{ EmailId = $item.EmailId; AddToQueue = $false; }     
        Add-MSUserMigrationNote -Id $item.InstanceId -NoteText "The Email: '$($item.Subject)' was blocked from being sent. MS is not allowed to Email Users with CustomFlag1 set to True." | Out-Null
        Write-MSDebug -LogText "The Email: '$($item.Subject)' was blocked from being sent to UserId $($item.InstanceId). MS is not allowed to Email Users with CustomFlag1 set to True"
    }        
}

return $blockedEmails

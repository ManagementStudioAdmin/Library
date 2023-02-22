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

## Get a list of Email addresses of VIPs to NOT email
##   Ignore users with a Blank email address or VIPs that have CustomFlag1 set to true 
$rpt = Get-MSDataminingReport -Module UserMigrations -All $true -HeaderFormat PrefixedName -Fields @('Email', 'CustomFlag1') -FilterExpression "UserMigrations_Email <> '' AND 
UserMigrations_CustomFlag1 = 1"

## No email addresses found to ignore
if($rpt.Status.Rows -eq 0){ return }

## Convert DMR result to list of Email Address
$blockedEmailAddresses = $rpt.Data | Select-Object -ExpandProperty UserMigrations_Email

## Alt Option, Manual List of Email Addresses that MS will not sent emails too. 
#$blockedEmailAddresses = @('richard.hynes@managementstudio.com', 'ben.coook@managementstudio.com')


$ignoreEmails = @()

foreach($emailObj in $ScriptArgs.EventData)
{
    foreach($email in $blockedEmailAddresses)
    {
        try
        {
            ## If this ToAddress contains one of the Blocked Email Addresses then ignore this email
            $mailMatch = '*' + $email + '*'
            if($emailObj.ToAddress -like $mailMatch) 
            {
                ## Add this email to the ignore list to return to MS
                $ignoreEmails += @{ 
                    EmailId = $emailObj.EmailId; 
                    AddToQueue = $false; 
                }
                
                ## Optionally log this blocked email to the script log
                Write-MSDebug -LogText "Blocked Email to $($emailObj.ToAddress)"
            }        
        }
        catch{
            Write-MSDebug -Exception $_
        }
    }
}

## Return a list of Emails to MS to ignore
return $ignoreEmails
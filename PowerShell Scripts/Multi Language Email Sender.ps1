#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl http://localhost -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################




<#
    Multi Language Email Sender

    Using the User's Country pick the correcttly localised email for that User. 

    Usage: 
        1. UI Button: 
            Target this script and put the Email Type to send in Arg1.
        
        2. ESM Plan Action: 
            Target this script and put the Email Type to send in Param.
            E.g. On Publish	| Run PowerShell | 58 | Survey-Request	

        3. On Self-Schedule Booked 
            Target this script and put the Email Type to send in Arg1.
            E.g. Invoke-MSScript -Module UserMigrations -ScriptId 58 -TargetIds $ScriptArgs.Items -Args1 'Schedule-Complete'
#>




############  START OF CONFIGURATION  ############

## Custom Form Field ID holding the Users Country
$locationFieldId = 1498
$defaultLanguage = 'EN'

$emailLookup = @(

    ## English Language Pack
    @{ Lang = 'EN'; Location = @('England', 'Ireland')},  ## <-- List of Languages (i.e. Values in the UI) that this Language Pack covers

    @{ Lang = 'EN'; Email = 'Survey-Request'; EmailId = '244'; IsDuEmail = $false  },
    @{ Lang = 'EN'; Email = 'Survey-Reminder'; EmailId = '243'; IsDuEmail = $false  },
    @{ Lang = 'EN'; Email = 'Survey-Complete'; EmailId = '242'; IsDuEmail = $false  },

    @{ Lang = 'EN'; Email = 'Schedule-Request'; EmailId = '251'; IsDuEmail = $true },
    @{ Lang = 'EN'; Email = 'Schedule-Reminder'; EmailId = '252'; IsDuEmail = $true },
    @{ Lang = 'EN'; Email = 'Schedule-Complete'; EmailId = '250'; IsDuEmail = $true },
    ##------------------------------------------------------------


    ## French Language Pack
    @{ Lang = 'FR'; Location = @('France')},
    
    @{ Lang = 'FR'; Email = 'Survey-Request'; EmailId = '202'; IsDuEmail = $false  },
    @{ Lang = 'FR'; Email = 'Survey-Reminder'; EmailId = '203'; IsDuEmail = $false  },
    @{ Lang = 'FR'; Email = 'Survey-Complete'; EmailId = '204'; IsDuEmail = $false  },

    @{ Lang = 'FR'; Email = 'Schedule-Request'; EmailId = '254'; IsDuEmail = $true },
    @{ Lang = 'FR'; Email = 'Schedule-Reminder'; EmailId = '255'; IsDuEmail = $true },
    @{ Lang = 'FR'; Email = 'Schedule-Complete'; EmailId = '253'; IsDuEmail = $true },
    ##------------------------------------------------------------


    ## German Language Pack
    @{ Lang = 'DE'; Location = @('Germany', 'Austria')},
    
    @{ Lang = 'DE'; Email = 'Survey-Request'; EmailId = '232'; IsDuEmail = $false },
    @{ Lang = 'DE'; Email = 'Survey-Reminder'; EmailId = '233'; IsDuEmail = $false },
    @{ Lang = 'DE'; Email = 'Survey-Complete'; EmailId = '234'; IsDuEmail = $false },

    @{ Lang = 'DE'; Email = 'Schedule-Request'; EmailId = '248'; IsDuEmail = $true },
    @{ Lang = 'DE'; Email = 'Schedule-Reminder'; EmailId = '249'; IsDuEmail = $true },
    @{ Lang = 'DE'; Email = 'Schedule-Complete'; EmailId = '247'; IsDuEmail = $true }
    ##------------------------------------------------------------
)


############  END OF CONFIGURATION  ############
## ---------------------------------------------


## Users to email are found in '$ScriptArgs.Items'
$migrationIds = $ScriptArgs.Items


$validEmailTypes = @('Survey-Request', 'Survey-Reminder', 'Survey-Complete', 'Schedule-Request', 'Schedule-Reminder', 'Schedule-Complete')

## Email Type in EventArg1 (Grid Custom Action, On Schedule Booked)
if(-not [string]::IsNullOrWhiteSpace($ScriptArgs.EventArg1)){
    $emailType = $ScriptArgs.EventArg1
}

## Email Type in UserInput (ESM Plan Action)
if(-not [string]::IsNullOrWhiteSpace($ScriptArgs.UserInput)){
    $emailType = $ScriptArgs.UserInput
}


## Was a valid Email Type to send passed into the script?
if(([string]::IsNullOrWhiteSpace($emailType)) -or ($validEmailTypes -notcontains $emailType))
{    
    Write-MSDebug -LogText "Invalid Email Type: '$($emailType)'" -ResultStatus Error
    return
}



## Dataming the Users for their Country and Title (for logging)
$dmr = Get-MSUserMigrationDataminingReport -MigrationIds $migrationIds -Fields @('Id', 'Title', 'DeployUnit') -CustomFieldIds @($locationFieldId)

if($dmr.Status.Rows -eq 0){
    Write-MSDebug -LogText "No valid Users found to email" -ResultStatus Error
    return
}


$emailsToSend = @{}
foreach ($row in $dmr.Data) 
{
    ## For each User, look at their Country and find a matching Email     
    $location = $row."CustomField_$($locationFieldId)"

    ## Convert Location to Language Code
    $langCodeFound = $false
    foreach($item in $emailLookup.GetEnumerator())
    {
        if($item.Location -contains $location)
        {
            $location = $item.Lang
            $langCodeFound = $true
        }
    } 

    ## Validation Check: User's Country Found in Email Lookup
    if($langCodeFound -eq $false){
        Write-MSDebug -LogText "Warning: No email found for Country: '$($location)' on User: '$($row.UserMigrations_Title)'. Defaulting to $($defaultLanguage) " -ResultStatus Error
        $location = $defaultLanguage
    }


    ## Get Email Id to Send
    foreach($item in $emailLookup.GetEnumerator())
    {
        if($item.Lang -eq $location -and $item.Email -eq $emailType)
        {
            ## If this is a DU Email and the User is not in a DU don't try and send it
            if($item.IsDuEmail -and [string]::IsNullOrWhiteSpace($row.UserMigrations_DeployUnit))
            {
                Write-MSDebug -LogText "Error: Can not Send '$emailType' ($($item.Lang)) to $($row.UserMigrations_Title). User is not in a DU." -VerboseInfo
                continue
            }
            


            ## Add Email to Send Queue

            ## Create an entry in the send hashtable if not already present
            if(-not $emailsToSend.ContainsKey($item.EmailId)){
                $emailsToSend.Add($item.EmailId, @())
            }

            ## Add User to list of Emaisl to send (grouped by Email Id)
            $emailsToSend[$item.EmailId] += $row.UserMigrations_Id
            
            ## Optionally Log that an email was found to send
            Write-MSDebug -LogText "Send '$emailType' ($($item.Lang)) to $($row.UserMigrations_Title)" -VerboseInfo

            break ## Don't check all emails, stop at the first match
        }
    } 
}


## Actually send the emails
if($emailsToSend.Count -gt 0)
{
    foreach($email in $emailsToSend.GetEnumerator())
    {
        ## $email.Key is a EmailTemplateId  / $email.Value is a list of MigrationIds
        Write-MSDebug -LogText "Sending EmailId: '$($email.Key)' to $($email.Value.Count) Users"
        Send-MSEmails -Module UserMigrations -ToIds $email.Value -EmailTemplateId $email.Key -ScheduleSendAt (Get-Date) -SpreadOverHours 0 | Out-Null
    }
}


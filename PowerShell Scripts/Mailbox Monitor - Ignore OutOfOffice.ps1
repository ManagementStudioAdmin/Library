#################################################################
## This Script can be used as the Email Pre-Processor foundation
## E.g. Ignore Out Of Office Emails so that they are not created as new defects
#################################################################

## Update Actions to send back to ManagementStudio
## These actions tell MS what to do (if anything) with the new emails found in the mailbox
$updates = @()

## $ScriptArgs.EventData holds a list of new Emails found
foreach($email in $ScriptArgs.EventData)
{
    ## If the Email contains text similar to "I am out of the Office" 
    ## Then flag that email to be ignored by the Email processor
    
    if($email.ContentAsText -match "I.*out.*of.*office/ig")
    { 
        $updates += @{ SequenceId = $email.SequenceId; Ignore = $true; }
        
        Write-MSDebug -LogText "OOO Email Ignored"
    } 
}

## Return Email Updates to MS to continue processing
$updates
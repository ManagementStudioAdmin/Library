#################################################################
## This Script can be used as the Email Pre-Processor foundation
## E.g. Ignore Out Of Office Emails so that they are not created as new defects
#################################################################

## Update Actions to send back to ManagementStudio
## These actions tell MS what to do (if anything) with the new emails found in the mailbox

## Convert the incoming EventData into a hash of updates that we can fill in later
$updatesHash = @{}
foreach($email in $ScriptArgs.EventData) {
    $updatesHash.Add($email.EmailId, @{ EmailId = $email.EmailId; Ignore = $email.Ignore; IsNewDefect = $email.IsNewDefect;  InstanceId = $email.InstanceId;  ModuleId = $email.ModuleId; })
}


## Out Of Office Rule
foreach($email in $ScriptArgs.EventData)
{
    ## If the Email contains text similar to "I am out of the Office" 
    ## Then flag that email to be ignored by the Email processor
    if($email.ContentAsText -match "I.*out.*of.*office/ig")  { 
        $updatesHash[$email.EmailId].Ignore = $true        
    } 
}

## Return Email Updates to MS to continue processing
$updatesHash.Values

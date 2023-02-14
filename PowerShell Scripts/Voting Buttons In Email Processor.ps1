$userId = $ScriptArgs.Items[0]
$fieldId = 2941

switch ($ScriptArgs.EventArg1) {
    
    'Great' { 
        Update-MSUserMigrationsCustomFields -FieldId $fieldId -FieldInstanceId $userId -DataValue 'Great'
        New-MSApiResult -Header "Thank you for your vote!" -Content "We are happy to hear your migration went well" -Status Success
     }

    'Good' { 
        Update-MSUserMigrationsCustomFields -FieldId $fieldId -FieldInstanceId $userId -DataValue 'Good'
        New-MSApiResult -Header "Thank you for your vote!"  -Content "We are happy to hear your migration went well" -Status Success
     }

    'Poor' { 
        Update-MSUserMigrationsCustomFields -FieldId $fieldId -FieldInstanceId $userId -DataValue 'Poor'
        New-MSApiResult -Header "Thank you for your vote!" -Content "We are sorry to hear that you had a bad experance."
     }

    Default {
        New-MSApiResult -Header "Invalid Vote" -Content "Please contact a member of the project team" -Status Error
    }
}

<#

## USE CASE ## 
A "New Version / Clone" App button is required on the App Portal Grid.

## SOLUTION ## 
Create a Custom Button on the App Portal Grid to call a PowerShell script that will use the MS API to clone the App.
Optionally redirect the User to a details page for the new App to collect additional information.

## STEPS ## 
1. Go To : Administration\Applications\Surveys
    Create an App Survey to serve as the 'Details View' of the new App. Take note of its SurveyId

2. Update the code below with the SurveyId of from step one

3. Chose option 1 or 2 in the script by uncommenting the preferred option
    Option 1 - Redirect to New App Details Page immediately
    Option 2 - Display a message to the User that the App has been created with an optional link to the details page
    Option 3 - Implement your own logic, e.g., move the new App to a process, create a UAT, email a User etc.

4. Go To : Administration\Applications\PowerShell Scripts
    Create an App PowerShell script using the code below. Take note of the ScriptId

5. Go to : Administration\Applications\Portal
    In the 'Grid Columns' area add "{ CustomButtonScriptId: 99; Label: New Version; Style: btn-secondary btn-sm; },"
    Note: Change the 'CustomButtonScriptId' value to the Script Id from step 4

#>

## CODE ##

## App Details SurveyId
$redirectToSurveyId = 99        ## <- SurveyId from step 1

## The AppId to clone - Do not edit this line
$appId = $ScriptArgs.Items[0]

## Clone the Application - You can customise the sections of the App to be cloned
$clone = Update-MSCloneModuleItem -Module Applications -Id $appId -Notes -Blueprints -Links -DiscoveryTab

## Get the Survey to redirect to
$detailSurvey = Get-MSSurveysForModuleItems -Module Applications -SurveyId $redirectToSurveyId -InstanceIds $clone.InstanceId

## STEP 3 - Uncomment relevant option 
## Option 1 - Redirect to New App Details Page
# New-MSApiResult -Header "Cloned" -Status Success -RedirectUrl $detailSurvey.SurveyUrl

## Option 2 - Display Message, with App Details Page link 
# New-MSApiResult -Header "Cloned" -Content "Cloned <br/><a href=$($detailSurvey.SurveyUrl)>App Info</a>" -Status Success

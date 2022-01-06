#######################  QUICK CONNECTION  ######################
Import-Module "c:\ManagementStudio\ManagementStudioApi"
Connect-MSApi -ApiUrl "http://localhost" -ProjectId 1 -UserName "UserName" -Password "YourPassw0rd!" -Logfile "C:\ManagementStudio\ScriptLog.txt" | Out-Null
#################################################################

<#
## NOTE: 
 See the 'Dataming Report.ps1' for more info on how to create the DMR data.
 This example will use DMR's saved in the UI to declutter the DMR code 


------------------------------------------------
 New-MSExcelReport
------------------------------------------------
Takes a datatable as an input (generally from a DRM) and uses it  to create an Excel report file on the MS server in the Reports directory. The path to this report is then returned. 


PARAMS


------------------------------------------------
 Send-MSDataminingReportEmails
------------------------------------------------
PARAMS
 -EmailTemplateId <int>
 -EmailTemplateName <string>
  All emails that are sent from MS must have a email template even if it is empty. For sending DMR reports via email it is recommmeded that you create a generic email template with a Module Type 'ManagementStudio'
  The email templates can be created per report to provide a better user experance where the report is intoducded in the email and any actions listed or a simple blank email template can be used and the report will show as an attached Excel file

 -SendTo <string>
  A ';' delimited list of email addresses to send the report to

 -FileAttachments <array>
 
#>



#==============================================================================================
#==============================================================================================

# Ex 1. Email a DMR report 

## Step 1. Run a DMR using a report saved in the UI
$dmr = Get-MSDataminingReportById -ReportId 1

## Step 2. Create an Excel report with the DMR data as a file on the Server
$excelReport = New-MSExcelReport  -Data $dmr.Data -IncludeColumnHeaders

## Step 3. Email the Excel report created on the Server to a user
Send-MSDataminingReportEmails  -EmailTemplateId 29 -SendTo "richard.hynes@migrationstudio.co.uk" -FileAttachments @($excelReport.Reports)


#==============================================================================================

# Ex 2. Email a DMR report with mutiple sheets and a report template

## Step 1. Run mutiple DMRs using a report saved in the UI
$appReport = Get-MSDataminingReportById -ReportId 2
$userReport = Get-MSDataminingReportById -ReportId 3
$deviceReport = Get-MSDataminingReportById -ReportId 4

 
## Step 2a. Create a report entry (i.e. wooksheet) per DMR. 
$xlsApps = New-MSExcelReportEntry -Data $appReport.Data -SheetName "Apps Report"
$xlsUsers = New-MSExcelReportEntry -Data $userReport.Data -SheetName "Users Report"
$xlsDevices = New-MSExcelReportEntry -Data $deviceReport.Data -SheetName "Devices Report"

## Step 2b. Using the report entries create an Excel report on the Server
$excelReport = New-MSExcelReport  -Reports @($xlsApps, $xlsUsers, $xlsDevices) -IncludeColumnHeaders -ExcelTemplateResourceId 1


## Step 3. Email the Excel report created on the Server to a user
Send-MSDataminingReportEmails  -EmailTemplateId 29 -SendTo "richard.hynes@migrationstudio.co.uk" -FileAttachments @($excelReport.Reports)
# SPOC Team Schedule Page

ManagementStudio allows Users to be emailed their self-schedule link individually to select their migration slot. In cases where this is not practical or desirable a combination of surveys and Datamining Reports (DMR) can be used to create a page where a SPOC can set the schedule of their Users. 

Self-Schedule slots are defined by Deployment  Units (DU), we'll make use of this to create a Survey page that allows a SPOC to pick a slot and unlock slots that have already been selected. 



Step 1 - Create DU Survey with list of Users

1. Create a new DMR in the DU section
   1. Add the DU Name
   2. Add a Self-Schedule tier
      1. Include the Self-Schedule Link field
   3. Save the DMR and take note of its ID.
2. Create a new Survey in the DU section
   1. Untick the save buttons and unlock on save options
   2. Add a new Field of Type Datamining Report and use the Id from the previous step
   3. Save the Survey

Step 2 - Convert schedule URL into a button

1. Open the DMR from step one

2. Click Expression Columns in the toolbar

3. Add an expression column with the following text

   `<a href="something" >Schedule</a>`



Adding an Unlock Button

When a migration slot selected it its automatically locked to prevent further changes. This slot can be unlocked in the client UI but if we need to give a SPOC the ability to unlock a slot without giving them full client access then an Unlock button can be created and added to the page. 

Step 1- Create Unlock Script

1. Create a new User Migration Script
2. Enable http activation
3. Paste the below code into the script
4. Take note of the Script Id and key



Step 2 - Add Button to DMR

1. Open DMR backing the Schedule page
2. Add a new Expression column
3. Paste the below text into new column
4. Replace the ScriptId & Key from above
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
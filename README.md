## SHEPS
To create ICD9 to ICD10 equivalents use the ICD9_to_10 along with the 2 .csv's in the folder, Convert_ICD9_to_10 works on a single file, the Read_Multiple_Sheps works on multiple SHEPS files at once.

## Steps
# Pre data
- ICD9_to_ICD10: This script will use the two files in the folder ICD_Codes. The script will identify and convert ICD-9 codes into their new ICD-10 codes and create a new .csv for use in later scripts.
- Reformat_SHEPS: In this script you will be able to edit the formating of the SHEPS file. This allows you to cut down on needless columns that take up space, this is especially useful when you will run multiple files at once as this will save a lot of time

# Base
- Single_SHEPS_File: This script will convert the diagnosis columns in the sheps file with the corresponding ICD-10 outcomes that you specify and create a new dataframe.
- Multiple_SHEP_Files: This script will be able to read in multiple years of SHEPS data. Be sure to have files located correctly.

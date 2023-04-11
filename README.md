# SHEPS
- These scripts will allow you to convert ICD-9 codes into corresponding ICD-10 codes. Additionally, you will be able to specify targeted outcomes that you are interested in and extract them from the original SHEPS file. This process should also work on other ICD-9/10 equivalent data sets but with a need to tailor column names to match new data.

# Steps
## Pre data
- ICD9_to_ICD10: This script will use the two files in the folder ICD_Codes. The script will identify and convert ICD-9 codes into their new ICD-10 codes and create a new .csv for use in later scripts.
- Reformat_SHEPS: In this script you will be able to edit the formating of the SHEPS file. This allows you to cut down on needless columns that take up space, this is especially useful when you will run multiple files at once as this will save a lot of time

## Base
### Single_SHEPS_File:
1. First, it loads two packages: "dplyr" and "data.table".
2. It sets the working directory to "~/Sheps" using the "setwd" function.
3. It reads the "Sheps" dataset using the "fread" function.
4. It reads two subsets of the "ICD Codes" dataset and stores them in "icd_codes" and "ICD_10" variables using the "fread" function.
5. It creates a copy of the "Sheps" dataset and assigns it to "mini_sheps".
6. It creates a named vector of ICD9 to ICD10 codes using the "setNames" function and assigns it to "dat2vec".
7. It creates a vector of positions of columns containing ICD codes and assigns it to "position".
8. It replaces ICD-9 codes in "mini_sheps" dataset with their respective ICD-10 codes using the "lapply" function and assigns the result back to "mini_sheps".
9. It filters out the rows from "mini_sheps" dataset that contain specific ICD-10 codes related to physical health outcomes such as respiratory, heat-related illness, cardiovascular, suicide and self-harm, and death. It creates separate dataframes for each outcome and assigns them to "Respiratory_case", "Heat_illness_case", "Cardiovascular_case", "sui_selfharm_case", and "died_case" respectively.
10. It filters out the rows from "mini_sheps" dataset that contain specific ICD-10 codes related to mental health outcomes such as all mental health, psychoactive substance abuse, schizophrenia and schizotypal and delusional disorders, and mood disorders. It creates separate dataframes for each outcome and assigns them to "Mental_Health_case", "Psychoactive_case", "Schizophrenia_case", and "Mood_case" respectively.

- Multiple_SHEP_Files: This script will be able to read in multiple years of SHEPS data. Be sure to have files located correctly.

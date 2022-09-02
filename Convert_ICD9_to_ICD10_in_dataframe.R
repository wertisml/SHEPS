library(googledrive)
library(data.table)

setwd("~/Sheps")
# Download file from Google Drive
#drive_auth()
filep = drive_download("Inpatient_2008_NC.csv", overwrite = T) 
# Read in the Google Drive file
Sheps <- fread(filep$local_path)

icd_codes <- fread("C:\\Users\\wertisml\\Documents\\Sheps\\ICD Codes\\all_ICD9_ICD10.csv")
ICD_10 <- fread("C:\\Users\\wertisml\\Documents\\Sheps\\ICD Codes\\all_ICD10_codes.csv")

#==============================================================================#
# Convert ICD9 to ICD10 in the Sheps data
#==============================================================================#

# Set-up

mini_sheps <- Sheps[1:1000,]

dat2vec <- setNames(icd_codes$icd10, icd_codes$icd9)

position <- grep("iag", names(mini_sheps))

# Convert the ICD-9 to ICD-10

mini_sheps[,position[1]:position[length(position)]] <- lapply(mini_sheps[,position[1]:position[length(position)]], function(z) dat2vec[as.character(z)])

#==============================================================================#
# Physical health outcomes
#==============================================================================#

# Respiratory

ICD10_Code <- c("^J")

Respiratory_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                 ICD_10$ICD10, value=TRUE))

Respiratory_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Respiratory_codes)) %>%
  mutate(Respiratory = 1) %>%
  dplyr::select(Respiratory, shepsid, admitdt)

# Heat-related illness

ICD10_Code <- c("^T67", "^X30")

Heat_illness_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                  ICD_10$ICD10, value=TRUE))

Heat_illness_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Heat_illness_codes)) %>%
  mutate(Heat_illness = 1) %>%
  dplyr::select(Heat_illness, shepsid, admitdt)

# Cardiovascular

ICD10_Code <- c("^I")

Cardiovascular_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                    ICD_10$ICD10, value=TRUE))

Cardiovascular_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Cardiovascular_codes)) %>%
  mutate(Cardiovascular = 1) %>%
  dplyr::select(Cardiovascular, shepsid, admitdt)

# Suicide and self-harm

ICD10_Code <- c("R45851","R4588", "^X7", "^X8")

sui_selfharm_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                  ICD_10$ICD10, value=TRUE))

sui_selfharm_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% sui_selfharm_codes)) %>%
  mutate(Sui_selfharm = 1) %>%
  dplyr::select(Sui_selfharm, shepsid, admitdt)

# Expired (Dead)

Status_Code <- c(20, 40, 41, 42)

died_case <- mini_sheps %>% 
  filter_at(vars(contains("sta")), any_vars(. %in% Status_Code)) %>%
  mutate(died = 1) %>%
  dplyr::select(died, shepsid, admitdt)

#==============================================================================#
# Mental health outcomes
#==============================================================================#

# All Mental Health

ICD10_Code <- c("^F")

Mental_Health_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                   ICD_10$ICD10, value=TRUE))

Mental_Health_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Mental_Health_codes)) %>%
  mutate(Mental_Health = 1) %>%
  dplyr::select(Mental_Health, shepsid, admitdt)

# psychoactive substance abuse

ICD10_Code <- c("^F1")

Psychoactive_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                  ICD_10$ICD10, value=TRUE))

Psychoactive_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Psychoactive_codes)) %>%
  mutate(Psychoactive = 1) %>%
  dplyr::select(Psychoactive, shepsid, admitdt)

# Schizophrenia and schizotypal and delusional disorders

ICD10_Code <- c("^F2")

Schizophrenia_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                   ICD_10$ICD10, value=TRUE))

Schizophrenia_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Schizophrenia_codes)) %>%
  mutate(Schizophrenia = 1) %>%
  dplyr::select(Schizophrenia, shepsid, admitdt)

# Mood disorders

ICD10_Code <- c("^F3")

Mood_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                          ICD_10$ICD10, value=TRUE))

Mood_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Mood_codes)) %>%
  mutate(Mood = 1) %>%
  dplyr::select(Mood, shepsid, admitdt)

# Neurotic disorders

ICD10_Code <- c("^F4")

Neurotic_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                              ICD_10$ICD10, value=TRUE))

Neurotic_case <- mini_sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% Neurotic_codes)) %>%
  mutate(Neurotic = 1) %>%
  dplyr::select(Neurotic, shepsid, admitdt)

#==============================================================================#
# Combining the mini dataframes with the original 
#==============================================================================#

mini_mental <- mini_sheps %>%
  left_join(Neurotic_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Mood_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Schizophrenia_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Psychoactive_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Mental_Health_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt"))

mini_physical <- mini_sheps %>%
  left_join(Respiratory_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Heat_illness_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(Cardiovascular_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(sui_selfharm_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
  left_join(died_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt"))





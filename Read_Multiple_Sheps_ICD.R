library(data.table)
library(dplyr)

setwd("E:/Sheps/Sheps_2008_2020_filtered")

dat.files  <- list.files(path="E:/Sheps/Sheps_2008_2020_filtered",
                         recursive=T,
                         pattern="\\.csv$",
                         full.names=T,
                         ignore.case=F,
                         no.. = TRUE)

icd_codes <- fread("E:\\Sheps\\ICD_Codes\\all_ICD9_ICD10.csv")
ICD_10 <- fread("E:\\Sheps\\ICD_Codes\\all_ICD10_codes.csv")

n = 2008

for(i in dat.files){
  Sheps <- fread(i)
  
  #============================================================================#
  # Set-up
  #============================================================================#
  
  Sheps$zip5 <- as.numeric(Sheps$zip5)
  
  Sheps <- Sheps %>%
    filter(zip5 >= 27006) %>%
    filter(zip5 <= 28909) %>%
    filter(zip5 != "NA") %>%
    filter(!is.na(shepsid))
  
  Sheps$fyear <- fifelse(Sheps$fyear != n, n, Sheps$fyear)
  
  dat2vec <- setNames(icd_codes$icd10, icd_codes$icd9)
  
  position <- grep("iag", names(Sheps))
  
  # Convert the ICD-9 to ICD-10
  
  if (n < 2016){
    Sheps[,position[1]:position[length(position)]] <- lapply(Sheps[,position[1]:position[length(position)]], function(z) dat2vec[as.character(z)])
  }
  
  # Adjust the race column to match later numeric versions
  
  if (n < 2011){
    Sheps$race <- fifelse(Sheps$race == 6, 7,
                    fifelse(Sheps$race == 5, 6,
                      fifelse(Sheps$race == 4, 5,
                        Sheps$race)))
  }
  
  #==============================================================================#
  # Physical health outcomes
  #==============================================================================#
  
  # Respiratory
  
  ICD10_Code <- c("^J")
  
  Respiratory_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                   ICD_10$ICD10, value=TRUE))
  
  Respiratory_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Respiratory_codes)) %>%
    mutate(Respiratory = 1) %>%
    dplyr::select(Respiratory, shepsid, admitdt)
  
  # Heat-related illness
  
  #ICD10_Code <- c("^T67", "^X30")
  
  #Heat_illness_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
  #                                  ICD_10$ICD10, value=TRUE))
  
  #Heat_illness_case <- Sheps %>% 
  #  filter_at(vars(contains("iag")), any_vars(. %in% Heat_illness_codes)) %>%
  #  mutate(Heat_illness = 1) %>%
  #  dplyr::select(Heat_illness, shepsid, admitdt)
  
  # Cardiovascular
  
  ICD10_Code <- c("^I")
  
  Cardiovascular_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                      ICD_10$ICD10, value=TRUE))
  
  Cardiovascular_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Cardiovascular_codes)) %>%
    mutate(Cardiovascular = 1) %>%
    dplyr::select(Cardiovascular, shepsid, admitdt)
  
  # Suicide and self-harm
  
  ICD10_Code <- c("R45851","R4588", "^X7", "^X8")
  
  sui_selfharm_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                    ICD_10$ICD10, value=TRUE))
  
  sui_selfharm_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% sui_selfharm_codes)) %>%
    mutate(Sui_selfharm = 1) %>%
    dplyr::select(Sui_selfharm, shepsid, admitdt)
  
  # Expired (Dead)
  
  Status_Code <- c(20, 40, 41, 42)
  
  died_case <- Sheps %>% 
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
  
  Mental_Health_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Mental_Health_codes)) %>%
    mutate(Mental_Health = 1) %>%
    dplyr::select(Mental_Health, shepsid, admitdt)
  
  # psychoactive substance abuse
  
  ICD10_Code <- c("^F1")
  
  Psychoactive_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                    ICD_10$ICD10, value=TRUE))
  
  Psychoactive_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Psychoactive_codes)) %>%
    mutate(Psychoactive = 1) %>%
    dplyr::select(Psychoactive, shepsid, admitdt)
  
  # Schizophrenia and schizotypal and delusional disorders
  
  ICD10_Code <- c("^F2")
  
  Schizophrenia_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                     ICD_10$ICD10, value=TRUE))
  
  Schizophrenia_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Schizophrenia_codes)) %>%
    mutate(Schizophrenia = 1) %>%
    dplyr::select(Schizophrenia, shepsid, admitdt)
  
  # Mood disorders
  
  ICD10_Code <- c("^F3")
  
  Mood_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                            ICD_10$ICD10, value=TRUE))
  
  Mood_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Mood_codes)) %>%
    mutate(Mood = 1) %>%
    dplyr::select(Mood, shepsid, admitdt)
  
  # Neurotic disorders
  
  ICD10_Code <- c("^F4")
  
  Neurotic_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                ICD_10$ICD10, value=TRUE))
  
  Neurotic_case <- Sheps %>% 
    filter_at(vars(contains("iag")), any_vars(. %in% Neurotic_codes)) %>%
    mutate(Neurotic = 1) %>%
    dplyr::select(Neurotic, shepsid, admitdt)
  
  #==============================================================================#
  # Combining the mini dataframes with the original 
  #==============================================================================#
  
  mental <- Sheps %>%
    left_join(Neurotic_case) %>%
    left_join(Mood_case) %>%
    left_join(Schizophrenia_case) %>%
    left_join(Psychoactive_case) %>%
    left_join(Mental_Health_case) %>%
    replace(is.na(.), 0)
  
  physical <- Sheps %>%
    left_join(Respiratory_case) %>%
    #left_join(Heat_illness_case, by = c("shepsid" = "shepsid", "admitdt" = "admitdt")) %>%
    left_join(Cardiovascular_case) %>%
    left_join(sui_selfharm_case) %>%
    left_join(died_case) %>%
    replace(is.na(.), 0)
  
  #============================================================================#
  # Write off the file
  #============================================================================#
  
  fwrite(mental, "Sheps_mental.csv", append = TRUE)
  fwrite(physical, "Sheps_physical.csv", append = TRUE)
  
  print(n)
  n=n+1
}




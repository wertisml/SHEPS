library(tidyverse)
library(data.table)
library(arrow)

setwd("~/Sheps/files/parquet/mental_reworked")

dat.files  <- list.files(path="~/Sheps/files/filtered",
                         recursive=T,
                         pattern="\\.parquet$",
                         full.names=T,
                         ignore.case=F,
                         no.. = TRUE)

icd_codes <- read_csv("/home/students/wertisml/Sheps/files/ICD_Codes/all_ICD9_ICD10.csv")
ICD_10 <- read_csv("/home/students/wertisml/Sheps/files/ICD_Codes/all_ICD10_codes.csv")

#==============================================================================#
# Build filters
#==============================================================================#

# Create ICD-9 to ICD-10 conversions
dat2vec <- setNames(icd_codes$icd10, icd_codes$icd9)

# Mental Health Cases
ICD10_Code <- c("^F")
Mental_Health_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                   ICD_10$ICD10, value=TRUE))

# psychoactive substance abuse
ICD10_Code <- c("^F1")
Psychoactive_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                  ICD_10$ICD10, value=TRUE))

# Schizophrenia and schizotypal and delusional disorders
ICD10_Code <- c("^F2")
Schizophrenia_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                                   ICD_10$ICD10, value=TRUE))

# Mood disorders
ICD10_Code <- c("^F3")
Mood_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                          ICD_10$ICD10, value=TRUE))

# Neurotic disorders
ICD10_Code <- c("^F4")
Neurotic_codes <- unique(grep(paste(ICD10_Code, collapse="|"), 
                              ICD_10$ICD10, value=TRUE))

#==============================================================================#
# Use filters
#==============================================================================#

n = 2008

for(i in dat.files){ 
  
  if(n < 2016) {
  
  system.time(Sheps <- open_dataset(i) %>%
                select(fyear, ptcnty, zip5, agey, sex, race, admitdt, shepsid, 
                       matches("^diag")) %>%
                collect() %>%
                filter(!is.na(shepsid)) %>%
                drop_na(admitdt) %>%
                mutate(fyear = fifelse(fyear != n, n, fyear)) %>%
                { # begin code block to add
                  position <- grep("iag", names(.)) # replace var1, var2, var3 with actual variable names
                  .[, position[1]:position[length(position)]] <- lapply(.[, position[1]:position[length(position)]], function(z) dat2vec[as.character(z)])
                  .
                } %>%
                mutate(Mental_Health = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Mental_Health_codes)) > 0, 1,
                                              0),
                       Psychoactive = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Psychoactive_codes)) > 0, 1,
                                             0),
                       Schizophrenia = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Schizophrenia_codes)) > 0, 1,
                                              0),
                       Mood = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Mood_codes)) > 0, 1,
                                     0),
                       Neurotic = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Neurotic_codes)) > 0, 1,
                                         0))%>%
                select(-matches("^diag")) #%>%
                #mutate_all(as.character)
  )
  } else {system.time(Sheps <- open_dataset(i) %>%
                        select(fyear, ptcnty, zip5, agey, sex, race, admitdt, shepsid, 
                               matches("^diag")) %>%
                       collect() %>%
                       filter(!is.na(shepsid)) %>%
                       drop_na(admitdt) %>%
                       mutate(fyear = fifelse(fyear != n, n, fyear)) %>%
                       mutate(Mental_Health = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Mental_Health_codes)) > 0, 1,
                                                     0),
                              Psychoactive = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Psychoactive_codes)) > 0, 1,
                                                    0),
                              Schizophrenia = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Schizophrenia_codes)) > 0, 1,
                                                     0),
                              Mood = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Mood_codes)) > 0, 1,
                                            0),
                              Neurotic = ifelse(rowSums(sapply(select(., starts_with("diag")), `%in%`, Neurotic_codes)) > 0, 1,
                                                0))%>%
                        select(-matches("^diag")) #%>%
                        #mutate_all(as.character)
  ) }
  
  if (n < 2011) {
    Sheps$race <- fifelse(Sheps$race == 6, 7,
                          fifelse(Sheps$race == 5, 6,
                                  fifelse(Sheps$race == 4, 5,
                                          Sheps$race)))
  }
  
  write_parquet(Sheps, paste0("Mental_",n,".parquet"))
  
  print(n)
  n=n+1
}

#==============================================================================#
# Create single file
#==============================================================================#

read_parquet_bucket <- function(file_path, col_names){
  
  Outcome <- open_dataset(file_path) %>% 
    select(all_of(c(col_names))) %>%
    collect()
  
  return(Outcome)
}

Outcome <- read_parquet_bucket(file_path = "~/Sheps/files/parquet/mental",
                          col_names = c("zip5", "admitdt", "Mental_Health"))




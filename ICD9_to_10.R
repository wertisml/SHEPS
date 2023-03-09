library(icdcoder)
library(data.table)
library(dplyr)

ICD9 <- fread("~\\ICD Codes\\ICD9_Diag_Codes.csv", header = TRUE)
ICD10 <- read.delim("~\\ICD Codes\\icd10cm_codes_2022.txt",
                    header = FALSE,
                    sep = " ")
                    
# ICD-9

icd9codes <- ICD9$`DIAGNOSIS CODE`
icd9_to_10 <- convICD(icd9codes, "icd9")

fwrite(icd9_to_10, "all_ICD9_ICD10.csv")

# ICD-10

ICD_10 <- ICD10[,1:2]
colnames(ICD_10) <- c("ICD10", "number")
ICD_10$number <- seq.int(nrow(ICD_10))

fwrite(ICD_10, "all_ICD10_codes.csv")



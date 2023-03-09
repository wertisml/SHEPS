library(dplyr)
library(data.table)

sheps <- fread(file.choose())

codes <- fread("C:\\Users\\wertisml\\Documents\\Sheps\\ICD Codes\\ADD_ICD9_10.csv")
ADD <- codes$Codes

ADD_case <- Sheps %>% 
  filter_at(vars(contains("iag")), any_vars(. %in% ADD)) %>%
  mutate(ADD = 1) %>%
  dplyr::select(fyear, patst, ptcnty, zip5, agem, agey, sex, race, ADD, shepsid)



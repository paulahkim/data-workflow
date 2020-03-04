#clear all prior data and work to ensure a clean environment
rm(list=ls())

#download dataset to intended working directory
#https://drive.google.com/open?id=1p9CtNgDE5Lj1muEkxQqfOWdop2NiAEjV

#set working directory to folder where dataset is saved
setwd("~/Desktop/Data Workflow/R practice")

#program to open tidyverse
library(plyr)
library(tidyverse)

#program to open .csv and excel files
library(readxl)  

#load dataset, open LEFT sheet
dc2019star <-read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx", 
                                   sheet = "School STAR Metric Scores")

#view dataset 
View(dc2019star)



### PLAN TO CLEAN DATASET -- VARIABLES AND OBSERVATIONS TO KEEP
### Variable description pulled from "Data Dictionary" sheet 
### in "2019DCSchoolReportCardMetricScoresPublicData.xlsx"

## LEA Code: 3-4 digit identifier unique to each local education agency  
#            ***will keep only observations "001" for DCPS and drop others (charter, alternative); 
#            renders LEA Name redundant
## School Name: name of school
## School Code: 3-4 digit identifier unique to each school
## School Framework: school's grade configuration or school designations
#            ***will keep only observations "Elementary School with Pre-Kindergarten" 
#            and drop others (Alternative Framework, Elementary School without Pre-Kindergarten,
#            High School, Middle School)
## Student Group: STAR Framework measures performance for student groups with a minimum n size of 10
#            ***will keep only observations for 6 ESSA-defined racial/ethnic groups: 
#            "American Indian or Alaskan Native", "Asian","Black or African American",
#            "Hispanic/Latino of any race", "Native Hawaiian or Other Pacific Islander", "White" 
#            and drop others
## Metric: STAR Framework metrics are designed to share information about student success and 
#            progress using different data elements associated with positive student outcomes
#            ***will keep "90% Attendance", "Approaching, Meeting or Exceeding Expectations - ELA",
#            "Approaching, Meeting or Exceeding Expectations - Math" 
#            and drop others
## Metric Score: Score earned by the school on a given metric for a given student group
## Metric N: Number of students in a given student group included for a given metric 


##select variables (i.e., columns) of interest
analyticstardraft <- select(dc2019star,
    "LEA Code","School Name","School Code","School Framework","Student Group","Metric",
    "Metric Score","Metric N"                  
)
View(analyticstardraft)


##rename variables of interest into abbreviations
analyticstardraft <- rename(analyticstardraft,
                   leaid = "LEA Code", schnme = "School Name", schid = "School Code", 
                   schtype = "School Framework", stugrp = "Student Group",
                   mtrc = "Metric", mtrcsc = "Metric Score", mtrcnum = "Metric N"
)
View(analyticstardraft)


##filter observations (i.e., rows) of interest
analyticstardraft <- filter(analyticstardraft,
    leaid == "001",
    schtype == "Elementary School with Pre-Kindergarten",
    stugrp %in% c("American Indian/Alaskan Native","Asian","Black/African-American",
                  "Hispanic/Latino of any race","Native Hawaiian/Other Pacific Islander",
                  "White"),
    mtrc %in% c("90% Attendance") 
)
View(analyticstardraft)


##filter observations (i.e., rows) to remove non-numbers
analyticstar <- filter(analyticstardraft,
    mtrcsc != "n<10"
)
View(analyticstar)





#load dataset, open RIGHT sheet
dc2019card <-read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx", 
                                   sheet = "School Report Card Only Metrics")

#view dataset
View(dc2019card)


### PLAN TO CLEAN DATASET -- VARIABLES AND OBSERVATIONS TO KEEP
### Variable description pulled from "Data Dictionary" sheet 
### in "2019DCSchoolReportCardMetricScoresPublicData.xlsx"

## LEA Code: 3-4 digit identifier unique to each local education agency  
#            ***will keep only observations "001" for DCPS and drop others (charter, alternative); 
#            renders LEA Name redundant
## School Name: name of school
## School Code: 3-4 digit identifier unique to each school
## School Framework: DC SCHOOL REPORT CARD DOES NOT HAVE THIS DESCRIPTIVE VARIABLE
## Student Group: DC School Report Card includes metrics for student groups with a minimum n size of 10
#            ***will keep only observations for 6 ESSA-defined racial/ethnic groups: 
#            "American Indian or Alaskan Native", "Asian","Black or African American",
#            "Hispanic/Latino of any race", "Native Hawaiian or Other Pacific Islander", "White" 
#            and drop others
## Metric: DC School Report Card  metrics are designed to share information about student success and 
#            progress using different data elements associated with positive student outcomes
#            ***will keep "All Suspensions" 
#            and drop others
## Metric Score: Score earned by the school on a given metric for a given student group
## Metric N: Number of students in a given student group included for a given metric 


##select variables (i.e., columns) of interest
analyticcarddraft <- select(dc2019card,
                       "LEA Code","School Name","School Code","Student Group","Metric",
                       "Metric Score","Metric N"                  
)
View(analyticcarddraft)


##rename variables of interest into abbreviations
analyticcarddraft <- rename(analyticcarddraft,
                       leaid = "LEA Code", schnme = "School Name", schid = "School Code", 
                       stugrp = "Student Group", mtrc = "Metric", mtrcsc = "Metric Score", 
                       mtrcnum = "Metric N"
) 
View(analyticcarddraft)


##filter observations (i.e., rows) of interest
analyticcarddraft <- filter(analyticcarddraft,
                       leaid == "001",
                       stugrp %in% c("American Indian/Alaskan Native","Asian","Black/African-American",
                                     "Hispanic/Latino of any race","Native Hawaiian/Other Pacific Islander",
                                     "White"),
                       mtrc == "All Suspensions"
)
View(analyticcarddraft)


##filter (i.e., rows) to remove non-numbers
analyticcard <- filter(analyticcarddraft,
                       mtrcsc != "n<10"                   
)
View(analyticcard)





##join left and right datasets 
analyticcombinedraft <- left_join(
    analyticstar, analyticcard, by="schid"
)
View(analyticcombinedraft)


##check for missing data
View(
   filter(analyticcombinedraft, !complete.cases(analyticcombinedraft))
) # no missing data found


##select and remove redundant identifier columns
analyticcombinedraft <- select(analyticcombinedraft,
                   -leaid.x,-leaid.y,-schnme.y
)
View(analyticcombinedraft)


##filter and remove redundant rows by stugrp
analyticcombinedraft <- filter(analyticcombinedraft,
                   stugrp.x == stugrp.y
)
View(analyticcombinedraft)


##select redundant stugrp.y
analytic <- select(analyticcombinedraft,
                   -stugrp.y          
) 

##rename stugrp.x observations in preparation for pivoting  
analytic$rcode <- revalue(analytic$stugrp.x, c(
                  "Asian" = "A", "Black/African-American" = "B",
                  "Hispanic/Latino of any race" = "L", "Native Hawaiian/Other Pacific Islander" = "H",
                  "White" = "W",
                  "American Indian/Alaskan Native" = "N"))

View(analytic$rcode)
                    
                



##reshape dataset from long to wide
#KEEP THIS -- pivot_wider for race_90% attendance by school
analytic_widedraft3 <- pivot_wider(analytic, 
                                   schid,
                                   names_from = c("rcode","mtrc.x"), 
                                   names_sep = "_",
                                   values_from = mtrcsc.x
)
View(analytic_widedraft3)


#KEEP THIS -- pivot_wider for race_suspension by school
analytic_widedraft4 <- pivot_wider(analytic, 
                                   schid,
                                   names_from = c("rcode","mtrc.y"), 
                                   names_sep = "_",
                                   values_from = mtrcsc.y
)
View(analytic_widedraft4)


#left_join race_90% attendance by school, race_suspension by school
analytic_widedraftjoin <- left_join(
  analytic_widedraft3, analytic_widedraft4, 
  by="schid"
)
View(analytic_widedraftjoin)



##reshape dataset from wide to long
analytic_longdraft <- pivot_longer(analytic_widedraftjoin, 
                                    -schid,
                                    names_to = "stugrp",
                                    values_to = "90%attendrt"
) %>% mutate(stugrp = as.factor(stugrp)
)
View(analytic_longdraft) 


























analytic_widedraft2 <- pivot_wider(analytic, 
                                   -c("schnme.x","schid","schtype","stugrp.x"),
                                   names_from = rcode, 
                                   values_from = mtrcsc.x
)
View(analytic_widedraft2)




analytic_widedraft <- pivot_wider(analytic, schid, names_from = rcode, values_from = mtrcsc.x)

View(analytic_widedraft)





analytic_longdraft9 <- pivot_longer(analytic, 
                                    -c("schnme.x","schid","schtype","stugrp"),
                                    names_to = "mtrc",
                                    names_pattern = "(.)",
                                    values_to = c("mtrcsc", "mtrcnum")
) %>% mutate(mtrc = as.factor(mtrc)
)
View(analytic_longdraft9) 



analytic_longdraft8 <- pivot_longer(analytic, 
                                    -c("schnme.x","schid","schtype","stugrp"),
                                    names_to = "mtrc",
                                    names_pattern = "(.)",
                                    values_to = c("mtrcsc", "mtrcnum")
) %>% mutate(mtrc = as.factor(mtrc)
)
View(analytic_longdraft8) 
                                    




analytic_longdraft7 <- pivot_longer(analytic, 
                                    -c("schnme.x","schid","schtype","stugrp"),
                                    names_to = c("mtrc", "mtrcsc", "mtrcnum"),
                                    names_pattern = "new_?(.*)_(.)(.*)",
                                    values_to = c("mtrc", "mtrcsc", "mtrcnum")
                                    
                                    
) %>% mutate(mtrc = as.factor(mtrc)
)
View(analytic_longdraft7) 



analytic_longdraft4 <- pivot_longer(analytic, 
                                    -c("schnme.x","schid","schtype","stugrp"),
                                    names_to = c("mtrc.z", "mtrcsc.z", "mtrcnum.z"),
                                    names_pattern = "(.)(.)(.)",
                                    names_repair = "minimal",
                                    values_to = c("mtrc", "mtrcsc", "mtrcnum")
) %>% mutate(mtrc = as.factor(mtrc)
)
View(analytic_longdraft4) 


analytic_longdraft3 <- pivot_longer(analytic, 
                                   -c("schnme.x","schid","schtype","stugrp"),
                                   names_to = c("mtrc", "mtrcsc", "mtrcnum"),
                                   names_sep ="(.)(.)(.)"
) %>% mutate(mtrc = as.factor(mtrc)
)
View(analytic_longdraft3) 


analytic_longdraft2 <- pivot_longer(analytic, 
                                   -c("schnme.x","schid","schtype"),
                                   names_to = c("stugrp"),
                                   names_pattern = "(.)"
)
View(analytic_longdraft2)                                                
                                                
                                                mtrc", "mtrcsc", "mtrcnum"),
                                   values_to = "(.)(._(._"
)
View(analytic_longdraft)



analytic_longdraft <- pivot_longer(analytic, 
                               -c("schnme.x","schid","schtype","stugrp"),
                               names_to = c("mtrcnum","mtrc", "mtrcsc", "mtrcnum"),
                               names_pattern = "(.)(.)(.)(.)"
)
View(analytic_longdraft)




                               names_to = c("stugrp", "mtrc", "mtrcsc", "mtrcnum"),
                               values_to = 
)                              
View(analytic_long3)


analytic_long3 <- pivot_longer(analytic, 
                              -c(schnme.x, schid, schtype),
                              names_to = c("stugrp.y", "mtrc.y", "mtrcsc.y", "mtrcnum.y"),
                              names_pattern="(.)(.)"
)                              
View(analytic_long3)


analytic_long <- pivot_longer(analytic, 
                              -c(schnme.x, schid, schtype, stugrp.x, mtrc.x, mtrcsc.x, mtrcnum.x),
                              names_to = c("stugrp.y", "mtrc.y", "mtrcsc.y", "mtrcnum.y"),
                              names_pattern="(.)(.)"
)                              
View(analytic_long)




analytic_longdraft2 <- pivot_longer(analytic, 
                              -c(schnme.x, schid, schtype, stugrp.x, mtrc.x, mtrcsc.x, mtrcnum.x),
                              names_to="stugrp.x",
                              values_to="mtrc","mtrcsc","mtrcnum"
)                             
View(analytic_longdraft)
                              
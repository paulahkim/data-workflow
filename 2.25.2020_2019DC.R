#clear all prior data and work to ensure a clean environment
rm(list=ls())

#download dataset to intended working directory
#https://drive.google.com/open?id=1p9CtNgDE5Lj1muEkxQqfOWdop2NiAEjV

#set working directory to folder where dataset is saved
setwd("~/Desktop/Data Workflow/R practice")

#program to open tidyverse
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
    mtrc %in% c("90% Attendance","Meeting or Exceeding Expectations - ELA", 
                "Meeting or Exceeding Expectations - Math") 
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
analytic <- filter(analyticcombinedraft,
                   stugrp.x == stugrp.y
)
View(analytic)





##simple aggregates for summary statistics
analytic %>%


#download dataset to working directory
#https://drive.google.com/open?id=1p9CtNgDE5Lj1muEkxQqfOWdop2NiAEjV

#clear all prior data and work to ensure a clean environment
rm(list=ls())

#set working directory to identify folder before opening file
setwd("~/Desktop/Data Workflow/R practice")

#open tidyverse
library(tidyverse)

#open package to open .csv and excel files
library(readxl)  



#load dataset, open FIRST sheet
dcreport2019starsheet <-read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx", 
                                   sheet = "School STAR Metric Scores")

#view dataset using BASE R
View(dcreport2019starsheet)


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
## Domain: STAR Framework metrics are grouped into domains: Academic Achievement, Academic Growth, 
#            School Enviroment, Graduation Rate, and English Language Proficiency
## Metric: STAR Framework metrics are designed to share information about student success and 
#            progress using different data elements associated with positive student outcomes
#            ***will keep "90% Attendance", "Approaching, Meeting or Exceeding Expectations - ELA",
#            "Approaching, Meeting or Exceeding Expectations - Math" 
#            and drop others
## Metric Score: Score earned by the school on a given metric for a given student group
## Metric N: Number of students in a given student group included for a given metric 


## Using TIDYVERSE to select variables of interest
analyticstar <- select(dcreport2019starsheet,
    "LEA Code","School Name","School Code","School Framework","Student Group","Domain","Metric",
    "Metric Score","Metric N"                  
)

View(analyticstar)


## Using TIDYVERSE to rename observations of interest into abbreviations
analyticstar <- rename(analyticstar,
                   leaid = "LEA Code", schnme = "School Name", schid = "School Code", 
                   schtype = "School Framework", stugrp = "Student Group", dom = "Domain",
                   mtrc = "Metric", mtrcsc = "Metric Score", mtrcnum = "Metric N"
)


## Using TIDYVERSE to select observations of interest
analyticstar <- filter(analyticstar,
    leaid == "001",
    schtype == "Elementary School with Pre-Kindergarten",
    stugrp %in% c("American Indian or Alaskan Native","Asian","Black or African American",
                  "Hispanic/Latino of any race","Native Hawaiian or Other Pacific Islander",
                  "White"),
    mtrc %in% c("90% Attendance","Meeting or Exceeding Expectations - ELA", 
                "Meeting or Exceeding Expectations - Math") 
)





#load dataset, open SECOND sheet
dcreport2019cardsheet <-read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx", 
                                   sheet = "School Report Card Only Metrics")

#view dataset using BASE R
View(dcreport2019cardsheet)


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
## Domain: DC SCHOOL REPORT CARD DOES NOT HAVE THIS DESCRIPTIVE VARIABLE 
## Metric: DC School Report Card  metrics are designed to share information about student success and 
#            progress using different data elements associated with positive student outcomes
#            ***will keep "All Suspensions" 
#            and drop others
## Metric Score: Score earned by the school on a given metric for a given student group
## Metric N: Number of students in a given student group included for a given metric 


## Using TIDYVERSE to select variables of interest
analyticcard <- select(dcreport2019cardsheet,
                       "LEA Code","School Name","School Code","Student Group","Metric",
                       "Metric Score","Metric N"                  
)

View(analyticcard)


## Using TIDYVERSE to rename observations of interest into abbreviations
analyticcard <- rename(analyticcard,
                       leaid = "LEA Code", schnme = "School Name", schid = "School Code", 
                       stugrp = "Student Group", mtrc = "Metric", mtrcsc = "Metric Score", 
                       mtrcnum = "Metric N"
)


## Using TIDYVERSE to select observations of interest
analyticcard <- filter(analyticcard,
                       leaid == "001",
                       stugrp %in% c("American Indian or Alaskan Native","Asian",
                                     "Black or African American","Hispanic/Latino of any race", 
                                     "Native Hawaiian or Other Pacific Islander","White"),
                       mtrc == "All Suspensions"
)

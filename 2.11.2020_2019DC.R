#clear all prior data and work to ensure a clean environment
rm(list=ls())   

#set working directory to identify folder before opening file
setwd("~/Desktop/Data Workflow/R practice")

#open file; this particular package allows R to open .csv and excel files
library(readxl)  

#load dataset, opens first sheet 
dcreport2019 <- read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx")

#load dataset, opens specific sheet
dcreport2019starsheet <-read_excel("2019DCSchoolReportCardMetricScoresPublicData.xlsx", sheet = "School STAR Metric Scores" )

#view dataset
View(dcreport2019starsheet)

# view headers
head(dcreport2019starsheet)

# see summary of min, 1st quartile, median, 3rd quartile, max
summary(dcreport2019starsheet)

# see number of columns
length(dcreport2019starsheet)

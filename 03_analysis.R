# Copyright 2019 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

source("header.R")
#Calculate non hunted mortality - known + unreported
FemaleUnk_Report_pop$UnReportedFemaleMort <- round((FemaleUnk_Report_pop$FemaleUnk_NHuntMort_10yrAvg*FemaleUnk_Report_pop$UnReportRatio),2)
FemaleUnk_Report_pop$TotalFemale_NHuntMort<-round((FemaleUnk_Report_pop$UnReportedFemaleMort + FemaleUnk_Report_pop$FemaleUnk_NHuntMort_10yrAvg),2)
#List hunted mortality
FemaleUnk_Report_pop$TotalFemale_HuntMort<-FemaleUnk_Report_pop$FemaleUnk_HuntMort_10yrAvg
#Total mortality
FemaleUnk_Report_pop$TotalFemale_Mort<-round((FemaleUnk_Report_pop$TotalFemale_HuntMort+FemaleUnk_Report_pop$TotalFemale_NHuntMort),2)

FemaleUnk_Report_pop$pc_Mort <- round(FemaleUnk_Report_pop$TotalFemale_Mort/FemaleUnk_Report_pop$pop2018*100,2)
FemaleUnk_Report_pop$pc_Mort[is.na(FemaleUnk_Report_pop$pc_Mort)]<-0

#db <- gsub(",","",db) and then run as.numeric(db)


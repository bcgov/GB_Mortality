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
#Calculate key GBPU metrics for mortality - pc_Female_Mort and initial Threat classification
FemaleUnk_Report_pop_WMU<-FemaleUnk_Report_pop_WMU %>%
  mutate(UnReportedFemaleMort = round((FemaleUnk_NHuntMort_10yrAvg*UnReportRatio),2)) %>%
  mutate(TotalFemale_NHuntMort = round((UnReportedFemaleMort + FemaleUnk_NHuntMort_10yrAvg),2)) %>%
  mutate(TotalFemale_HuntMort = FemaleUnk_HuntMort_10yrAvg) %>%
  mutate(TotalFemale_Mort = round((TotalFemale_HuntMort + TotalFemale_NHuntMort),2)) %>%
  mutate(pc_Female_Mort = round(TotalFemale_Mort/EST_POP_2018*100,2)) %>%
  mutate(fem_mng_targ = round(Manage_target/3,2)) %>%
  mutate(Mort_Mng_Flag = case_when(fem_mng_targ > pc_Female_Mort ~ 0, TRUE ~ 1 )) %>%
  mutate_all(funs(ifelse(is.na(.), 0, .))) %>%
  mutate(Mort_Bio_Threat = case_when(pc_Female_Mort < 1.33  ~ 0,
                                     pc_Female_Mort >= 1.33 & pc_Female_Mort < 2 ~ 1,
                                     pc_Female_Mort >= 2 & pc_Female_Mort < 3.33 ~ 2,
                                     pc_Female_Mort >= 3.33 ~ 3 ))


saveRDS(FemaleUnk_Report_pop_WMU, file = 'tmp/FemaleUnk_Report_pop_WMU')
#FemaleUnk_Report_pop_WMU<- readRDS(file = 'tmp/FemaleUnk_Report_pop_WMU')





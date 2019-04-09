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
#Calculate non hunted mortality columns, mangement targets and biological targets
FemaleUnk_Report_pop<-FemaleUnk_Report_pop %>%
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

    #  %>% dplyr::select(WMUid, MU = MU.y, LEH, GRIZZLY_BEAR_POP_UNIT_ID, POPULATION_NAME, EST_POP_2018, FemaleUnk_HuntMort_10yrAvg, FemaleUnk_NHuntMort_10yrAvg, UnReportRatio,Manage_target)

# assess each MU agains a bilogical and management target and assign a class:
Female -
o	0-1.33% none ie 4% total
o	1.33-2 % Low - 6% total - approaching issue
o	2-3.33 % Medium - >6%
o	>3.33 % High - well above

* Setting Mortality thresholds - Steve M. is pulling together table
* Negligible - <2%
* Low - 2-4 Mortality (McLellan et al 2016 - page 6)
* Med > 4
* High - > 6



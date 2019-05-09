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

# by GBPU, area/percent of each threat category, ie GBPU 0 1 2 3 4 - table populated by area
# then assign an overall threat based on their proportion
WMU_GB_Summary <- FemaleUnk_Report_pop_WMU %>%
              mutate(Neg = case_when(Mort_Bio_Threat == 0 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 0 ~ 0)) %>%
              mutate(Low = case_when(Mort_Bio_Threat ==1 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 1 ~ 0)) %>%
              mutate(Med = case_when(Mort_Bio_Threat == 2 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 2 ~ 0)) %>%
              mutate(High = case_when(Mort_Bio_Threat == 3 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 3 ~ 0)) %>%
              group_by(GBPU=GRIZZLY_BEAR_POP_UNIT_ID, GBPU_Name=POPULATION_NAME) %>%
              dplyr::summarise(Neg=sum(Neg),Low=sum(Low),Med=sum(Med),High=sum(High),
                               AREA_KM2_noWaterIce=sum(AREA_KM2_noWaterIce), EST_POP_2018=sum(EST_POP_2018),
                               FemaleUnk_HuntMort_10yrAvg=sum(FemaleUnk_HuntMort_10yrAvg),
                               TotalFemale_HuntMort=sum(TotalFemale_HuntMort),
                               FemaleUnk_NHuntMort_10yrAvg=sum(FemaleUnk_NHuntMort_10yrAvg),
                               UnReportedFemaleMort_WMU=sum(UnReportedFemaleMort),
                               #Carry over Total Females mort calculated and re-calculate % of populations
                               #This reflects the difference between the GBPU and WMU approach
                               TotalFemale_Mort_WMU=sum(TotalFemale_Mort)
              ) %>%
              merge(UnReport_GBPU, by.x='GBPU_Name', by.y='GBPU') %>%

              mutate(UnReportedFemaleMort = round((FemaleUnk_NHuntMort_10yrAvg*UnReportRatio),2)) %>%
              mutate(TotalFemale_NHuntMort = round((UnReportedFemaleMort + FemaleUnk_NHuntMort_10yrAvg),2)) %>%
              mutate(TotalFemale_NHuntMort_WMU = round((UnReportedFemaleMort_WMU + FemaleUnk_NHuntMort_10yrAvg),2)) %>%
              mutate(TotalFemale_Mort = round((TotalFemale_HuntMort + TotalFemale_NHuntMort),2)) %>%
              mutate(pc_Female_Mort = round(TotalFemale_Mort/EST_POP_2018*100,2)) %>%
              mutate(pc_Female_Mort_WMU = round(TotalFemale_Mort_WMU/EST_POP_2018*100,2)) %>%

              mutate(pcNeg=round(Neg/AREA_KM2_noWaterIce*100,2)) %>%
              mutate(pcLow=round(Low/AREA_KM2_noWaterIce*100,2)) %>%
              mutate(pcMed=round(Med/AREA_KM2_noWaterIce*100,2)) %>%
              mutate(pcHigh=round(High/AREA_KM2_noWaterIce*100,2)) %>%
              mutate(Mort_Bio_Threat = case_when(pc_Female_Mort_WMU < 1.33  ~ 0,
                            pc_Female_Mort_WMU >= 1.33 & pc_Female_Mort_WMU < 2 ~ 1,
                            pc_Female_Mort_WMU >= 2 & pc_Female_Mort_WMU < 3.33 ~ 2,
                            pc_Female_Mort_WMU >= 3.33 ~ 3 )) %>%
              mutate(Mort_Bio_Threat_wt = case_when(pcNeg > 50 ~ '0',
                            pcLow > 50 ~ '1',
                            pcHigh > 50 ~ '3',
                            pcMed > 50 ~ '2',
                            (pcMed + pcHigh) > 50 ~ '3',
                            (pcLow + pcMed) > 50 & pcHigh == 0  ~ '2',
                            (pcLow + pcHigh) > 50 & pcMed == 0 ~ '2'
                            ))

saveRDS(WMU_GB_Summary, file = 'tmp/WMU_GB_Summary')
#WMU_GB_Summary<- readRDS(file = 'tmp/WMU_GB_Summary')


#Data check
Check<-WMU_GB_Summary %>%
  merge(GB_Summary, by='GBPU') %>%
  dplyr::select(GBPU_Name=GBPU_Name.x, TotalFemale_Mort_WMU=TotalFemale_Mort_WMU, TotalFemale_Mort_GBPU=TotalFemale_Mort.y,
                pc_Female_Mor_WMU=pc_Female_Mort_WMU, pc_Female_Mor_GBPU=pc_Female_Mort.y,
                Mort_Bio_Threat_WMU=Mort_Bio_Threat.x,Mort_Bio_Threat_GBPU=Mort_Bio_Threat.y,
                pcNeg, pcLow, pcMed,pcHigh)





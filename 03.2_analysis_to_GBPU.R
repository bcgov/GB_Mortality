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
GBPU_Summary <- FemaleUnk_Report_pop %>%
                mutate(Neg = case_when(Mort_Bio_Threat == 0 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 0 ~ 0)) %>%
                mutate(Low = case_when(Mort_Bio_Threat ==1 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 1 ~ 0)) %>%
                mutate(Med = case_when(Mort_Bio_Threat == 2 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 2 ~ 0)) %>%
                mutate(High = case_when(Mort_Bio_Threat == 3 ~ AREA_KM2_noWaterIce,
                         Mort_Bio_Threat != 3 ~ 0)) %>%
               group_by(GRIZZLY_BEAR_POP_UNIT_ID, POPULATION_NAME) %>%
               dplyr::summarise(Neg=sum(Neg),Low=sum(Low),Med=sum(Med),High=sum(High),Areaha=sum(AREA_KM2_noWaterIce)) %>%
              mutate(pcNeg=round(Neg/Areaha*100,2)) %>%
              mutate(pcLow=round(Low/Areaha*100,2)) %>%
              mutate(pcMed=round(Med/Areaha*100,2)) %>%
              mutate(pcHigh=round(High/Areaha*100,2)) %>%


#How to roll up to GBPU WMU mort as a grid, for each GBPU - what combos of morts?
# >50 is neg then GBPU is neg
# >50 is low then low
# >50 is med and low then low
# >50 is high and med then med
# >50 is high then high

GBPU_Summary2<- GBPU_Summary %>%
  mutate(Threat = case_when(pcNeg > 50 ~ 'Neg',
                            pcLow > 50 ~ 'Low',
                            (pcLow + pcMed) > 50 ~ 'Med',
                            (pcLow + pcMed + pcHigh) > 50 ~ 'Med',
                            pcMed > 50 ~ 'Med',
                            pcMed+pcHigh>50 ~ 'High',
                            pcHigh > 50 ~ 'High'))



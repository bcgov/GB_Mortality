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

#Combine point over poly to get WMU_LEH names and id for each kill
GB_WMU<-st_transform(GB_WMU,crs="+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

CIpointwWMU<-CIpoint %>%
  st_join(GB_WMU, join = st_intersects) %>%
  mutate(WMUid=as.numeric(GBPU_MU_LEH_uniqueID)) %>%
  mutate(LEH=as.character(LEH_Zone2_fix)) %>%
  dplyr::select(WMUid,MU,LEH,KillYear,KILL_CODE,HuntMort,NonHuntMort)

# Summarise non-hunt kill data for female + unknown, 10 years from 2008 to 2017
FemaleUnk_Report_WMU<-CIpointwWMU %>%
  group_by(WMUid, MU, LEH) %>%
  dplyr::summarise(THuntMort=sum(HuntMort),TNonHuntMort=sum(NonHuntMort)) %>%
  mutate(FemaleUnk_HuntMort_10yrAvg = THuntMort/10) %>%
  mutate(FemaleUnk_NHuntMort_10yrAvg = TNonHuntMort/10) %>%
  dplyr::select(WMUid, MU, LEH, THuntMort, FemaleUnk_HuntMort_10yrAvg, TNonHuntMort,FemaleUnk_NHuntMort_10yrAvg)

# Remove geometry so a simple data.frame
st_geometry(FemaleUnk_Report_WMU) <- NULL

#Join WMU, population estimate - from file, reported female+unknown mortality
#set NAs to 0
#set where MAX_ALLOW_MORT_PERC to minimum of 4%
FemaleUnk_Report_pop_WMU<-FemaleUnk_Report_WMU %>%
  merge(gb2018WMUpop, by.x='WMUid', by.y='GBPU_MU_LEH_uniqueID', all.y=TRUE) %>%
  merge(UnReport_WMU,by='WMUid') %>%
  mutate_all(funs(ifelse(is.na(.), 0, .))) %>%
  mutate(Manage_target = case_when(MAX_ALLOW_MORT_PERC == 0 ~ 4, TRUE ~ MAX_ALLOW_MORT_PERC)) %>%
  #mutate(test = ifelse(MAX_ALLOW_MORT_PERC == 0, 4, MAX_ALLOW_MORT_PERC)) %>%
  dplyr::select(WMUid, MU = MU.y, AREA_KM2_noWaterIce, LEH=LEH.y, GRIZZLY_BEAR_POP_UNIT_ID, POPULATION_NAME, EST_POP_2018, FemaleUnk_HuntMort_10yrAvg, FemaleUnk_NHuntMort_10yrAvg, UnReportRatio,Manage_target)








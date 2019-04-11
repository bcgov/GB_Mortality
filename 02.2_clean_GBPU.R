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

#Combine point (CI) over poly (GBPU) to get GBPU names and id for each kill
GBPU<-st_transform(GBPU,crs="+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

CIpointwGBPU<-CIpoint %>%
  st_join(GBPU, join = st_intersects) %>%
  mutate(GBPU=as.numeric(GBPU)) %>%
  mutate(GBPU_Name=as.character(POPUL)) %>%
  dplyr::select(GBPU,GBPU_Name,KillYear,KILL_CODE,HuntMort,NonHuntMort)

# Summarise non-hunt kill data for female + unknown, 10 years from 2008 to 2017
FemaleUnk_Report_GBPU<-CIpointwGBPU %>%
  group_by(GBPU,GBPU_Name) %>%
  dplyr::summarise(THuntMort=sum(HuntMort),TNonHuntMort=sum(NonHuntMort)) %>%
  mutate(FemaleUnk_HuntMort_10yrAvg = THuntMort/10) %>%
  mutate(FemaleUnk_NHuntMort_10yrAvg = TNonHuntMort/10) %>%
  dplyr::select(GBPU, GBPU_Name, THuntMort, FemaleUnk_HuntMort_10yrAvg, TNonHuntMort,FemaleUnk_NHuntMort_10yrAvg)

# Remove geometry so a simple data.frame
st_geometry(FemaleUnk_Report_GBPU) <- NULL

#Join GBPU, population estimate - from file, reported female+unknown mortality
FemaleUnk_Report_pop_GBPU<-FemaleUnk_Report_GBPU %>%
  merge(gb2018GBPUpop, by.x='GBPU', by.y='GRIZZLY_BEAR_POP_UNIT_ID', all.y=TRUE) %>%
  merge(UnReport_GBPU,by.x='GBPU_Name', by.y='GBPU', all.x=TRUE) %>%
  mutate_all(funs(ifelse(is.na(.), 0, .))) %>%
  #mutate(Manage_target = case_when(MAX_ALLOW_MORT_PERC == 0 ~ 4, TRUE ~ MAX_ALLOW_MORT_PERC)) %>%
  #mutate(test = ifelse(MAX_ALLOW_MORT_PERC == 0, 4, MAX_ALLOW_MORT_PERC)) %>%
  dplyr::select(GBPU, GBPU_Name=POPULATION_NAME, AREA_KM2_noWaterIce, EST_POP_2018, FemaleUnk_HuntMort_10yrAvg, FemaleUnk_NHuntMort_10yrAvg, UnReportRatio)


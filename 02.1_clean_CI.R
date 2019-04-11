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

# Assign GBPU to each location
# select only last 10 years of records - all have georeferencing
CIpoint1 <- GB_CI %>%
  filter(KillYear <2018 & KillYear>2007 & SEX != 'M') %>%
  mutate(HuntMort=as.numeric(KILL_CODE == 1)) %>%
  mutate(NonHuntMort=as.numeric(KILL_CODE != 1))
  #filter(KILL_CODE != 1 & KillYear <2018 & KillYear>2007 & SEX != 'M')

#Covers 4 UTM zones - make an sf for each zone then project to Albers and combine them
utmOut<-list()
utms<-c(8,9,10,11)
for (j in 1:length(utms)) {
   i<-utms[j]
   utmOut[[j]] <-CIpoint1 %>%
    filter(ZONE_NO==i) %>%
    st_as_sf(coords = c("Easting", "Northing")
    ,crs=paste("+proj=utm +zone=",i,sep='')) %>%
    st_transform(crs="+proj=aea +lat_1=50 +lat_2=58.5 +lat_0=45 +lon_0=-126 +x_0=1000000 +y_0=0 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
  }

#combine the list of sf objects into a single geometry and export for inspection
CIpoint<-do.call(rbind, utmOut)
st_write(CIpoint, file.path(spatialOutDir,'CIpoint.shp'), delete_layer = TRUE)

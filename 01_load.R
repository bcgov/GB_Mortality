# Copyright 2018 Province of British Columbia
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

# Repo estimates unreported mortality for each GBPU based on:
# 1. core security (in % by GBPU). Note: replaces previous statistic of % capable within 50km of areas with >5000 people
# 2. Hunter day density -> HunterDensity repo: https://github.com/bcgov/HunterDensity
# Note: previously used Large Ungulate harvest replaced by hunter day density above
# 3. frontcountry (in % by GBPU) - from provincial CE Grizzly protocol. Note: replaces previous statistic of % capable habitat with roads

source("header.R")

#GBPU_lutFile <- file.path(StrataDir,"GBPU_lut")
#GBPU_lut <- readRDS(file = GBPU_lutFile)
#colnames(GBPU_lut)<-c('GBPUid','GBPU')

#Load Cumpulsory Inspection (CI) data
GB_CI <- data.frame(read_xlsx(file.path(DataDir, "CI/CI-1978-2017_Don.xlsx"), sheet=NULL))

#GB_Unreported data for GBPU and WMU are loaded
#Fist GBPU
StrataL <- c('GBPUr','GBPUr_NonHab')
num<-length(StrataL)

#GBPU - Read in unreported mortality data from excel generated by the repo GB_Unreproted - 04_output_RevisedRanking.R
UnrepLR<-list()
for (i in 1:num) {
  StratName<-StrataL[i]
  UnrepLR[[i]] <-
    data.frame(read_xls(file.path(UnRepDataDir,paste('UnReported_GBPU.xls',sep='')), sheet=StratName)) %>%
    mutate(UnReportRatio=UnReport) %>%
    dplyr::select(GBPU,UnReportRatio)
}

#select the full GBPU - 'GBPUr'
UnReport_GBPU<-UnrepLR[[1]]

#Read in spatial files used
GBPUr<-raster(file.path(StrataDir,"GBPUr.tif"))
GBPU<-st_read(file.path(GBspatialDir,'GBPU.shp'))
#GBPU_lut<-readRDS(file = file.path(StrataDir,'GBPU_lut'))
#colnames(GBPU_lut)<-c('GBPU','GBPU_Name')

#########
#WMU - Read in unreported mortality data from excel generated by the repo GB_Unreproted - 04_output_RevisedRanking.R
StrataL <- c('GB_WMU_id','GB_WMU_id_NonHab')
num<-length(StrataL)

UnrepLR<-list()
for (i in 1:num) {
  StratName<-StrataL[i]
  # Read in strata sheet and modify so GBPUs consistent with current 55 GBPUs
  # North Purcells = North Purcells + Spillamacheen
  # Central-South Purcells = South Purcells + Central Purcells
  # Drop those records since new has recalculated values based on 55
  UnrepLR[[i]] <-
    data.frame(read_xls(file.path(UnRepDataDir,paste('UnReported_WMU.xls',sep='')), sheet=StratName)) %>%
    mutate(UnReportRatio=UnReport) %>%
    dplyr::select(WMUid, MU, LEH,UnReportRatio)
}

#select the full GBPU for now - 'GBPUr'
UnReport_WMU<-UnrepLR[[1]]

#Load 2018 grizzly bear population data from the GB_data prep
#from the 2018 gdb
gb2018WMUpop <- data.frame(read_xls(file.path(GBDataOutDir, "WMUpop.xls"), sheet=NULL))
gb2018GBPUpop <- data.frame(read_xls(file.path(GBDataOutDir, "GBPUpop.xls"), sheet=NULL))


#Read in spatial files used
WMUr<-raster(file.path(StrataDir,"WMUr.tif"))
WMU<-st_read(file.path(GBspatialDir,'WMU.shp'))
GB_WMU_File <- file.path(StrataDir ,'GB_WMU')
GB_WMU<-readRDS(file = GB_WMU_File)


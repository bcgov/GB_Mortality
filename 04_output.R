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

# Spreadsheet of Mortality data by GBPU
WriteXLS(Mort_UnRep, file.path(dataOutDir,paste('Mort_UnRep.xls',sep='')))

# Mortality raster for IUCN assessment
MortR<-subs(GBPUr,Mort_UnRep, by='GBPU',which='pc_Mort')
writeRaster(MortR, filename=file.path(spatialOutDir,"MortR.tif"), format="GTiff", overwrite=TRUE)


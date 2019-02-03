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
MortR<-subs(GBPUr,Mort_UnRep, by='GBPUid',which='pc_Mort')
writeRaster(MortR, filename=file.path(spatialOutDir,"MortR.tif"), format="GTiff", overwrite=TRUE)

#Make a pretty table for GBPU
library(htmltools)
library(webshot)
library(formattable)

df<-Mort_UnRep %>%
  dplyr::select(GBPU,PopEst, ReportedFemaleMort, UnReport, UnReportedFemaleMort,TotalFemaleMort,pc_Mort)
colnames(df)<-c('GBPU','Pop 2018','Reported Female Mortality','Unreported Mortality Ratio',
                'Unreported Female Mortality','Total Female Mortality','per cent Mortality')

# formattable export function
export_formattable <- function(f, file, width = "100%", height = NULL,
                               background = "white", delay = 0.2)
{
  w <- as.htmlwidget(f, width = width, height = height)
  path <- html_print(w, background = background, viewer = NULL)
  url <- paste0("file:///", gsub("\\\\", "/", normalizePath(path)))
  webshot(url,
          file = file,
          selector = ".formattable_widget",
          delay = delay)
}
#(source: https://github.com/renkun-ken/formattable/issues/26)

DT<-formattable(df, list(
  GBPU = color_tile("white", "orange"),
  formattable::area(col = c('Pop 2018')) ~ normalize_bar("pink", 0.1),
  formattable::area(col = c('Reported Female Mortality')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('Unreported Mortality Ratio')) ~ normalize_bar("lightgreen", 0.01),
  formattable::area(col = c('Unreported Female Mortality')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('Total Female Mortality')) ~ normalize_bar("lightgrey", 0.01),
  'per cent Mortality' = formatter("span", style = x ~
                                   ifelse(x < 1.66 ,style(color = "green", font.weight = "bold"), style(color = "red",
                                                                                                     font.weight = "bold")))
))

#webshot::install_phantomjs()
export_formattable(DT,file.path(figsOutDir,"GBMortalityTable.png"))

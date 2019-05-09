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

# Spreadsheet of Mortality data by WMU
FemaleUnk_Report_pop_WMU<- readRDS(file = 'tmp/FemaleUnk_Report_pop_WMU')

WriteXLS(FemaleUnk_Report_pop_WMU, file.path(dataOutDir,paste('MortalityThreat_WMU.xls',sep='')))

#Make a pretty table for GBPU
library(htmltools)
library(webshot)
library(formattable)

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
FemaleUnk_Report_pop_WMU<-FemaleUnk_Report_pop_WMU[order(FemaleUnk_Report_pop_WMU$POPULATION_NAME),]

df1<-FemaleUnk_Report_pop_WMU[1:240,] %>%
  dplyr::select(WMUid, POPULATION_NAME, MU, LEH, EST_POP_2018, FemaleUnk_NHuntMort_10yrAvg, UnReportRatio, UnReportedFemaleMort,
                TotalFemale_NHuntMort, TotalFemale_HuntMort, TotalFemale_Mort, pc_Female_Mort)

colnames(df1)<-c('WMUid','GBPU','MU','LEH','Pop 2018','10yr Avg Reported Female Non-Hunt Mortality','Unreported Non-Hunt Mortality Ratio',
                 'Unreported Non-Hunt Female Mortality','Total Non-Hunt Female Mortality',
                 '10yr Avg Total Hunt Female Mortality','Total Female Mortality','per cent Female Mortality')
df1$WMUid <- factor(df1$WMUid)

#df.list<-list(df1,df2)
df.list<-list(df1)
DT.list<-list()
npages<-1
for (j in 1:npages) {
  df<-df.list[[j]]
  rownames(df)<-NULL

  DT<-formattable(df[order(df$GBPU),], list(
  'GBPU' = color_tile("white", "orange"),
  formattable::area(col = c('Pop 2018')) ~ normalize_bar("pink", 0.1),
  formattable::area(col = c('10yr Avg Reported Female Non-Hunt Mortality')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('Unreported Non-Hunt Mortality Ratio')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('Unreported Non-Hunt Female Mortality')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('Total Non-Hunt Female Mortality')) ~ normalize_bar("lightblue", 0.01),
  formattable::area(col = c('10yr Avg Total Hunt Female Mortality')) ~ normalize_bar("lightgreen", 0.01),
  formattable::area(col = c('Total Female Mortality')) ~ normalize_bar("lightgrey", 0.01),
  'per cent Mortality' = formatter("span", style = x ~
   ifelse(x < 1.33 ,style(color = "green", font.weight = "bold"), style(color = "red",
   font.weight = "bold")))
))

#webshot::install_phantomjs()
DT.list[[j]]<-DT
export_formattable(DT,file.path(figsOutDir,paste("WMU_GBMortalityTablewDensity.png",sep='')))
}

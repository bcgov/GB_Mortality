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

library(RCurl)

#FTPtarget <-"ftp.geobc.gov.bc.ca/pub/incoming/FromDonMorgan/"
FTPtarget <-'ftp.for.gov.bc.ca/HRE/gov_internal/incoming/Morgan/'
FileDir<-'GB_Mortality'
FileToUpload<-c(file.path(dataOutDir,'FemaleUnk_Report_pop.xls'),
                file.path(figsOutDir,'GBMortalityTablewDensity_1.png'),
                file.path(figsOutDir,'GBMortalityTablewDensity_2.png'))

#remove existing ftp directory- will error if doesnt exist
curlPerform(url=FTPtarget, postquote=paste("RMD ",FileDir,sep=''), userpwd = "domorgan:1SummerHaze")
curlPerform(url=FTPtarget, postquote=paste("MKD ",FileDir,sep=''), userpwd = "domorgan:1SummerHaze")

#Loop through all the files to load to the FTP
for (i in 1:length(FileToUpload)) {

          ftpUpload((paste(FileToUpload[i],sep='')),
            paste(FTPtarget,FileDir,'/',sub('.*\\/', '', FileToUpload[i]),sep=''),
            userpwd = "domorgan:1SummerHaze")
}

#Send email to Rob that files are posted - works to my gmail but not rob for some reason?
from <- "<dmorgan9009@gmail.com>"
#to <- "<Rob.Oostlander@gov.bc.ca>"
#to <- "<don.morgan@gov.bc.ca>"
to = "<dmorgan9009@gmail.com>"
mailControl<-list(smtpServer="ASPMX.L.GOOGLE.COM")

#mailControl=list(smtpServer="smtp.gmail.com")
library(sendmailR)

subject <- "Grizzly FTP Load"
body <- paste("Hi Rob - the FTP directory ",FTPtarget,
        FileDir,' has been posted/refreshed on: ',Sys.time(),sep='')

sendmail_options(smtpPort="25")
sendmail(from=from,to=to,subject=subject,msg=body,control=mailControl)

#To delete on server
#curlPerform(url="ftp://xxx.xxx.xxx.xxx/", quote="DELE file.txt", userpwd = "user:pass")


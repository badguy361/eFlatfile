library(dplyr)
# import records
rec_FM_Vs30 <- read.table(file="sgm.2021_Frv_Fnm.rec.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/GDMS_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
#
# check <- rec_FM_Vs30[,c(1:3,101:114)]
################################################################## 

#!?��?��經�?�公弝�?��?�斷層面穝〝長寬�?�〝斷層破裂面?��度�?�寬�?
#!=================================================================
#  !    計�?�斷層面�?                                                |
#  !    Wells and Coppersmith(1994):                                |
#  !    log(A)=-3.49+0.91*M     sigma(log(A))=0.24                  |
#  !    ??�矩覝模?��?��範�?��??4.8~7.9                                   |
#  !=================================================================     
#  !    NGA計畫中�?��?�斷層破裂面之長寬�??                             |
#  !    log(AR)=(0.01752-0.00472*FN-0.01099*FR)*(M-4)**3.097        |
#  !=================================================================

# 依�?��?��?�碩士�?��?��?�NGA使用??�面穝長寬�?? (AR,aspect ratio)
# AR <- function(Mw,Fnm,Frv){
#   x1 <- Mw-4
#   AR <- 10**((0.01752-0.00472*Fnm-0.01099*Frv)*(x1**3.097))
#   #AR
#   sprintf("%.10f", AR)
# }
################################################################## 

################################################
# output for Fortran code (plane1)
tmp = inner_join(x = rec_FM_Vs30, y = catalog, by = "event_id")
cal.plane1 = inner_join(x = tmp, y = stations, by = "station")

# cal.plane1 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output1 <- cal.plane1[c("event_id","longitude","latitude","Mw","depth","GCMT_Strike1","GCMT_Dip1","Fnm_1","Frv_1","lon","lat","filter.id")] 
write.table(output1,file="Fortran_plane1/2016_fy_in_plane1.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE)  # ,na="0"

# output for Fortran code (plane2)
# cal.plane2 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output2 <- cal.plane1[c("event_id","longitude","latitude","Mw","depth","GCMT_Strike2","GCMT_Dip2","Fnm_2","Frv_2","lon","lat","filter.id")] 
write.table(output2,file="Fortran_plane2/2016_fy_in_plane2.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE)  # ,na="0"

################################################
# go to Fortran_plane1 and Fortran_plane2 Folder to run Fortran code
################################################
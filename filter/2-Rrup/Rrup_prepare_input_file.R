library(dplyr)
GDMS.record <- read.table(file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
GDMS.record_filtered <- GDMS.record %>% filter(!is.na(filter_id))
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/TSMIP_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
#
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
tmp = inner_join(x = GDMS.record_filtered, y = catalog, by = "event_id")
cal.plane1 = inner_join(x = tmp, y = stations, by = "station")

# cal.plane1 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output1 <- cal.plane1[c("event_id","longitude","latitude","Mw","depth","strike1","dip1","Fnm_1","Frv_1","lon","lat","filter_id")] 
write.table(output1,file="Fortran_plane1/fy_in_plane1.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE) 

# output for Fortran code (plane2)
# cal.plane2 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output2 <- cal.plane1[c("event_id","longitude","latitude","Mw","depth","strike2","dip2","Fnm_2","Frv_2","lon","lat","filter_id")] 
write.table(output2,file="Fortran_plane2/fy_in_plane2.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE)

################################################
# go to Fortran_plane1 and Fortran_plane2 Folder to run Fortran code
################################################

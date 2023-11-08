library(dplyr)
GDMS.record <- read.table(file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
GDMS.record_filtered <- GDMS.record %>% filter(!is.na(filter_id))
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/TSMIP_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
#
################################################################## 

#!?ˆ©?”¨ç¶“é?—å…¬å¼è?ˆç?—æ–·å±¤é¢ç©ã€é•·å¯¬æ?”ã€æ–·å±¤ç ´è£‚é¢?•·åº¦è?‡å¯¬åº?
#!=================================================================
#  !    è¨ˆç?—æ–·å±¤é¢ç©?                                                |
#  !    Wells and Coppersmith(1994):                                |
#  !    log(A)=-3.49+0.91*M     sigma(log(A))=0.24                  |
#  !    ??‡çŸ©è¦æ¨¡?©?”¨ç¯„å?ï??4.8~7.9                                   |
#  !=================================================================     
#  !    NGAè¨ˆç•«ä¸­è?ˆç?—æ–·å±¤ç ´è£‚é¢ä¹‹é•·å¯¬æ??                             |
#  !    log(AR)=(0.01752-0.00472*FN-0.01099*FR)*(M-4)**3.097        |
#  !=================================================================

# ä¾å?è?‰ç?„ç¢©å£«è?–æ?‡ï?ŒNGAä½¿ç”¨??„é¢ç©é•·å¯¬æ?? (AR,aspect ratio)
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

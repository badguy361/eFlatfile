## 2020/08/05 
################################################################## 
source(file = "hageodist.R")
# import records
rec_FM_Vs30 <- read.table(file="D:/Myanmar/filter/2-Rrup/sgm.2020_Frv_Fnm.rec_tmp.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
#
# check <- rec_FM_Vs30[,c(1:3,101:114)]
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
cal.plane1 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output1 <- cal.plane1[c("event_id","origins.longitude","origins.latitude","final_Mw","origins.depth","GCMT_Strike1","GCMT_Dip1","Fnm_1","Frv_1","sta_lon","sta_lat","filter.id")] 
write.table(output1,file="D:/Myanmar/filter/2-Rrup/Fortran_plane1/2020_fy_in_plane1.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE)  # ,na="0"

# output for Fortran code (plane2)
cal.plane2 <- rec_FM_Vs30
# cal.plane1 <- rec_FM_Vs30[which((!is.na(rec_FM_Vs30$FM_Index)) & (rec_FM_Vs30$Final_Mw>4.8)),]
output2 <- cal.plane2[c("event_id","origins.longitude","origins.latitude","final_Mw","origins.depth","GCMT_Strike2","GCMT_Dip2","Fnm_2","Frv_2","sta_lon","sta_lat","filter.id")] 
write.table(output2,file="D:/Myanmar/filter/2-Rrup/Fortran_plane2/2020_fy_in_plane2.txt",sep=" ",row.names = FALSE, col.names = FALSE, quote = FALSE)  # ,na="0"

################################################
# go to Fortran_plane1 and Fortran_plane2 Folder to run Fortran code
################################################

# Rrup
plane1 <- read.table(file="D:/Myanmar/filter/2-Rrup/Fortran_plane1/2020_fy_out_plane1.txt")
names(plane1) <- c("filter.id","Rrup_p1","Rrup.x1","Rrup.y1","Rrup.z1")
plane1.for.merge <- plane1[,c("filter.id","Rrup_p1")]
#
plane2 <- read.table(file="D:/Myanmar/filter/2-Rrup/Fortran_plane2/2020_fy_out_plane2.txt")
names(plane2) <- c("filter.id","Rrup_p2","Rrup.x2","Rrup.y2","Rrup.z2")
plane2.for.merge <- plane2[,c("filter.id","Rrup_p2")]
#
rec_FM_Vs30_2 <- merge(rec_FM_Vs30,plane1.for.merge,by=c("filter.id"),all.x=TRUE)
rec_FM_Vs30_2 <- merge(rec_FM_Vs30_2,plane2.for.merge,by=c("filter.id"),all.x=TRUE)
rec_FM_Vs30_2$Avg_Rrup <- (rec_FM_Vs30_2$Rrup_p1+rec_FM_Vs30_2$Rrup_p2)/2.
# check <- rec_FM_Vs30_2[,c(1:3,101:117)]


# Hypo (Mw <= 4.8)
Hori.R <- hageodist(rec_FM_Vs30_2$final.Lon,rec_FM_Vs30_2$final.Lat,rec_FM_Vs30_2$Lon.Sta.X,rec_FM_Vs30_2$Lat.Sta.Y)
rec_FM_Vs30_2$Hypo <- sqrt(Hori.R**2+rec_FM_Vs30_2$final.Dep**2)

# Adopted Rrup
rec_FM_Vs30_2$Adopted_Rrup <- rec_FM_Vs30_2$Hypo
rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Adopted_Rrup"] <- rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Avg_Rrup"]
check <- rec_FM_Vs30_2[,c(1:3,101:119)]


write.table(rec_FM_Vs30_2,file="D:/Myanmar/filter/2-Rrup/sgm.2020_Frv_Fnm.rec_tmp2.csv",sep=",",row.names = FALSE, col.names = TRUE)  # ,na="0"


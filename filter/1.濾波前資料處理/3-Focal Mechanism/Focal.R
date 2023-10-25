library(stringr)
#讀??? rec
rec <- read.table(file="C:/Users/user/Desktop/Central/internship/2-consolidating/1-Flatfile/sgm.2017.BH.rec.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# FM
EQID_FM <- read.table("C:/Users/user/Desktop/EQID+FM_202012.new.csv",sep=",",header=TRUE)
# EQID_FM <- read.table("C:/Users/user/Desktop/Central/internship/2-consolidating/2-merge rec with FM/EQID+FM_202012.csv",sep=",",header=TRUE)
#
merge1 <- merge(rec,EQID_FM,by=c("EQ_ID"),all.x = TRUE)
merge1$Mw_index <- as.character(merge1$Mw_index)
# merge1 <- unique(merge1[which(is.na(merge1$has_FM)),c("EQ_ID")]) # 89 EQ
# merge1.no.FM.rec <- unique(merge1[which(is.na(merge1$has_FM)),])             # 204 rec

#  Final Mw
for (i in 1:nrow(merge1)){
  if (is.na(merge1$Final_Mw[i])){
    merge1$final.Lon[i] <- merge1$Lon.X[i]
    merge1$final.Lat[i] <- merge1$Lat.Y[i]
    merge1$final.Dep[i] <- merge1$Depth[i]
    if(!is.na(merge1$Final_Mw[i]) & merge1$ML[i]>=5.5){ #ML change to Mw
      merge1$Tran_Mw[i] <- round(exp((merge1$ML[i]+3.131)/5.115),2)
      merge1$Final_Mw[i] <- round(exp((merge1$ML[i]+3.131)/5.115),2)
      merge1$Mw_index[i] <- "CWB"
    } 
    if(!is.na(merge1$Final_Mw[i]) & merge1$ML[i]<=6.0){ #ML change to Mw
      merge1$Tran_Mw[i] <- round((merge1$ML[i]-0.338)/0.961,2)
      merge1$Final_Mw[i] <- round((merge1$ML[i]-0.338)/0.961,2)
      merge1$Mw_index[i] <- "CWB"
    }
  }
}

# Final FM
merge1$Final_Strike_1 <- NA
merge1$Final_Dip_1 <- NA
merge1$Final_Slip_1 <- NA
merge1$Final_Strike_2 <- NA
merge1$Final_Dip_2 <- NA
merge1$Final_Slip_2 <- NA
merge1$FM_Index <- NA

# colnames(merge1)

for (i in 1:nrow(merge1)){
  if(!is.na(merge1$BATS.id[i])){
    merge1[i,c(84:89)] <- merge1[i,c(51:56)]
    merge1$FM_Index[i] <- "BATS"
  }
  if(!is.na(merge1$CMT.id[i])){
    merge1[i,c(84:89)] <- merge1[i,c(38:43)]
    merge1$FM_Index[i] <- "CMT"
  }
}
tmp <- merge1
# Fnm,Frv
for (i in 1:nrow(merge1)){
  if(is.na(merge1$Final_Slip_1[i])){
    merge1$Fnm_1[i] <- NA
    merge1$Frv_1[i] <- NA
    next
  }
  if ( abs(merge1$Final_Slip_1[i]-0)<=30 | abs(merge1$Final_Slip_1[i]-180)<=30 | abs(merge1$Final_Slip_1[i]+180)<=30 ){
    merge1$Fnm_1[i] <- 0
    merge1$Frv_1[i] <- 0
  } else if ( merge1$Final_Slip_1[i]>30 & merge1$Final_Slip_1[i]<150) {
    merge1$Fnm_1[i] <- 0
    merge1$Frv_1[i] <- 1
  } else {
    merge1$Fnm_1[i] <- 1
    merge1$Frv_1[i] <- 0
  }
}

# Fnm,Frv
merge1$Fnm_2 <- NA
merge1$Frv_2 <- NA

for (i in 1:nrow(merge1)){
  if(!is.na(merge1$Final_Slip_2[i])){
    if (abs(as.numeric(merge1$Final_Slip_2[i])-0) <= 30 | abs(as.numeric(merge1$Final_Slip_2[i])-180) <= 30 | abs(as.numeric(merge1$Final_Slip_2[i])+180) <= 30 ){
    merge1$Fnm_2[i] <- 0
    merge1$Frv_2[i] <- 0
  } else if ( merge1$Final_Slip_2[i]>30 & merge1$Final_Slip_2[i]<150) {
    merge1$Fnm_2[i] <- 0
    merge1$Frv_2[i] <- 1
  } else {
    merge1$Fnm_2[i] <- 1
    merge1$Frv_2[i] <- 0
  }
  }

  if(is.na(merge1$Final_Slip_2[i])){
    merge1$Fnm_2[i] <- NA
    merge1$Frv_2[i] <- NA
    next
  }
}

#
write.table(merge1,file="C:/Users/user/Desktop/Central/internship/2-consolidating/3-Focal Mechanism/rec+FM2017.csv",sep=",",col.names = TRUE,row.names = FALSE)

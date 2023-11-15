library(stringr)
result_TXT <- list.files("output_BSFL/TXT_output/")
dsheet <- read.csv("../../TSMIP_Dataset/GDMS_Record.csv", header = T)
dsheet <- dsheet[ ,-c(66:75)]
#TXT
TXT <- data.frame()
TXT_fi <- array()
tmp_TXT <- data.frame()
new_TXT <- strsplit(result_TXT,split = "_")
for(i in 1:length(result_TXT)){
  TXT_fi[i] <- paste0(new_TXT[[i]][1],"_",new_TXT[[i]][2],"_",new_TXT[[i]][3],"_",new_TXT[[i]][4],"_",new_TXT[[i]][5])
} # 去掉最後的RSP
for(i in 1:length(result_TXT)){
    # i = 8
  file_TXT <- paste0("output_BSFL/TXT_output/",result_TXT[i])
  tmp_TXT <- read.table(file_TXT,header = T,sep = ",")
  TXT <- rbind(TXT,tmp_TXT) #把一行一行的tmp_TXT整併成一個dataframe
}
colnames(TXT) <- c("filter_id","rec_id","STA_ID","dt","npts","file_id","Pfile","file_name","PGA_V","PGA_NS","PGA_EW","PGA_NS_EW","PGA_amean","PGV_V","PGV_NS","PGV_EW","PGV_NS_EW","PGV_amean","PGD_V","PGD_NS","PGD_EW","PGD_NS_EW","PGD_amean","HP_V","LP_V","HP_NS","LP_NS","HP_EW","LP_EW","author","Ia_Z","Ia_NS","Ia_EW","Ia_NS_EW","Ia_amean")

#period
result_RSP_1 <- list.files("output_BSFL/RSP_output/")
periodlab <- array()
sqrtlab <- array()
p <- read.table(paste0("output_BSFL/RSP_output/",result_RSP_1[1]),header = T,sep="")
DVA <- c("PSD","PSV","PSA")
component <- c("NS","EW","Z")
period <- matrix(nrow = 9,ncol = nrow(p))
sqrt_H <- matrix(nrow = 3,ncol = nrow(p))
for (i in 1:3){
  for(j in 1:3){
    pn <- (i-1)*3+j
    periodlab[pn] <- paste0(DVA[i],".",component[j],"_T")
  }
  sqrtlab[i] <- paste0(DVA[i],".sqrt_T")
}
for(i in 1:9){
    period[i,] <- paste0(periodlab[i],sprintf("%0.3f",p$PERIOD.SEC.) ,"S")
}
for (i in 1:3){
    sqrt_H[i,] <- paste0(sqrtlab[i],sprintf("%0.3f",p$PERIOD.SEC.) ,"S")
}


#RSP
result_RSP <- list.files("output_BSFL/RSP_output/")

station <- array()
RSP_fi <- array()
tmp_RSP <- data.frame()
RSP <- data.frame()
nr = 0
new_RSP <- strsplit(result_RSP,split = "_")
for(i in 1:length(result_RSP)){
  RSP_fi[i] <- paste0(new_RSP[[i]][1],"_",new_RSP[[i]][2],"_",new_RSP[[i]][3],"_",new_RSP[[i]][4],"_",new_RSP[[i]][5])
}
for(i in 1:length(result_TXT)){
  # i = 8 
  file_RSP <- paste0("output_BSFL/RSP_output/",TXT_fi[i],"_RSP.txt")
  nr <- nr +1
  station[nr] <- TXT_fi[i]
  tmp_RSP <- read.table(file_RSP,header = T,sep="")
  for (j in 2:10){
    tmp <- tmp_RSP[ ,j]
    nc <- 0
    for(k in 1:length(tmp)){
      nc <- (j-2)*length(tmp)+k
      RSP[nr,nc] <- tmp[k]
    }
    }
}
names(RSP) <- as.array(t(period)) #t(x) 行列對換

# merge TXT RSP
TXT_RSP <- cbind(TXT,RSP)
print(TXT_RSP)
final_result_tmp <- merge(dsheet,TXT_RSP,by = c("filter_id"),all.y = T)

sheet_rot <- read.csv("Tmp_save_file/Outputdata/myMergedData_summary.csv", header = T)
names(sheet_rot)[5:115] <- paste0(names(sheet_rot)[5:115],"_RotD50")
Result_tmp <- merge(final_result_tmp,sheet_rot,by="filter_id",all.x = T)
Result <- Result_tmp
Result[ ,1] <- Result_tmp[ ,2]
Result[ ,2] <- Result_tmp[ ,3]
Result[ ,3] <- Result_tmp[ ,1]
names(Result)[1:3] <- c("rec_id","EQ_ID","filter_id")


Result$filter_id <- paste0("B00",str_pad(c(1:nrow(Result)),3,"left","0"))
write.table(Result,"GDMS_Record.csv",col.names = T,row.names = F,sep = ",")


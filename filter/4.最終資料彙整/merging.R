library(stringr)
result_TXT <- list.files("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/TXT_2019/")
dsheet <- read.csv("C:/Users/user/Desktop/Central/internship/2-consolidating/5-Rrup/2019.rec_FM_Vs30_Rrup.csv", header = T)
# sss <- colnames(dsheet)
dsheet <- dsheet[ ,-c(66:75)]
#TXT
TXT <- data.frame()
TXT_fi <- array()
tmp_TXT <- data.frame()
new_TXT <- strsplit(result_TXT,split = "_")
for(i in 1:length(result_TXT)){
  TXT_fi[i] <- paste0(new_TXT[[i]][1],"_",new_TXT[[i]][2],"_",new_TXT[[i]][3],"_",new_TXT[[i]][4],"_",new_TXT[[i]][5])
}
for(i in 1:length(result_TXT)){
    # i = 8
  file_TXT <- paste0("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/TXT_2019/",result_TXT[i])
  tmp_TXT <- read.table(file_TXT,header = T,sep = ",")
  TXT <- rbind(TXT,tmp_TXT)
}
colnames(TXT) <- c("filter.id","rec.id","STA_ID","dt","npts","file_id","Pfile","file_name","PGA_V","PGA_NS","PGA_EW","PGV_V","PGV_NS","PGV_EW","PGD_V","PGD_NS","PGD_EW","HP_V","LP_V","HP_NS","LP_NS","HP_EW","LP_EW","author")
#
# TXT$HP_period_V <- 1./TXT$HP_V
# TXT$HP_period_NS <- 1./TXT$HP_NS
# TXT$HP_period_EW <- 1./TXT$HP_EW

# for(i in 1:nrow(TXT)){
#   TXT$min_period[i] <- min(TXT$HP_period_V[i],TXT$HP_period_NS[i],TXT$HP_period_EW[i])
# }

# TXT$min_hz <- 1./TXT$min_period
# TXT$PGA.sqrt <- sqrt(TXT$PGA_EW*TXT$PGA_NS)
# TXT$PGV.sqrt <- sqrt(TXT$PGV_EW*TXT$PGV_NS)
# TXT$PGD.sqrt <- sqrt(TXT$PGD_EW*TXT$PGD_NS)
# write.table(TXT,"C:/Users/user/Desktop/Central/internship/3-Filtering/check filtering result/TXT.csv",col.names = T,row.names = F,sep = ",")

#period
result_RSP_1 <- list.files("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/RSP_2019/")
periodlab <- array()
sqrtlab <- array()
p <- read.table(paste0("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/RSP_2019/",result_RSP_1[1]),header = T,sep="")
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
result_RSP <- list.files("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/RSP_2019/")

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
  file_RSP <- paste0("C:/Users/user/Desktop/Central/internship/3-Filtering/Filtering Result/RSP_2019/",TXT_fi[i],"_RSP.txt")
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
names(RSP) <- as.array(t(period))

#over the usable period
# for(i in 1:nrow(TXT)){
#   index = 0
#   for(j in 1:nrow(p)){
#     if(TXT$min_period[i] < p$PERIOD.SEC.[j]){
#       for(k in 1:nrow(period)){
#         index <- (k-1)*ncol(period)+j
#         RSP[i,index] <- NA
#       }
#     }else{
#       next}
#   }
# }
# 
# #geometric mean
# for(i in 1:3){
  i <- 3
  k <- i*3-2
  for(j in 1:ncol(sqrt_H)){
  a <- sqrt_H[i,j]
  b <- period[k,j]
  c <- period[k+1,j]
  RSP[,a] <- sqrt(RSP[ ,b]*RSP[ ,c])
  }
# }
# write.table(RSP,"C:/Users/user/Desktop/Central/internship/3-Filtering/check filtering result/RSP.csv",col.names = T,row.names = F,sep = ",")
  
  
#
TXT <- TXT[ ,c(-1,-3,-6,-7)]
TXT_RSP <- cbind(TXT,RSP)
# write.table(TXT_RSP,"C:/Users/user/Desktop/TXT_RSP.csv",col.names = T,row.names = F,sep = ",")
final_result_tmp <- merge(dsheet,TXT_RSP,by = c("rec.id"),all.y = T)
# final_result <- final_result_tmp
# final_result[ ,2] <- final_result_tmp[, 3]
# final_result[ ,3] <- final_result_tmp[, 2]
# write.table(final_result,"C:/Users/user/Desktop/2019_final_result.csv",col.names = T,row.names = F,sep = ",")

sheet_rot <- read.csv("C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Outputdata_gather_2019/myMergedData.summary.csv", header = T)
names(sheet_rot)[5:115] <- paste0(names(sheet_rot)[5:115],"_RotD50")
Result_tmp <- merge(final_result_tmp,sheet_rot,by="filter.id",all.x = T)
Result <- Result_tmp
Result[ ,1] <- Result_tmp[ ,2]
Result[ ,2] <- Result_tmp[ ,3]
Result[ ,3] <- Result_tmp[ ,1]
names(Result)[1:3] <- c("rec.id","EQ_ID","filter.id")
# write.table(Result,"C:/Users/user/Desktop/rec_txt_RSP_RCTC_2019.csv",col.names = T,row.names = F,sep = ",")


Result$filter.id <- paste0("B000",str_pad(c(1:nrow(Result)),3,"left","0"))
write.table(Result,"C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2019.csv",col.names = T,row.names = F,sep = ",")



# 
# ###Calulate used data and graphing
# dsheet <- read.csv("C:/Users/user/Desktop/2019_final_result_NA.csv", header = T)
# lab <- colnames(dsheet)
# lab_start <- as.numeric(grep(lab,pattern = "PSA.sqrt_T0.010S"))
# lab_end <- as.numeric(grep(lab,pattern = "PSA.sqrt_T10.000S"))
# lab_1 <- lab_end - lab_start + 1
# a <- array()
# j= 0
# 
# for(i in lab_start:lab_end){
#   b <- array()
#   j <- j+1
#   b <- which(!is.na(dsheet[ ,i]))
#   a[j] <- length(b)
# }
# 
# p_1 <- strsplit(lab[lab_start:lab_end],split = "_")
# p <- array()
# for(i in 1:lab_1){
#   # i = 3
#   p_2 <- gsub("T",replacement="0",p_1[[i]][2])
#   p_3 <- gsub("S",replacement="0",p_2)
#   p[i] <- as.numeric(p_3)
# }
# 
# 
# pic.name <- paste0("The data")
# pic <- paste("C:/Users/user/Desktop/export image/",pic.name,".png",sep="")
# png(pic,width=750,height=750)
# par(mar=c(6,9,5.3,3.7))
# barplot(a,names.arg = p,ylim=c(0.01,670),axes = F,cex.names = 2)
# mtext("The number of using data ",side=3,line=1.8,cex=5)
# mtext("Number of data",side=2,line=5.8,cex=3.5)
# mtext("Period (sec)",side=1,line=4.3,cex=3.5)
# legend("topright",ncol = 1,col = "black",legend = "2019 data",fill= "gray" ,cex=2.3,inset=c(0.01,0.01))
# x.at <- c(-10,150)
# y.at <- seq(0,1000,by = 50)
# axis(1,at=x.at,labels=F,tck=0,lwd=2.5,padj=0.3)
# # axis(1,at=x.at,labels=c(10^-5,0,0.032,0.046,0.07,0.11,0.17,0.26,0.36,0.48,0.75,1.2,1.9,3.0,4.2,6.5,10.0),cex.axis=1.8,lwd=2.5,padj=0.3)
# axis(2,at=y.at,labels=seq(0,1000,by = 50),cex.axis=2.7,lwd=2.5,las = 2)
# axis(3,at=x.at,labels=FALSE,tck=0,lwd=2.5)
# axis(4,at=y.at,labels=FALSE,tck=0,lwd=2.5)
# 
# dev.off()











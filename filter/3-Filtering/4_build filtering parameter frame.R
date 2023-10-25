#
rec <- read.table(file="filter.frame2.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
#
### load corner frequency and usable period
path1 <- "Filtering Result/TXT/"
count1 <- 0
data.txt <- data.frame(SGM_SN=NA)
data.txt[,c("SGM_SN","SGM_ID","STA_ID","dt","npts","file_id","Pfile","file_name","PGA_V","PGA_NS","PGA_EW","PGV_V","PGV_NS","PGV_EW","PGD_V","PGD_NS","PGD_EW","HP_V","LP_V","HP_NS","LP_NS","HP_EW","LP_EW","author")] <- rep(NA,nrow(data.txt))

for (i in 1:nrow(rec)){ # nrow(rec) 
  # i <- 1
  tmp <- rec[i,]
  filename  <- as.character(paste0(path1,tmp$rec.id,"_",tmp$filter.id,".txt"))
  
  if(!file.exists(paste(filename,sep=""))){
    count1 <- count1+1
    print(paste(count1,"skip,",tmp$rec.id))
    next
  }
  
  filter_list  <- read.table(filename,sep=",",header=TRUE)
  data.txt <- rbind(data.txt,filter_list)
}

data.txt2 <- data.txt[-c(1),]
names(data.txt2)[names(data.txt2) == "SGM_SN"] <- "filter.id"
names(data.txt2)[names(data.txt2) == "SGM_ID"] <- "rec.id"
write.table(data.txt2,file="Filtering Result/filter_txt.csv",sep=",",col.names = TRUE,row.names = FALSE)

# 
## RSP
path2 <- 'Filtering Result/RSP/'
count2 <- 0
data.RSP <- data.frame(SGM_SN=NA)
# data.RSP[,c("SGM_SN","T0.010S","T0.020S","T0.022S","T0.025S","T0.029S","T0.030S","T0.032S","T0.035S","T0.036S","T0.040S","T0.042S","T0.044S","T0.045S","T0.046S","T0.048S","T0.050S","T0.055S","T0.060S","T0.065S","T0.067S","T0.070S","T0.075S","T0.080S","T0.085S","T0.090S","T0.095S","T0.100S","T0.110S","T0.120S","T0.130S","T0.133S","T0.140S","T0.150S","T0.160S","T0.170S","T0.180S","T0.190S","T0.200S","T0.220S","T0.240S","T0.250S","T0.260S","T0.280S","T0.290S","T0.300S","T0.320S","T0.340S","T0.350S","T0.360S","T0.380S","T0.400S","T0.420S","T0.440S","T0.450S","T0.460S","T0.480S","T0.500S","T0.550S","T0.600S","T0.650S","T0.667S","T0.700S","T0.750S","T0.800S","T0.850S","T0.900S","T0.950S","T1.000S","T1.100S","T1.200S","T1.300S","T1.400S","T1.500S","T1.600S","T1.700S","T1.800S","T1.900S","T2.000S","T2.200S","T2.400S","T2.500S","T2.600S","T2.800S","T3.000S","T3.200S","T3.400S","T3.500S","T3.600S","T3.800S","T4.000S","T4.200S","T4.400S","T4.600S","T4.800S","T5.000S","T5.500S","T6.000S","T6.500S","T7.000S","T7.500S","T8.000S","T8.500S","T9.000S","T9.500S","T10.000S")] <- rep(NA,nrow(data.RSP))
tmp.RSP  <- read.table(paste0(path2,"/",rec$rec.id[1],"_RSP.txt"), skip=1, col.names=c("PERIOD(SEC)","PSD-NS","PSD-EW","PSD-Z","PSV-NS","PSV-EW","PSV-Z","PSA-NS","PSA-EW","PSA-Z","PSA-sqrt"))
TT <-  paste0("_T",formatC(tmp.RSP$PERIOD.SEC., digits = 3, format = "f"),"S")
data.RSP[,c(paste0("PSD-NS",TT),paste0("PSD-EW",TT),paste0("PSD-Z",TT),paste0("PSV-NS",TT),paste0("PSV-EW",TT),paste0("PSV-Z",TT),paste0("PSA-NS",TT),paste0("PSA-EW",TT),paste0("PSA-Z",TT),paste0("PSA-sqrt",TT))] <- rep(NA,nrow(data.RSP))
#
for (i in 1:nrow(rec)){
  # i <- 1
  print(i)
  tmp <- rec[i,]
  filename  <- as.character(paste0(tmp$rec.id,"_RSP.txt"))
  
  if(!file.exists(paste(path2,filename,sep=""))){
    count2 <- count2+1
    print(paste(count2,"skip"))
    next
  }
  tmp.RSP  <- read.table(paste0(path2,filename), skip=1, col.names=c("PERIOD(SEC)","PSD-NS","PSD-EW","PSD-Z","PSV-NS","PSV-EW","PSV-Z","PSA-NS","PSA-EW","PSA-Z","PSA-sqrt"))
  tmp.RSP2 <- cbind(tmp$filter.id,t(tmp.RSP[,2]),t(tmp.RSP[,3]),t(tmp.RSP[,4]),t(tmp.RSP[,5]),t(tmp.RSP[,6]),t(tmp.RSP[,7]),t(tmp.RSP[,8]),t(tmp.RSP[,9]),t(tmp.RSP[,10]),t(tmp.RSP[,11]))
  colnames(tmp.RSP2) <- colnames(data.RSP)
  data.RSP <- rbind(data.RSP,tmp.RSP2)
}
data.RSP2 <- data.RSP[-c(1),]
names(data.RSP2)[names(data.RSP) == "SGM_SN"] <- "filter.id"
write.table(data.RSP2,file="Filtering Result/data_RSP.csv",sep=",",col.names = TRUE,row.names = FALSE)




#-------------------------------------------------------
# DO PLOT ALL Processed SGM
# Export PNG FIGURES
# 繪製加速度、速度、位移歷時函數及傅氏譜
# Acceleration 、 Velocity and Displacement Time History Plotting Function
# PNG 格式輸出
#-------------------------------------------------------
  library(RMySQL)
  library(Cairo)
  source("SGM_Process/Function_Integrate2VD.r")    #積分函數
#取得全部資料的ID
#  con <- dbConnect(dbDriver("MySQL"), host="140.115.123.70", username="sgm_process_user", password="7AnW7vAwDZrp8Xam", dbname="process")
#  id.list <- dbGetQuery(con, "SELECT ID,SGM_SN,author FROM SGM_Data_processed")
#  dbDisconnect(con)  #解除資料庫連線

#開始一筆一筆輸出圖
# i <- 1
# i <- 2
# i <- 10
#for (i in 1:dim(id.list)[1]){
for (i in 11:dim(id.list)[1]) {
  Plot_All_processed(id.list$SGM_SN[i],id.list$ID[i])
  }


Plot_All_processed <- function(SGM_SN,ID){
#資料庫連線查詢
  #取得SGM資料
#  SGM_SN <- id.list$SGM_SN[i]
#  ID <- id.list$ID[i]
  #con <- dbConnect(dbDriver("MySQL"), host="140.115.123.70", username="sgm_process_user", password="7AnW7vAwDZrp8Xam", dbname="process")
  #data <- dbGetQuery(con, paste("SELECT DT,NP,V,H1,H2,author,P_time FROM SGM_Data_processed WHERE ID=",ID,sep=""))
  #dbDisconnect(con)  #解除資料庫連線
#取得SGM對應的ID資料
  con <- dbConnect(dbDriver("MySQL"), host="140.115.123.70", username="tngauser", password="nga5864", dbname="CWB")
  data.id <- dbGetQuery(con, paste("SELECT EVN_ID,STA_ID,EQ_ID FROM SGM_INDEX WHERE SGM_SN ='",SGM_SN,"'",sep=""))
  dbDisconnect(con)  #解除資料庫連線

#取得time history資料
  EQ_ID <- data.id$EQ_ID
  STA_ID <- data.id$STA_ID
  SGM_ID <- paste(gsub("_","",data.id$EQ_ID),".",data.id$STA_ID,sep="")
  a1 <- strsplit(data$V,",")[[1]]
  a2 <- strsplit(data$H1,",")[[1]]
  a3 <- strsplit(data$H2,",")[[1]]
  storage.mode(a1) <- "numeric"
  storage.mode(a2) <- "numeric"
  storage.mode(a3) <- "numeric"
  x <- seq(1:data$NP)*data$DT
  nfft <- 2^(floor(logb(data$NP,2))+1)
  nNyq <- nfft/2+1
  idf <- 1.0/(nfft*data$DT)
  freqs <- (seq(1:nNyq)-1)*idf
#產生time series
  accts1 <- ts(data=a1, deltat=data$DT, start=0.0)
  accts2 <- ts(data=a2, deltat=data$DT, start=0.0)
  accts3 <- ts(data=a3, deltat=data$DT, start=0.0)
#積分到速度
  velts1 <- integrate2V(accts1*978.88)
  velts2 <- integrate2V(accts2*978.88)
  velts3 <- integrate2V(accts3*978.88)
#積分到位移
  dists1 <- integrate2D(velts1)
  dists2 <- integrate2D(velts2)
  dists3 <- integrate2D(velts3)
#傅利葉轉換
  a1 <- c(a1, rep(0, nfft-data$NP))
  a2 <- c(a2, rep(0, nfft-data$NP))
  a3 <- c(a3, rep(0, nfft-data$NP))
#... Foward FFT
  a1f <- fft(a1)
  a2f <- fft(a2)
  a3f <- fft(a3)
  a1f.amp <- abs(a1f[1:nNyq])
  a2f.amp <- abs(a2f[1:nNyq])
  a3f.amp <- abs(a3f[1:nNyq])
#圖檔檔名
  path.ACC=paste("D:/SUB_processed/",data$author,"/01_ACC_PNG/",EQ_ID,"/",SGM_ID,".png",sep="")
  path.VEL=paste("D:/SUB_processed/",data$author,"/02_VEL_PNG/",EQ_ID,"/",SGM_ID,".png",sep="")
  path.DIS=paste("D:/SUB_processed/",data$author,"/03_DIS_PNG/",EQ_ID,"/",SGM_ID,".png",sep="")
  path.FS=paste("D:/SUB_processed/",data$author,"/04_FS_PNG/",EQ_ID,"/",SGM_ID,".png",sep="")
# 畫加速度
  CairoPNG(filename = path.ACC, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  layout(matrix(1:3,3,1))
	plot(accts1, type="n", ylab="Acceleration (g)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(accts1)
	title(paste("Acceleration Time History",SGM_SN,"Process by",data$author,"at",data$P_time))
	points(which.max(abs(accts1))*data$DT,accts1[which.max(abs(accts1))], pch=18, col=2, cex=2)
	text(0,max(accts1)*0.8,substr(paste("PGA=",max(abs(accts1))),1,12), pos=4)
	text(0,min(accts1)*0.8,"Vertical component", pos=4)
	plot(accts2, type="n", ylab="Acceleration (g)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(accts2)
	points(which.max(abs(accts2))*data$DT,accts2[which.max(abs(accts2))], pch=18, col=2, cex=2)
	text(0,max(accts2)*0.8,substr(paste("PGA=",max(abs(accts2))),1,12), pos=4)
	text(0,min(accts2)*0.8,"Horizontal component H1 (NS)", pos=4)
	plot(accts3, type="n", ylab="Acceleration (g)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(accts3)
	points(which.max(abs(accts3))*data$DT,accts3[which.max(abs(accts3))], pch=18, col=2, cex=2)
	text(0,max(accts3)*0.8,substr(paste("PGA=",max(abs(accts3))),1,12), pos=4)
	text(0,min(accts3)*0.8,"Horizontal component H2 (EW)", pos=4)
  dev.off()
#畫速度
  CairoPNG(filename = path.VEL, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  layout(matrix(1:3,3,1))
	plot(velts1, type="n", ylab="Velocity (cm/s)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(velts1)
	title(paste("Velocity Time History",SGM_SN,"Process by",data$author,"at",data$P_time))
	points(which.max(abs(velts1))*data$DT,velts1[which.max(abs(velts1))], pch=18, col=2, cex=2)
	text(0,max(velts1)*0.8,substr(paste("PGV=",max(abs(velts1))),1,12), pos=4)
	text(0,min(velts1)*0.8,"Vertical component", pos=4)
	plot(velts2, type="n", ylab="Velocity (cm/s)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(velts2)
	points(which.max(abs(velts2))*data$DT,velts2[which.max(abs(velts2))], pch=18, col=2, cex=2)
	text(0,max(velts2)*0.8,substr(paste("PGV=",max(abs(velts2))),1,12), pos=4)
	text(0,min(velts2)*0.8,"Horizontal component H1 (NS)", pos=4)
	plot(velts3, type="n", ylab="Velocity (cm/s)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(velts3)
	points(which.max(abs(velts3))*data$DT,velts3[which.max(abs(velts3))], pch=18, col=2, cex=2)
	text(0,max(velts3)*0.8,substr(paste("PGV=",max(abs(velts3))),1,12), pos=4)
	text(0,min(velts3)*0.8,"Horizontal component H2 (EW)", pos=4)
  dev.off()
#畫位移
  CairoPNG(filename = path.DIS, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  layout(matrix(1:3,3,1))
	plot(dists1, type="n", ylab="Displacement (cm)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(dists1)
	title(paste("Displacement Time History",SGM_SN,"Process by",data$author,"at",data$P_time))
	points(which.max(abs(dists1))*data$DT,dists1[which.max(abs(dists1))], pch=18, col=2, cex=2)
	text(0,max(dists1)*0.8,substr(paste("PGD=",max(abs(dists1))),1,12), pos=4)
	text(0,min(dists1)*0.8,"Vertical component", pos=4)
	plot(dists2, type="n", ylab="Displacement (cm)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(dists2)
	points(which.max(abs(dists2))*data$DT,dists2[which.max(abs(dists2))], pch=18, col=2, cex=2)
	text(0,max(dists2)*0.8,substr(paste("PGD=",max(abs(dists2))),1,12), pos=4)
	text(0,min(dists2)*0.8,"Horizontal component H1 (NS)", pos=4)
	plot(dists3, type="n", ylab="Displacement (cm)", xlab="time (sec)")
	abline(h=0, col=2)
	lines(dists3)
	points(which.max(abs(dists3))*data$DT,dists3[which.max(abs(dists3))], pch=18, col=2, cex=2)
	text(0,max(dists3)*0.8,substr(paste("PGD=",max(abs(dists3))),1,12), pos=4)
	text(0,min(dists3)*0.8,"Horizontal component H2 (EW)", pos=4)
  dev.off()
#畫傅氏譜
  CairoPNG(filename = path.FS, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  layout(matrix(1:4,2,2, byrow=TRUE))
	plot(c(0.01,100), range(a1f.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
  title(paste("Vertical Component"))
	lines(freqs[-1], a1f.amp[-1], type='l', lwd=2)
	axis(1, labels=F, tck=1, lty=2, at=array(outer(1:9, c(0.01,0.1,1,10,100))))
	axis(1, labels=F, tck=1, at=c(0.01,0.1,1,10,100), lwd=1)
	axis(2, labels=F, tck=1, lwd=1)
	plot(c(0.01,100), range(a2f.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
  title(paste("Horizontal Component H1 (NS)"))
	lines(freqs[-1], a2f.amp[-1], type='l', lwd=2)
	axis(1, labels=F, tck=1, lty=2, at=array(outer(1:9, c(0.01,0.1,1,10,100))))
	axis(1, labels=F, tck=1, at=c(0.01,0.1,1,10,100), lwd=1)
	axis(2, labels=F, tck=1, lwd=1)
	plot(c(0.01,100), range(a3f.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
  title(paste("Horizontal Component H2 (EW)"))
	lines(freqs[-1], a3f.amp[-1], type='l', lwd=2)
	axis(1, labels=F, tck=1, lty=2, at=array(outer(1:9, c(0.01,0.1,1,10,100))))
	axis(1, labels=F, tck=1, at=c(0.01,0.1,1,10,100), lwd=1)
	axis(2, labels=F, tck=1, lwd=1)
  plot.new()
  text(0.5,0.6,labels="Fourier Amplitude",cex=2)
  text(0.5,0.4,labels=EQ_ID,cex=2)
  text(0.5,0.2,labels=STA_ID,cex=2)
  dev.off()
}

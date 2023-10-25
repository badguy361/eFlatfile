#
filter.frame <- read.csv(file="filter.frame2.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)

### LOAD Library
###
library(DBI)
library(RMySQL)
library(RMySQL)
library(foreign)
library(digest)
library(Cairo)
library(stringr)
library(RCTC)  # New! for calculating RotD50、...
library(RSEIS) # New! for applying "rsspec.taper()"
###
### LOAD Functions
###
source("SGM_Process/Function_Integrate2VD.r")    #積分函數
source("SGM_Process/Function_Integrate_Ia.r")    #Ia計算
source("SGM_Process/Function_spectraw3.r")       #計算反應譜
source("SGM_Process/Function_Baseline.r")        #基線校正
source("SGM_Process/Function_Butterworth.r")     #Butterworth濾波函數
source("SGM_Process/Function_write_DB.r")        #寫入資料庫
source("SGM_Process/Function_write_File.r")      #寫入檔案
source("SGM_Process/Function_write_data.r")      #寫資料
#source("SGM_Process/Function_tcltk_mesgbox.r")  #選取資料品質視窗
#source("SGM_Process/Function_Process.r")        #主程式

# ProcessTH <- function(SGM_SN, author, Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2) {
  
  ## 
  ## Skip and Add are used only for estimating displacement baseline
  ## 
  ## 1. Phase 1 (Vol. 1; type == 1) data may need instrument correction
  ## 2. Need better error checking and handling in 'spectraw'
  ##
  ##
  
  # A. ?s?u???Ʈw???o SGM ?j?_???? info 
  
  #  con <- dbConnect(dbDriver("MySQL"), host=mysql.ip, username=mysql.username, password=mysql.password, dbname=mysql.dbname)
  #  data.info <- dbGetQuery(con, paste("SELECT * FROM  SGM_INDEX_NEW WHERE file_id = ",paste("'",file.id,"'",sep="")))
  #  dbDisconnect(con)  #?Ѱ????Ʈw?s?u
  # A.1 ???o?j?_???? time history 
  #rpage = url(data.info$url,'r')
  
  SGM_SN= "B000020"
  author="yang"
  Baseline=TRUE
  PreBaseline=FALSE
  Skip=0
  Add=20
  Taper=0
  nDC=2000
  tb=5
  te=5
  nPole=2.5

  data.info  <- filter.frame[filter.frame$filter.id==SGM_SN,]
  rpage <- as.character(paste0("../@ts data/BH_2018/",str_pad(data.info$Month,2, pad = "0"),"/",data.info$ts_name)) 
  accs  <- read.table(rpage, skip=1, col.names=c("time","Z","H1","H2"))
  
  dt <- accs$time[2]-accs$time[1]
  YEAR <- data.info$Year
  MON <- data.info$Month
  DAY <- data.info$Day
  HOUR <- data.info$Hour
  MINUTE <- data.info$Minute
  SEC <- data.info$Second
  SGM_ID <- data.info$rec.id
  EQ_ID <- data.info$EQ_ID
  STA_ID <- data.info$Sta
  Lon <- data.info$final.Lon
  Lat <- data.info$final.Lat
  Depth <- data.info$final.Dep
  Distance <- data.info$Adopted_Rrup
  Hypo <- data.info$Hypo
  ML <- data.info$ML
  # Instrument_type <- data.info$Instrument
  SGM_SN <- data.info$filter.id
  file_id <- data.info$Pfile
  Pfile <- data.info$Pfile
  # file_name <- data.info$File.name
  # file_path <- data.info$url
  rec.id <- data.info$rec.id
  
  HP_V <- data.info$HP_V
  LP_V <- 100
  HP_NS <- data.info$HP_NS
  LP_NS <- 100
  HP_EW <- data.info$HP_EW
  LP_EW <- 100 
  
  path1 <- paste("BS_plot/",sep="")
  
  # B. ?غc?U?��q time history
  acc.v <- accs$Z/978.88
  acc.h1 <- accs$H1/978.88
  acc.h2 <- accs$H2/978.88
  #  x <- seq(1:dim(acc)[1])*data$DT
  npts<-dim(accs)[1]
  start.time <- 0.0
  acc.1<- ts(acc.v, deltat=dt, start=start.time) # ts() :time series
  acc.2<- ts(acc.h1, deltat=dt, start=start.time)
  acc.3<- ts(acc.h2, deltat=dt, start=start.time)
  
  # Start looping 3 components
  # i <- 1 
  # for (i in 1:3){
  #20180929ADD    
    i=2

    if(i ==1) acc <-acc.1 else if(i == 2) acc <-acc.2 else acc <- acc.3
    text.comp <- ifelse( i==1, "Vertical", ifelse( i==2, "Horizontal NS", "Horizontal EW"))
    # C. Remove DC
    #     negative nDC means the mean of whole record; otherwise mean is
    #     taken as the average of the first nDC points
    #
    if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC])

    # D. ???u?ե?
    #  Add=2
    #  Skip=0
    #  tb=5
    #  te=5
    #  nPole=2
    #  Taper=0
    if (tb > 0) nb <- npts * tb / 100 else nb <- tb
    if (te > 0) ne <- npts * te / 100 else ne <- te
    if (Taper > 0) nTaper <- npts * Taper / 100 else nTaper <- Taper
    nSkip <- ceiling(Skip/dt)
    nAdd  <- ceiling(Add/dt)

    acc.bs  <- BslnAdj(acc, nTaper, nSkip, nAdd)

    #?n?? ???t??
    vel <- integrate2V(acc*978.88)
    vel.bs <- integrate2V(acc.bs*978.88)
    #?n?? ???첾
    dis <- integrate2D(vel)
    dis.bs <- integrate2D(vel.bs)

    # E. ø?? ?[?t?סB?t?סB?첾
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  windows(record = TRUE, width = 9, height = 9)
    windows(width = 9, height = 9)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    # lines(acc.bs, col=6)
    abline(h=0)
    title(paste(SGM_ID,"  Acceleration Time History    ",file_id,text.comp,"    Baseline Correction", sep=","))
    points(which.max(abs(acc))*dt,acc.bs[which.max(abs(acc))], pch=18, col=2, cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    # lines(vel.bs, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel))*dt,vel.bs[which.max(abs(vel))], pch=18, col=2, cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    # lines(dis.bs, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis))*dt,dis[which.max(abs(dis))], pch=18, col=2, cex=2)
    text(0,dis[which.max(abs(dis))]*0.5,substr(paste("PGD=",max(abs(dis))),1,12), pos=4)
    text(0,dis[which.max(abs(dis))]*0.5,paste(text.comp," component"), pos=4)

    path.1=paste(path1,SGM_SN,".AVD_bc.",text.comp,".png",sep="" )
    CairoPNG(filename = path.1, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    #windows(width = 9, height = 9)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    # lines(acc.bs, col=6)
    abline(h=0)
    title(paste(SGM_ID,"Acceleration Time History",file_id,text.comp, sep=",   ")) # ,"Baseline Correction"
    points(which.max(abs(acc))*dt,acc[which.max(abs(acc))], pch=18, col=2, cex=2)
#    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    text(0,max(acc)*0.5,substr(paste("PGA=",max(abs(acc))),1,12), pos=4)
    text(0,min(acc)*0.5,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    # lines(vel.bs, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel))*dt,vel[which.max(abs(vel))], pch=18, col=2, cex=2)
#    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    text(0,max(vel)*0.5,substr(paste("PGV=",max(abs(vel))),1,12), pos=4)
    text(0,min(vel)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    # lines(dis.bs, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis))*dt,dis[which.max(abs(dis))], pch=18, col=2, cex=2)
#    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    text(0,dis[which.max(abs(dis))]*0.5,substr(paste("PGD=",max(abs(dis))),1,12), pos=4)
    text(0,0.5,paste(text.comp," component"), pos=4)
    dev.off()
    
    
  #   if(i ==1) acc <-acc.1 else if(i == 2) acc <-acc.2 else acc <- acc.3
  #   text.comp <- ifelse( i==1, "Vertical", ifelse( i==2, "Horizontal NS", "Horizontal EW"))
  #   # C. Remove DC 
  #   #     negative nDC means the mean of whole record; otherwise mean is 
  #   #     taken as the average of the first nDC points
  #   #
  #   if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC])
  #   
  #   # D. ???u?ե?
  #   #  Add=2
  #   #  Skip=0
  #   #  tb=5
  #   #  te=5                                                    
  #   #  nPole=2
  #   #  Taper=0
  #   if (tb > 0) nb <- npts * tb / 100 else nb <- tb
  #   if (te > 0) ne <- npts * te / 100 else ne <- te		
  #   if (Taper > 0) nTaper <- npts * Taper / 100 else nTaper <- Taper
  #   nSkip <- ceiling(Skip/dt)
  #   nAdd  <- ceiling(Add/dt)
  #   acc.bs  <- BslnAdj(acc, nTaper, nSkip, nAdd)
  #   
  #   #?n?? ???t?? 
  #   vel <- integrate2V(acc*978.88)
  #   vel.bs <- integrate2V(acc.bs*978.88)
  #   #?n?? ???첾 
  #   dis <- integrate2D(vel)
  #   dis.bs <- integrate2D(vel.bs)
  #   
  #   # E. ø?? ?[?t?סB?t?סB?첾
  #   #  graphics.off()
  #   #  .SavedPlots <- NULL # Deletes any existing plot history
  #   #  windows(record = TRUE, width = 9, height = 9)
  #   windows(width = 9, height = 9)
  #   layout(matrix(1:3,3,1))
  #   #... 1. Acceleration time history
  #   plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
  #   lines(acc.bs, col=6)
  #   abline(h=0)
  #   title(paste(SGM_ID,"  Acceleration Time History    ",file_id,text.comp,"    Baseline Correction", sep=","))
  #   points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col=2, cex=2)
  #   text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
  #   text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
  #   #... 2. Velocity time history
  #   plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
  #   lines(vel.bs, col=6)
  #   abline(h=0)
  #   title("Velocity Time History")
  #   points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col=2, cex=2)
  #   text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
  #   text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
  #   #... 3. Displacement time history
  #   plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
  #   lines(dis.bs, col=6)
  #   abline(h=0)
  #   title("Displacement Time History")
  #   points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col=2, cex=2)
  #   text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
  #   text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
  #   
  #   path.1=paste(path2,"/",SGM_ID,".",SGM_SN,".AVD_bc.",text.comp,".png",sep="" )
  #   CairoPNG(filename = path.1, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  #   #windows(width = 9, height = 9)
  #   layout(matrix(1:3,3,1))
  #   #... 1. Acceleration time history
  #   plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
  #   lines(acc.bs, col=6)
  #   abline(h=0)
  #   title(paste(SGM_ID,"Acceleration Time History",file_id,text.comp,"Baseline Correction", sep=",   "))
  #   points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col=2, cex=2)
  #   text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
  #   text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
  #   #... 2. Velocity time history
  #   plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
  #   lines(vel.bs, col=6)
  #   abline(h=0)
  #   title("Velocity Time History")
  #   points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col=2, cex=2)
  #   text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
  #   text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
  #   #... 3. Displacement time history
  #   plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
  #   lines(dis.bs, col=6)
  #   abline(h=0)
  #   title("Displacement Time History")
  #   points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col=2, cex=2)
  #   text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
  #   text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
  #   dev.off()
  #   
  #   #  qc <- setqc()
  #   # F. ø?? ??��?? ?Ť??? 
  #   #... PSV (pseudo spectral velocit; tripartite plot would be better)
  #   rsp <- spectraw2(acc.bs, 0.05, 'psv') # spectraw2(acc.bs, damping, 'psv')
  #   #   print("OK")
  #   # set graphic for plotting
  #   #  graphics.off()
  #   #  .SavedPlots <- NULL # Deletes any existing plot history
  #   #  windows(record = TRUE, width = 15, height = 9)
  #   
  #   windows(width = 15, height = 9)
  #   layout(matrix(1:2,1,2))
  #   plot_spectra(rsp, "psv")
  #   
  #   #?ǳƭp??FFT?Ϊ??Ѽ? 
  #   nfft <- 2^(floor(logb(npts,2))+1) # logb(npts,2) = log2(npts)
  #   nNyq <- nfft/2+1
  #   idf <- 1.0/(nfft*dt)
  #   freqs <- (seq(1:nNyq)-1)*idf
  #   #?????צ???2?????? 
  #   acc.bs2 <- c(acc.bs, rep(0, nfft-npts))
  #   #... Foward FFT
  #   fs <- fft(acc.bs2)
  #   fs.amp <- abs(fs[1:nNyq])
  #   fs.amp_o <- abs(fs[1:nNyq])    # fs.amp[-1] : ??fs.amp?Ĥ@?ӼƦr????
  #   plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
  #   title(paste(text.comp," Component"))
  #   lines(freqs[-1], fs.amp[-1], type='l', lwd=2,col=6)
  #   abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
  #   abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
  #   
  #   #
  #   #... Locate corners of bandpass filter
  #   # ?????o?i?W?q
  #   # locator() : Reads the position of the graphics cursor when the (first) mouse button is pressed.
  #   #fc <- locator(n=2, type='p', pch=16, col=6)
  #   #fc <- sort(fc$x) # locator() ?|?^???I��??x??y?y??
  #   #fc <- c(data.info$Lowest_Usable_Freq_Ave,100) #?T?w?W?q?o?i
  #   
  #   # 2019.01.13: ?D??Period = 0.5 sec ~ 10 sec ?????Arsv?̧C?ȹ?��???g?��A?˼Ʊo???W?v
  #   fc <- c()
  #   HP.T <- rsp$Period[which(rsp$psv==min(rsp$psv[57:105]))]
  #   fc[1] <- 1/HP.T
  #   fc[2] <- 100
  #   print(fc)
  #   # if(i ==1) fc[1] <-0.35 else if(i == 2) fc[1] <-0.27 else fc[1] <- 0.16
  #   # if(i ==1) fc[2] <-60 else if(i == 2) fc[2] <-43 else fc[2] <- 55
  #   
  #   # ??SSHAC?I???o?i
  #   #fc[1] <- ifelse( i==1, data.info$Lowest_Usable_Freq_Ave , ifelse( i==2, data.info$Lowest_Usable_Freq_H1 , data.info$Lowest_Usable_Freq_H2))
  #   #fc[2] <- 100
  #   
  #   # Original code
  #   # if (length(fc) == 0) {
  #   #   fc[1] <- 0.05
  #   #   fc[2] <- 100   #?אּ100 
  #   # }
  #   # if (length(fc) == 1) {
  #   #   fc[1] <- signif(fc[1],2)
  #   #   #		fc[2] <- NA 
  #   #   fc[2] <- 100   #?אּ100
  #   # }
  #   # if (length(fc) == 2) {
  #   #   fc[1] <- signif(fc[1],2) # signif rounds the values in its first argument to the specified number of significant digits.
  #   #   fc[2] <- signif(fc[2],2)
  #   # }
  #   
  #   #	
  #   #... High-pass filter: causal Butterworth, with nPole poles
  #   #
  #   if (!is.na(fc[1])) {fs[1:nNyq] <- fs[1:nNyq] * hpassButterworth(nfft, dt, fc[1], nPole); NULL}
  #   
  #   #		
  #   #... Low-pass filter: causal Butterworth
  #   #
  #   if (!is.na(fc[2])) {fs[1:nNyq] <- fs[1:nNyq] * lpassButterworth(nfft, dt, fc[2], nPole); NULL}
  #   
  #   if(i ==1) HP_V <-fc[1] else if(i == 2) HP_NS <-fc[1] else HP_EW <-fc[1]
  #   if(i ==1) LP_V <-fc[2] else if(i == 2) LP_NS <-fc[2] else LP_EW <-fc[2]
  #   
  #   #	
  #   #... Plot filtered Fourier amplitude spectra
  #   #
  #   fs.amp <- abs(fs[1:nNyq])
  #   lines(freqs[-1], fs.amp[-1], col=2)
  #   abline(v=fc, col=6, lwd=2)
  #   
  #   path.4=paste(path2,"/",SGM_ID,".",SGM_SN,".FFT.",text.comp,".png",sep="")
  #   CairoPNG(filename = path.4, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  #   plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
  #   title(paste(SGM_ID," ",text.comp," Component"))
  #   lines(freqs[-1], fs.amp_o[-1], type='l', lwd=2,col=6)
  #   abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
  #   abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
  #   lines(freqs[-1], fs.amp[-1], col=2)
  #   abline(v=fc, col=6, lwd=2)
  #   dev.off()	
  #   
  #   #
  #   #... Prepare Fourier spectrum for inverse FFT
  #   #
  #   fs[1] <- complex(real=Re(fs[1]), imaginary=0)
  #   fs[nNyq] <- complex(real=Re(fs[nNyq]), imaginary=0)
  #   fs[nfft+2-(2:(nfft/2))] <- Conj(fs[2:(nfft/2)])
  #   
  #   #	
  #   #... Inverse FF 
  #   #
  #   acc.flt <- ts(data=Re(fft(fs, inverse=T))/nfft, deltat=dt, start=start.time)
  #   
  #   #
  #   #... Keep only the original length
  #   #  
  #   acc.flt <- ts(acc.flt[1:npts], deltat=dt, start=start.time)		
  #   
  #   #	
  #   #... Correct baseline drift after filtering	
  #   #
  #   if (Baseline) acc.flt <- BslnAdj(acc.flt, nTaper, nSkip, nAdd)
  #   vel.flt <- integrate2V(acc.flt*981)
  #   dis.flt <- integrate2D(vel.flt)
  #   
  #   #	
  #   #... Plot filtered and baseline-corrected time histories
  #   #
  #   windows(width = 9, height = 9)
  #   layout(matrix(1:3,3,1))
  #   #... 1. Acceleration time history 
  #   plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)")
  #   lines(acc.flt, col=6)
  #   abline(h=0)
  #   title(paste(SGM_ID,"  Acceleration Time History    ",file_id,text.comp,"    Filtering", sep=","))
  #   points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col=2, cex=2)
  #   text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
  #   text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
  #   #... 2. Velocity time history
  #   plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
  #   lines(vel.flt, col=6)
  #   abline(h=0)
  #   title("Velocity Time History")
  #   points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col=2, cex=2)
  #   text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
  #   text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
  #   #... 3. Displacement time history
  #   plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)")
  #   lines(dis.flt, col=6)
  #   abline(h=0)
  #   title("Displacement Time History")
  #   points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col=2, cex=2)
  #   text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
  #   text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
  #   
  #   path.2=paste(path2,"/",SGM_ID,".",SGM_SN,".AVD_fl.",text.comp,".png",sep="")
  #   CairoPNG(filename = path.2, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  #   layout(matrix(1:3,3,1))
  #   #... 1. Acceleration time history 
  #   plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)")
  #   lines(acc.flt, col=6)
  #   abline(h=0)
  #   title(paste(SGM_ID,"  Acceleration Time History    ",file_id,text.comp,"    Filtering", sep=","))
  #   points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col=2, cex=2)
  #   text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
  #   text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
  #   #... 2. Velocity time history
  #   plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
  #   lines(vel.flt, col=6)
  #   abline(h=0)
  #   title("Velocity Time History")
  #   points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col=2, cex=2)
  #   text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
  #   text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
  #   #... 3. Displacement time history
  #   plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)")
  #   lines(dis.flt, col=6)
  #   abline(h=0)
  #   title("Displacement Time History")
  #   points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col=2, cex=2)
  #   text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
  #   text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
  #   dev.off()
  #   
  #   
  #   #... Compute and plot response spectra
  #   rsp.flt <- spectraw2(acc.flt, 0.05, "psa")
  #   #	rsp <- spectraw2(acc.bs, 0.05, "psa")
  #   windows(width = 9, height = 9)
  #   plot_spectra(rsp.flt, "psv")
  #   lines(rsp$Period, rsp$psv, type='l', lwd=2, col=8)
  #   uband <- 1.0/fc/1.3
  #   mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
  #   mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
  #   mtext(paste("ID=",file_id," ",text.comp), line=3)
  #   if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
  #   if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)	
  #   
  #   ### psv
  #   path.3=paste(path2,"/",SGM_ID,".",SGM_SN,".rsp_psv.",text.comp,".png",sep="")
  #   CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  #   plot_spectra(rsp.flt, "psv")
  #   lines(rsp$Period, rsp$psv, type='l', lwd=6, col=8)
  #   uband <- 1.0/fc/1.3
  #   mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
  #   mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
  #   mtext(paste(SGM_ID,"  ID=",file_id," ",text.comp), line=3)
  #   if (!is.na(uband[1])) abline(v=uband[1], lwd=4, col=6)
  #   if (!is.na(uband[2])) abline(v=uband[2], lwd=4, col=6)
  #   abline(v=1/fc[1], lwd=4, col="blue")
  #   dev.off()
  #   
  #   ### psa
  #   path.3=paste(path2,"/",SGM_ID,".",SGM_SN,".rsp_psa.",text.comp,".png",sep="")
  #   CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  #   plot_spectra(rsp.flt, "psa")
  #   lines(rsp$Period, rsp$psa, type='l', lwd=2, col=8)
  #   uband <- 1.0/fc/1.3
  #   mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
  #   mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
  #   mtext(paste(SGM_ID,"  ID=",file_id," ",text.comp), line=3)
  #   if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
  #   if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)		
  #   abline(v=1/fc[1], lwd=2, col="blue")
  #   dev.off()
  #   
  #   if(i ==1) PGA_V <-max(abs(acc.flt)) else if(i == 2) PGA_NS <-max(abs(acc.flt)) else PGA_EW <-max(abs(acc.flt))
  #   if(i ==1) PGV_V <-max(abs(vel.flt)) else if(i == 2) PGV_NS <-max(abs(vel.flt)) else PGV_EW <-max(abs(vel.flt))
  #   if(i ==1) PGD_V <-max(abs(dis.flt)) else if(i == 2) PGD_NS <-max(abs(dis.flt)) else PGD_EW <-max(abs(dis.flt))
  #   #PGA <- max(abs(acc.flt))
  #   #PGV <- max(abs(vel.flt))
  #   #PGD <- max(abs(dis.flt))
  #   if(i ==1) rsp_V <- rsp.flt else if(i == 2) rsp_NS <-rsp.flt else rsp_EW <- rsp.flt
  #   
  #   #Write_to_DB(SGM_SN,SGM_ID,EQ_ID,EVN_ID,STA_ID,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author)
  #   acc.md5 <- digest(paste(acc.flt, collapse=","), serialize=FALSE) 
  #   #Write_to_DB(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author,acc.md5)
  #   #Write_to_DB_sort(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,author,acc.md5)
  #   
  #   if(i ==1) ACC.Z <-acc.flt else if(i == 2) ACC.NS <-acc.flt else ACC.EW <- acc.flt
  #   if(i ==1) VEL.Z <-vel.flt else if(i == 2) VEL.NS <-vel.flt else VEL.EW <- vel.flt
  #   if(i ==1) DIS.Z <-dis.flt else if(i == 2) DIS.NS <-dis.flt else DIS.EW <- dis.flt
  #   
  #   # compare with Yeh's corner frequency
  #   # tmp <- paste0(data.info$SGM_ID,"_",i)
  #   # Yeh_fc <- Yeh2016_all_sim[which(Yeh2016_all_sim$SGM_ID_N==tmp),"fc_1"]
  #   # if(abs(fc[1]-Yeh_fc)>0.2){
  #   #    question[cc,"SGM_ID_N"] <- tmp
  #   #    cc <- cc+1
  #   # }
  #   
  #   
#   }  #end of loop 3 component

  # xx<- data.frame(SGM_SN)
  # 
  # xx$SGM_ID<-SGM_ID
  # #xx$EVN_ID<-EVN_ID
  # xx$STA_ID<-STA_ID
  # xx$dt<-dt
  # xx$npts<-npts
  # #xx$time<-accs$time
  # xx$file_id    <-  file_id   
  # xx$Pfile      <-  Pfile     
  # xx$file_name  <-  file_name 
  # xx$HP_V <- HP_V  
  # xx$LP_V <- LP_V  
  # xx$HP_NS <-HP_NS 
  # xx$LP_NS <-LP_NS 
  # xx$HP_EW <-HP_EW 
  # xx$LP_EW <-LP_EW 
  # xx$author <- as.character(author)
  # xx
  
  #CHECK?s???o?i?W?q???r?ɦ??m?O?_?s?b
  # path9 <- paste("F:/2019?o?i_SSHAC?H?~/PROCESS_FILE_?ȩ?/TXT",sep="")
  # ifelse(file.exists(path9),paste("file exit!"),dir.create(path9))
  # 
  # path10<- paste(path9,"/",SGM_ID,"_",SGM_SN,".txt",sep="")
  # write.table(xx, file= path10,sep = ",",row.names = F)
  # 
  graphics.off()
  
  # copy from Function_Process_main_step2.R
  # psd.v <- rsp_V$sd
  # psd.ns <- rsp_NS$sd
  # psd.ew <- rsp_EW$sd
  # psa.v <- rsp_V$psa
  # psa.ns <- rsp_NS$psa
  # psa.ew <- rsp_EW$psa
  # psv.v <- rsp_V$psv
  # psv.ns <- rsp_NS$psv
  # psv.ew <- rsp_EW$psv
  # 
  # psa.sqrt <- sqrt(psa.ns*psa.ew)
  # 
  # period <- rsp_V$Period
  
  #### output psv, psa data
  # datat <- data.frame(t=period,h1=psd.ns,h2=psd.ew,h3=psd.v,h4=psv.ns,h5=psv.ew,h6=psv.v,h7=psa.ns,h8=psa.ew,h9=psa.v,h10=psa.sqrt)
  # datat.fmt <- c(" PERIOD(SEC)     PSD-NS         PSD-EW         PSD-Z         PSV-NS         PSV-EW         PSV-Z         PSA-NS         PSA-EW         PSA-Z         PSA-sqrt",
  #                sprintf("%10.3f%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E",datat$t,datat$h1,datat$h2,datat$h3,datat$h4,datat$h5,datat$h6,datat$h7,datat$h8,datat$h9,datat$h10))
  # write.table(datat.fmt,file=paste("F:/2019?o?i_SSHAC?H?~/RSP/",SGM_ID,"_RSP.txt",sep=""),row.names=FALSE,col.names=FALSE, quote=FALSE)
  # 
  
  # })]
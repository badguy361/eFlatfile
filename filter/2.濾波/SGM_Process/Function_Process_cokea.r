### Set Work directory
setwd('C:/Users/user/Desktop/meinon/')
### Set config parameters
#  source("SGM_Process/Function_config.r")
###
### LOAD Library
###
library(RMySQL)
library(foreign)
library(digest)
library(Cairo)
###
### LOAD Functions
###
source("SGM_Process/Function_Integrate2VD.r")    #ç©å?†å‡½?•¸
source("SGM_Process/Function_Integrate_Ia.r")    #Iaç©å?†å‡½?•¸
source("SGM_Process/Function_spectraw3a.r")       #è¨ˆç?—å?æ?‰è??
source("SGM_Process/Function_Baseline.r")        #?Ÿºç·šæ ¡æ­?
source("SGM_Process/Function_Butterworth.r")     #Butterworthæ¿¾æ³¢?‡½?•¸
source("SGM_Process/Function_write_DB.r")        #å¯«å…¥è³‡æ?™åº«
source("SGM_Process/Function_write_File.r")      #å¯«åˆ°æª”æ??
#	source("SGM_Process/Function_tcltk_mesgbox.r") #?¸??–è?‡æ?™å?è³ªè¦–ç??
source("SGM_Process/Function_Process.r")         #ä¸»ç?‹å??

###
#  source("SGM_Process/Function_plot_processed_SGM.r")    #å°æ–¼??•ç?†å?Œæ?ç?„è?‡æ?™ç¹ª???(å¾è?‡æ?™åº«)


data.all <- read.table("C:/Users/user/Desktop/meinon/Event20160206/filter_infommm.txt",header=T)

ProcessTH <- function(SGM_SN, author, Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2) {
  ## 
  ## Skip and Add are used only for estimating displacement baseline
  ## 
  ## 1. Phase 1 (Vol. 1; type == 1) data may need instrument correction
  ## 2. Need better error checking and handling in 'spectraw'
  ##
  ##
  
  # A. ³s½u¸ê®Æ®w¨ú±o SGM ±j¾_¸ê®Æ info 
  
  #  con <- dbConnect(dbDriver("MySQL"), host=mysql.ip, username=mysql.username, password=mysql.password, dbname=mysql.dbname)
  #  data.info <- dbGetQuery(con, paste("SELECT * FROM  SGM_INDEX_NEW WHERE file_id = ",paste("'",file.id,"'",sep="")))
  #  dbDisconnect(con)  #¸Ñ°£¸ê®Æ®w³s½u
  # A.1 ¨ú±o±j¾_¸ê®Æ time history 
  #rpage = url(data.info$url,'r')
  data.info  <- data.all[data.all$SGM_SN==SGM_SN,]
  rpage <- as.character(data.info$url) 
  accs  <- read.table(rpage, skip=11, col.names=c("time","UD","NS","EW"))
  
  dt <- accs$time[2]-accs$time[1]
  SGM_ID <- data.info$SGM_ID
  #EVN_ID <- data.info$EVN_ID
  EQ_ID <- data.info$EQ_ID
  STA_ID <- data.info$STA_ID
  file_id <- data.info$file_id
  pfile <- data.info$pfile
  file_name <- data.info$file_name
  file_path <- data.info$url
  HP_V <- 0
  LP_v <- 0
  HP_NS <- 0
  LP_EW <- 0
  HP_NS <- 0
  LP_EW <- 0 
  
  
  # B. «Øºc¦U¤À¶q time history
  acc.v <- accs$UD/978.88
  acc.h1 <- accs$NS/978.88
  acc.h2 <- accs$EW/978.88
  #  x <- seq(1:dim(acc)[1])*data$DT
  npts<-dim(accs)[1]
  start.time <- 0.0
  acc.1<- ts(acc.v, deltat=dt, start=start.time)
  acc.2<- ts(acc.h1, deltat=dt, start=start.time)
  acc.3<- ts(acc.h2, deltat=dt, start=start.time)
  
  # Start looping 3 components
  # i <- 1 
  for (i in 1:3){
    if(i ==1) acc <-acc.1 else if(i == 2) acc <-acc.2 else acc <- acc.3
    text.comp <- ifelse( i==1, "Vertical", ifelse( i==2, "Horizontal NS", "Horizontal EW"))
    # C. Remove DC 
    #     negative nDC means the mean of whole record; otherwise mean is 
    #     taken as the average of the first nDC points
    #
    if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC])
    
    # D. °ò½u®Õ¥¿
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
    
    #¿n¤À ¨ì³t«× 
    vel <- integrate2V(acc*978.88)
    vel.bs <- integrate2V(acc.bs*978.88)
    #¿n¤À ¨ì¦ì²¾ 
    dis <- integrate2D(vel)
    dis.bs <- integrate2D(vel.bs)
    
    # E. Ã¸¹Ï ¥[³t«×¡B³t«×¡B¦ì²¾
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  windows(record = TRUE, width = 9, height = 9)
    windows(width = 9, height = 9)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.bs, col=6)
    abline(h=0)
    title(paste("Acceleration Time History    ",file_id,text.comp,"    Baseline Correction", sep=","))
    points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col=2, cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.bs, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col=2, cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.bs, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col=2, cex=2)
    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
    
    
    path.1=paste("C:/Users/user/Desktop/meinon/",data.info$author,"/P-PNG_AVDa/",EQ_ID,"/",SGM_ID,".AVD_bc.",text.comp,".png",sep="")
    CairoPNG(filename = path.1, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    #windows(width = 9, height = 9)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.bs, col=6)
    abline(h=0)
    title(paste("Acceleration Time History    ",file_id,text.comp,"    Baseline Correction", sep=","))
    points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col=2, cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.bs, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col=2, cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.bs, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col=2, cex=2)
    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
    dev.off()
    #  qc <- setqc()
    # F. Ã¸¹Ï ¤ÏÀ³ÃĞ ³Å¤óÃĞ 
    #... PSV (pseudo spectral velocit; tripartite plot would be better)
    rsp <- spectraw2(acc.bs, 0.05, 'psv')
    #   print("OK")
    # set graphic for plotting
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  windows(record = TRUE, width = 15, height = 9)
    windows(width = 15, height = 9)
    layout(matrix(1:2,1,2))
    plot_spectra(rsp, "psv")
    
    #·Ç³Æ­pºâFFT¥Îªº°Ñ¼Æ 
    nfft <- 2^(floor(logb(npts,2))+1)
    nNyq <- nfft/2+1
    idf <- 1.0/(nfft*dt)
    freqs <- (seq(1:nNyq)-1)*idf
    #´êªø«×¦¨¬°2ªº¦¸¤è 
    acc.bs2 <- c(acc.bs, rep(0, nfft-npts))
    #... Foward FFT
    fs <- fft(acc.bs2)
    fs.amp <- abs(fs[1:nNyq])
    fs.amp_o <- abs(fs[1:nNyq])
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(text.comp," Component"))
    lines(freqs[-1], fs.amp[-1], type='l', lwd=2)
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
    
    #
    #... Locate corners of bandpass filter
    #
    fc <- locator(n=2, type='p', pch=16, col=6)
    fc <- sort(fc$x)
    
    if (length(fc) == 0) {
      fc[1] <- 0.05
      fc[2] <- 100   #§ï¬°100 
    }
    if (length(fc) == 1) {
      fc[1] <- signif(fc[1],2)
      #		fc[2] <- NA 
      fc[2] <- 100   #§ï¬°100
    }
    if (length(fc) == 2) {
      fc[1] <- signif(fc[1],2)
      fc[2] <- signif(fc[2],2)
    }
    
    #	
    #... High-pass filter: causal Butterworth, with nPole poles
    #
    if (!is.na(fc[1])) {fs[1:nNyq] <- fs[1:nNyq] * hpassButterworth(nfft, dt, fc[1], nPole); NULL}
    
    #		
    #... Low-pass filter: causal Butterworth
    #
    if (!is.na(fc[2])) {fs[1:nNyq] <- fs[1:nNyq] * lpassButterworth(nfft, dt, fc[2], nPole); NULL}
    
    if(i ==1) HP_V <-fc[1] else if(i == 2) HP_NS <-fc[1] else HP_EW <-fc[1]
    if(i ==1) LP_V <-fc[2] else if(i == 2) LP_NS <-fc[2] else LP_EW <-fc[2]
    
    #	
    #... Plot filtered Fourier amplitude spectra
    #
    fs.amp <- abs(fs[1:nNyq])
    lines(freqs[-1], fs.amp[-1], col=2)
    abline(v=fc, col=6, lwd=2)
    
    
    path.4=paste("C:/Users/user/Desktop/meinon/",data.info$author,"/P-PNG_AVDa/",EQ_ID,"/",SGM_ID,".FFT.",text.comp,".png",sep="")
    CairoPNG(filename = path.4, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(text.comp," Component"))
    lines(freqs[-1], fs.amp_o[-1], type='l', lwd=2)
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
    lines(freqs[-1], fs.amp[-1], col=2)
    abline(v=fc, col=6, lwd=2)
    dev.off()	
    
    
    #
    #... Prepare Fourier spectrum for inverse FFT
    #
    fs[1] <- complex(real=Re(fs[1]), imaginary=0)
    fs[nNyq] <- complex(real=Re(fs[nNyq]), imaginary=0)
    fs[nfft+2-(2:(nfft/2))] <- Conj(fs[2:(nfft/2)])
    
    #	
    #... Inverse FF 
    #
    acc.flt <- ts(data=Re(fft(fs, inverse=T))/nfft, deltat=dt, start=start.time)
    
    #
    #... Keep only the original length
    #  
    acc.flt <- ts(acc.flt[1:npts], deltat=dt, start=start.time)		
    
    #	
    #... Correct baseline drift after filtering	
    #
    if (Baseline) acc.flt <- BslnAdj(acc.flt, nTaper, nSkip, nAdd)
    vel.flt <- integrate2V(acc.flt*981)
    dis.flt <- integrate2D(vel.flt)
    
    #	
    #... Plot filtered and baseline-corrected time histories
    #
    windows(width = 9, height = 9)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history 
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.flt, col=6)
    abline(h=0)
    title(paste("Acceleration Time History    ",file_id,text.comp,"    Filtering", sep=","))
    points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col=2, cex=2)
    text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
    text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.flt, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col=2, cex=2)
    text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
    text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.flt, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col=2, cex=2)
    text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
    text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
    
    path.2=paste("C:/Users/user/Desktop/meinon/",data.info$author,"/P-PNG_AVDa/",EQ_ID,"/",SGM_ID,".AVD_fl.",text.comp,".png",sep="")
    CairoPNG(filename = path.2, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history 
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.flt, col=6)
    abline(h=0)
    title(paste("Acceleration Time History    ",file_id,text.comp,"    Filtering", sep=","))
    points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col=2, cex=2)
    text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
    text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.flt, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col=2, cex=2)
    text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
    text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.flt, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col=2, cex=2)
    text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
    text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
    dev.off()
    
    
    
    
    #... Compute and plot response spectra
    rsp.flt <- spectraw2(acc.flt, 0.05, "psa")
    #	rsp <- spectraw2(acc.bs, 0.05, "psa")
    windows(width = 9, height = 9)
    plot_spectra(rsp.flt, "psv")
    lines(rsp$Period, rsp$psv, type='l', lwd=2)
    uband <- 1.0/fc/1.3
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste("ID=",file_id," ",text.comp), line=3)
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)	
    
    path.3=paste("C:/Users/user/Desktop/meinon/",data.info$author,"/P-PNG_AVDa/",EQ_ID,"/",SGM_ID,".rsp.",text.comp,".png",sep="")
    CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    plot_spectra(rsp.flt, "psv")
    lines(rsp$Period, rsp$psv, type='l', lwd=2)
    uband <- 1.0/fc/1.3
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste("ID=",file_id," ",text.comp), line=3)
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)		
    dev.off()
    
    if(i ==1) PGA_V <-max(abs(acc.flt)) else if(i == 2) PGA_NS <-max(abs(acc.flt)) else PGA_EW <-max(abs(acc.flt))
    if(i ==1) PGV_V <-max(abs(vel.flt)) else if(i == 2) PGV_NS <-max(abs(vel.flt)) else PGV_EW <-max(abs(vel.flt))
    if(i ==1) PGD_V <-max(abs(dis.flt)) else if(i == 2) PGD_NS <-max(abs(dis.flt)) else PGD_EW <-max(abs(dis.flt))
    #PGA <- max(abs(acc.flt))
    #PGV <- max(abs(vel.flt))
    #PGD <- max(abs(dis.flt))
    if(i ==1) rsp_V <- rsp.flt else if(i == 2) rsp_NS <-rsp.flt else rsp_EW <- rsp.flt
    
    #Write_to_DB(SGM_SN,SGM_ID,EQ_ID,EVN_ID,STA_ID,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author)
    acc.md5 <- digest(paste(acc.flt, collapse=","), serialize=FALSE) 
    #Write_to_DB(file_id,pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author,acc.md5)
    #Write_to_DB_sort(file_id,pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,author,acc.md5)
    
    if(i ==1) ACC.Z <-acc.flt else if(i == 2) ACC.NS <-acc.flt else ACC.EW <- acc.flt
  }  #end of loop 3 component
  

  
}

i=8
ProcessTH(data.all$SGM_SN[i],author="coke")


# New! for calculating RotD50???...
library(devtools)
install_github('wltcwpf/RCTC')
library(RCTC) 
library(stringr)
library(Cairo)
library(digest)

source("SGM_Process/Function_Integrate2VD.r")    
source("SGM_Process/Function_Integrate_Ia.r")   
source("SGM_Process/Function_spectraw3.r")    
source("SGM_Process/Function_Baseline.r")     
source("SGM_Process/Function_Butterworth.r")    
source("SGM_Process/Function_ia_series.r")    

ProcessTH <- function(filter.ID, author, Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5) {
  
  # nPole=2.5

  data.info  <- filter.frame[filter.frame$filter_id==filter.ID,]
  rpage <- as.character(paste0("../../TSMIP_Dataset/picking_result/09",str_pad(data.info$Month,2, pad = "0"),"/",paste0(data.info$file_name,".asc"))) 
  accs  <- read.table(rpage, skip=1, col.names=c("time","Z","H1","H2")) ###check skip = ?
  
  dt <- accs$time[2]-accs$time[1]
  
  # period.dat <- scan("R_BSFL/period.dat", skip=1)
  # period.dat <- sort(period.dat)
  periods <- c(0.010,0.020,0.022,0.025,0.029,0.030,0.032,0.035,0.036,0.040,0.042,0.044,0.045,0.046,
               0.048,0.050,0.055,0.060,0.065,0.067,0.070,0.075,0.080,0.085,0.090,0.095,0.100,0.110,
               0.120,0.130,0.133,0.140,0.150,0.160,0.170,0.180,0.190,0.200,0.220,0.240,0.250,0.260,
               0.280,0.290,0.300,0.320,0.340,0.350,0.360,0.380,0.400,0.420,0.440,0.450,0.460,0.480,
               0.500,0.550,0.600,0.650,0.667,0.700,0.750,0.800,0.850,0.900,0.950,1.000,1.100,1.200,
               1.300,1.400,1.500,1.600,1.700,1.800,1.900,2.000,2.200,2.400,2.500,2.600,2.800,3.000,
               3.200,3.400,3.500,3.600,3.800,4.000,4.200,4.400,4.600,4.800,5.000,5.500,6.000,6.500,
               7.000,7.500,8.000,8.500,9.000,9.500,10.00)
  
  YEAR <- data.info$year
  MON <- data.info$month
  DAY <- data.info$day
  HOUR <- data.info$hour
  MINUTE <- data.info$minute
  SEC <- data.info$second 
  rec.id <- sprintf("%04d_%02d%02d_%02d%02d_%02d_%03s", 
                          data.info$year, 
                          data.info$month, 
                          data.info$day, 
                          data.info$hour, 
                          data.info$minute, 
                          data.info$second,
                          data.info$station) #2017_0101_0321_57_EDH
  EQ_ID <- sprintf("%04d_%02d%02d_%02d%02d_%02d", 
                          data.info$year, 
                          data.info$month, 
                          data.info$day, 
                          data.info$hour, 
                          data.info$minute, 
                          data.info$second) #2017_0101_0321_57
  STA_ID <- data.info$station #EDH
  Distance <- round(data.info$Adopted_Rrup,1)
  
  ML <- data.info$ML
  Mw <- data.info$Mw
  filter.ID <- data.info$filter_id
  
  Pfile <- paste0(data.info$file_name,".asc")
  file_name <- data.info$file_name
  file_id <- file_name
  
  HP_V <- 0
  LP_V <- 0
  HP_NS <- 0
  LP_NS <- 0
  HP_EW <- 0
  LP_EW <- 0 
  
  ifelse(file.exists("output_BSFL/PROCESS_FILE_tmp"),paste("file exit!"),dir.create("output_BSFL/PROCESS_FILE_tmp"))
  path1 <- paste("output_BSFL/PROCESS_FILE_tmp/",YEAR,sep="")
  ifelse(file.exists(path1),paste("file exit!"),dir.create(path1))
  path2 <- paste("output_BSFL/PROCESS_FILE_tmp/",YEAR,"/",EQ_ID,sep="")
  ifelse(file.exists(path2),paste("file exit!"),dir.create(path2))
  
  
  # B. å»ºæ?‹å?„å?†é?? time history
  acc.v <- accs$Z/978.88
  acc.h1 <- accs$H1/978.88
  acc.h2 <- accs$H2/978.88
  #  x <- seq(1:dim(acc)[1])*data$DT
  npts<-dim(accs)[1]
  start.time <- 0.0
  acc.1<- ts(acc.v, deltat=dt, start=start.time) # ts() :time series
  acc.2<- ts(acc.h1, deltat=dt, start=start.time)
  acc.3<- ts(acc.h2, deltat=dt, start=start.time)
  
  # ADDDDDDDDDDDDDDDDDDDD 
  # acc.2   # NS
  # acc.3   # EW
  # acc.2.tmp <- acc.2 - mean(acc.2[1:nDC])
  # acc.3.tmp <- acc.3 - mean(acc.3[1:nDC])
  # if (Taper > 0) nTaper <- npts * Taper / 100 else nTaper <- Taper
  # nSkip <- ceiling(Skip/dt)
  # nAdd  <- ceiling(Add/dt)
  # acc.bs.2.tmp  <- BslnAdj(acc.2.tmp, nTaper, nSkip, nAdd)
  # acc.bs.3.tmp  <- BslnAdj(acc.3.tmp, nTaper, nSkip, nAdd)
  # rsp.2.tmp <- spectraw2(acc.bs.2.tmp, 0.05, 'psv') # NS
  # rsp.3.tmp <- spectraw2(acc.bs.3.tmp, 0.05, 'psv') # EW
  
  
  ########################
  
  # Start looping 3 components
  # i <- 1
  for (i in 1:3){
    
    # i=1
    
    if(i ==1) acc <-acc.1 else if(i == 2) acc <-acc.2 else acc <- acc.3
    text.comp <- ifelse( i==1, "Vertical", ifelse( i==2, "Horizontal NS", "Horizontal EW"))
    # C. Remove DC 
    #     negative nDC means the mean of whole record; otherwise mean is 
    #     taken as the average of the first nDC points
    #
    if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC])
    
    # D. ?Ÿºç·šæ ¡æ­?
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
    
    #ç©�å?? ?ˆ°?€Ÿåº¦ 
    vel <- integrate2V(acc*978.88)
    vel.bs <- integrate2V(acc.bs*978.88)
    #ç©�å?? ?ˆ°ä½�ç§» 
    dis <- integrate2D(vel)
    dis.bs <- integrate2D(vel.bs)
    
    # E. ç¹ªå?? ?? é€Ÿåº¦?€�é€Ÿåº¦?€�ä?�ç§»
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  X11(record = TRUE, width = 9, height = 9)
    X11(width = 6, height = 6)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.bs, col="black")
    abline(h=0)
    title(paste(EQ_ID,STA_ID,"Acceleration Time History",file_id,text.comp,"Baseline Correction", sep=",   "))
    points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col="orange", cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.bs, col="black")
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col="orange", cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.bs, col="black")
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col="orange", cex=2)
    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
    legend("topleft",c("Before","After"),lty=1,col = c("black","red"),cex = 1.5)
    ################
    path.1=paste(path2,"/",rec.id,".",filter.ID,".AVD_bc.",text.comp,".png",sep="" )
    CairoPNG(filename = path.1, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    # X11(width = 9, height = 9) 
    layout(matrix(1:4,4,1), heights=c(1.5,4,4,4))
    text1 <-paste(EQ_ID,STA_ID,file_name,"Baseline Correction",text.comp, sep=",   ")
    text2 <-paste(paste0("Mw = ",data.info$Mw),paste0("Distance = ",Distance," (km)"), paste0("Vs30 = ",round(0,0)," (m/s)"), sep=",   ")
    par(mar = c(0,0,0,0))
    plot(0,0, ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
    text(x = 0.1, y = 0, text1, cex = 1.7, col = "black",font=2)
    text(x = 0.1, y = -0.8, text2, cex = 1.5, col = "blue",font=1)
    #... 1. Acceleration time history
    par(mar = c(4,4,4,0.5)) 
    plot(acc, type="l" , ylab="Acceleration (g)", xlab="time (sec)",main=NULL) # , ylab="Acceleration (g)", xlab="time (sec)"
    lines(acc.bs, col="red")
    abline(h=0)
    title(paste0("Acceleration Time History"))
    points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col="orange", cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    legend("bottomleft",c("Before","After"),lty=1,lwd=2,col = c("black","red"))
    #legend("topright",c("Before","After"),lty=1,col = c("black","red"))
    # text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)",ylim=c(min(vel,vel.bs),max(vel,vel.bs)))
    lines(vel.bs, col="red")
    abline(h=0)
    title(paste0("Velocity Time History"))
    points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col="orange", cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    # text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)",ylim=c(min(dis,dis.bs),max(dis,dis.bs)))
    lines(dis.bs, col="red")
    abline(h=0)
    title(paste0("Displacement Time History"))
    points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col="orange", cex=2)
    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    legend("topleft",c("Before","After"),lty=1,col = c("black","red"),cex = 1.5)
    # text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
    graphics.off()
    
    ###########################
    #  qc <- setqc()
    # F. ç¹ªå?? ??�æ?‰è?? ??…æ?�è?? 
    #... PSV (pseudo spectral velocit; tripartite plot would be better)
    # rsp <- spectraw2(acc.bs, 0.05, 'psv') # spectraw2(acc.bs, damping, 'psv')
    psa <- PS_cal_cpp(acc.bs,periods,0.05,dt,type_return = 1)[2,]
    psv <- PS_cal_cpp(acc.bs,periods,0.05,dt,type_return = 1)[3,] 
    rsp <- data.frame(Period=periods,psa=psa,psv=psv)
    
    
    # X11(width = 15, height = 9)
    X11(width = 10, height = 6)
    layout(matrix(1:2,1,2))
    plot_spectra(rsp, "psv")
    # if(i == 2) lines(rsp.3.tmp$Period,rsp.3.tmp$psv,col="gray",lwd=2) 
    # if(i == 3) lines(rsp.2.tmp$Period,rsp.2.tmp$psv,col="gray",lwd=2)
    ## new part (2020.03.26)
    # if(i ==2) lines(rsp_EW$Period, rsp_EW$psv, lwd=2,col="gray80") else if(i == 3) lines(rsp_NS$Period, rsp_NS$psv, lwd=2,col="gray80")
    title(main = paste("Mw =",Mw,", Distance =",Distance,"km",sep=" "))
    
    # filtering
    fc <- c()
    tmp <- locator(n=1, type='p', pch=16, col=6)
    fc[1] <- 1./tmp$x[1]
    # if(i ==1) fc[1] <-data.info$HP_Z else if(i == 2) fc[1] <-data.info$HP_H1 else fc[1] <- data.info$HP_H2
    print(fc[1])
    if(!is.na(fc[1])){if(fc[1]<0) fc[1]<-NA}
    fc[2] <- 100
    # print(c(fc[1]))
    # print(c(fc[2]))
    
    #æº–å?™è?ˆç?—FFT?”¨??„å?ƒæ•¸ 
    nfft <- 2^(floor(logb(npts,2))+1) # logb(npts,2) = log2(npts)
    nNyq <- nfft/2+1
    idf <- 1.0/(nfft*dt)
    freqs <- (seq(1:nNyq)-1)*idf
    #æ¹Šé•·åº¦æ?�ç‚º2??„æ¬¡?–¹ 
    acc.bs2 <- c(acc.bs, rep(0, nfft-npts))
    #... Foward FFT
    fs <- fft(acc.bs2)
    fs.amp <- abs(fs[1:nNyq])
    fs.amp_o <- abs(fs[1:nNyq])    # fs.amp[-1] : ??Šfs.ampç¬¬ä?€?€‹æ•¸å­—æ‹¿???
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(text.comp," Component"))
    lines(freqs[-1], fs.amp[-1], type='l', lwd=2,col=6)
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
    
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
    
    path.4=paste(path2,"/",rec.id,".",filter.ID,".FFT.",text.comp,".png",sep="")
    CairoPNG(filename = path.4, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(EQ_ID,STA_ID,paste(text.comp,"Component"), sep=",   "),line = 2.2)
    title(text2,line = 0.8)
    lines(freqs[-1], fs.amp_o[-1], type='l', lwd=2,col="black")
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col="grey90", lty=2)
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col="grey90", lty=2)
    lines(freqs[-1], fs.amp[-1], col="red")
    abline(v=fc, col="blue",lty=2, lwd=2)
    legend("topright",c("Before","After"),lty=1,col = c("black","red"),bg="white")
    graphics.off()	
    
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
    X11(width = 6, height = 6)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)")
    lines(acc.flt, col="black")
    abline(h=0)
    title(paste(EQ_ID ,STA_ID,"Acceleration Time History",file_id,text.comp,"Filtering", sep=",   "))
    points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col="orange", cex=2)
    text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
    text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
    #legend("topright",c("Before","After"),lty=1,col = c("black","red"))
    #... 2. Velocity time history
    plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)")
    lines(vel.flt, col="black")
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col="orange", cex=2)
    text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
    text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)")
    lines(dis.flt, col="black")
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col="orange", cex=2)
    text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
    text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
    legend("topleft",c("Before","After"),lty=1,col = c("black","red"),cex = 1.5)
    path.2=paste(path2,"/",rec.id,".",filter.ID,".AVD_fl.",text.comp,".png",sep="")
    CairoPNG(filename = path.2, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    layout(matrix(1:4,4,1), heights=c(1.5,4,4,4))
    par(mar = c(0,0,0,0))
    plot(0,0, ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
    text1 <-paste(EQ_ID,STA_ID,file_name,"Filtered",text.comp, sep=",   ")
    text(x = 0.1, y = 0, text1, cex = 1.7, col = "black",font=2)
    text(x = 0.1, y = -0.8, text2, cex = 1.5, col = "blue",font=1)
    #... 1. Acceleration time history 
    par(mar = c(4,4,4,0.5)) 
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)",main=NULL)
    lines(acc.flt, col="red")
    abline(h=0)
    title("Acceleration Time History")
    points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col="orange", cex=2)
    text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
    #legend("topright",c("Before","After"),lty=1,col = c("black","red"))
    # text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)",ylim=c(min(vel.bs,vel.flt),max(vel.bs,vel.flt)))
    lines(vel.flt, col="red")
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col="orange", cex=2)
    text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
    # text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)",ylim=c(min(dis.bs,dis.flt),max(dis.bs,dis.flt)))
    lines(dis.flt, col="red")
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col="orange", cex=2)
    text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
    legend("topleft",c("Before","After"),lty=1,col = c("black","red"),cex = 1.5)
    # text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
    graphics.off()
    
    
    #... Compute and plot response spectra
    # rsp.flt <- spectraw2(acc.flt, 0.05, "psa")
    psa <- PS_cal_cpp(acc.flt,periods,0.05,dt,type_return = 1)[2,]
    psv <- PS_cal_cpp(acc.flt,periods,0.05,dt,type_return = 1)[3,] 
    rsp.flt <- data.frame(Period=periods,psa=psa,psv=psv)
    # rsp <- spectraw2(acc.bs, 0.05, "psa")
    X11(width = 6, height = 6)
    plot_spectra(rsp.flt, "psv")
    lines(rsp$Period, rsp$psv, type='l', lwd=2, col="orange")
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste("ID=",file_id," ",text.comp), line=3)
    abline(v=1/fc[1], lwd=2, col="blue")
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col="grey90")
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col="grey90")
    
    ### psv
    path.3=paste(path2,"/",rec.id,".",filter.ID,".rsp_psv.",text.comp,".png",sep="")
    CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white") # ,  res = 100
    plot_spectra(rsp, "psv")
    lines(rsp.flt$Period, rsp.flt$psv, type='l', lwd=2, col="red")
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste(EQ_ID,"_",STA_ID,"  ID=",file_id," ",text.comp), line=3)
    text3 <- c(paste0("Mw = ",data.info$Mw),
               paste0("Distance = ",Distance," (km)"),
               paste0("Vs30 = ",round(0,0)," (m/s)"))
    
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col="blue",lty=2)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col="blue",lty=2)
    abline(v=1/fc[1], lwd=2, col="blue",lty=2)
    legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
           y.intersp=1.2)
    legend("topright",c("Before","After"),lty=1,col = c("black","red"))
    graphics.off()
    
    ### psa
    path.3=paste(path2,"/",rec.id,".",filter.ID,".rsp_psa.",text.comp,".png",sep="")
    CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    plot_spectra(rsp, "psa")
    lines(rsp.flt$Period, rsp.flt$psa, type='l', lwd=2, col="red")
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste(rec.id,"  ID=",file_id," ",text.comp), line=3)
    legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
           y.intersp=1.2)
    legend("topright",c("Before","After"),lty=1,col = c("black","red"))
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col="blue",lty=2)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col="blue",lty=2)		
    abline(v=1/fc[1], lwd=2, col="blue",lty=2)
    graphics.off()
    
    if(i ==1) PGA_V <-max(abs(acc.flt)) else if(i == 2) PGA_NS <-max(abs(acc.flt)) else PGA_EW <-max(abs(acc.flt))
    if(i ==1) PGV_V <-max(abs(vel.flt)) else if(i == 2) PGV_NS <-max(abs(vel.flt)) else PGV_EW <-max(abs(vel.flt))
    if(i ==1) PGD_V <-max(abs(dis.flt)) else if(i == 2) PGD_NS <-max(abs(dis.flt)) else PGD_EW <-max(abs(dis.flt))
    
    if(i ==1) rsp_V <- rsp.flt else if(i == 2) rsp_NS <-rsp.flt else rsp_EW <- rsp.flt
    
    #Write_to_DB(filter.ID,rec.id,EQ_ID,EVN_ID,STA_ID,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author)
    acc.md5 <- digest(paste(acc.flt, collapse=","), serialize=FALSE) 
    #Write_to_DB(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author,acc.md5)
    #Write_to_DB_sort(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,author,acc.md5)
    
    if(i ==1) ACC.Z <-acc.flt else if(i == 2) ACC.NS <-acc.flt else ACC.EW <- acc.flt
    if(i ==1) VEL.Z <-vel.flt else if(i == 2) VEL.NS <-vel.flt else VEL.EW <- vel.flt
    if(i ==1) DIS.Z <-dis.flt else if(i == 2) DIS.NS <-dis.flt else DIS.EW <- dis.flt
    
    if(i ==1) Ia1_Z <- Ia(ACC.Z) else if(i == 2) Ia1_NS <- Ia(ACC.NS) else Ia1_EW <- Ia(ACC.EW)
    
    
    if(i ==1) Ia2_Z <- integrateAI(ACC.Z) else if(i == 2) Ia2_NS <- integrateAI(ACC.NS) else Ia2_EW <- integrateAI(ACC.EW)
    
    
    # ### for running RCTC 
    if(i ==2){
      NS <- c(dt,acc.flt)
      write.table(NS,file=paste0("Tmp_save_file/NS.txt"),col.names = FALSE,row.names = FALSE)
    } else if (i==3) {
      EW <- c(dt,acc.flt)
      write.table(EW,file=paste0("Tmp_save_file/EW.txt"),col.names = FALSE,row.names = FALSE)
    }
    nametransfer(filedir1 = paste0("Tmp_save_file/NS.txt"), filedir2 =paste0("Tmp_save_file/EW.txt"), stationname = filter.ID , sn = rec.id,
                 outputdir = 'Tmp_save_file/Inputdata')
    
  }  #end of loop 3 component
  
  xx<- data.frame(filter.ID)
  
  xx$rec.id<-rec.id
  #xx$EVN_ID<-EVN_ID
  xx$STA_ID<-STA_ID
  xx$dt<-dt
  xx$npts<-npts
  #xx$time<-accs$time
  xx$file_id    <-  file_id   
  xx$Pfile      <-  Pfile     
  xx$file_name  <-  file_name
  xx$PGA_V <- round(PGA_V,6)
  xx$PGA_NS <- round(PGA_NS,6)
  xx$PGA_EW <- round(PGA_EW,6)
  xx$PGA_NS_EW <- (PGA_NS*PGA_EW)**0.5
  xx$PGA_amean <- (PGA_NS+PGA_EW)/2
  
  xx$PGV_V <- round(PGV_V,6)
  xx$PGV_NS <- round(PGV_NS,6)
  xx$PGV_EW <- round(PGV_EW,6)
  xx$PGV_NS_EW <- (PGV_NS*PGV_EW)**0.5
  xx$PGV_amean <- (PGV_NS+PGV_EW)/2
  
  xx$PGD_V <- round(PGD_V,6)
  xx$PGD_NS <- round(PGD_NS,6)
  xx$PGD_EW <- round(PGD_EW,6)
  xx$PGD_NS_EW <- (PGD_NS*PGD_EW)**0.5
  xx$PGD_amean <- (PGD_NS+PGD_EW)/2
  
  xx$HP_V <- HP_V  
  xx$LP_V <- LP_V  
  xx$HP_NS <-HP_NS 
  xx$LP_NS <-LP_NS 
  xx$HP_EW <-HP_EW 
  xx$LP_EW <-LP_EW 
  xx$author <- as.character(author)
  xx$Ia_Z <- Ia1_Z
  xx$Ia_NS <- Ia1_NS
  xx$Ia_EW <- Ia1_EW
  xx$Ia_NS_EW <- (Ia1_NS*Ia1_EW)**0.5
  xx$Ia_amean <- (Ia1_NS+Ia1_EW)/2
  # xx$Ia2_Z <- Ia2_Z
  # xx$Ia2_NS <- Ia2_NS
  # xx$Ia2_EW <-Ia2_EW
  
  
  
  #CHECKå­˜æ”¾æ¿¾æ³¢? »æ®µæ?‡å?—æ?”ä?�ç½®?˜¯?�¦å­˜åœ¨
  path9 <- paste("output_BSFL/TXT_output")
  ifelse(file.exists(path9),paste("file exit!"),dir.create(path9))
  
  path10 <- paste(path9,"/",rec.id,"_",filter.ID,".rdata",sep="")
  save(xx, file= path10,row.names = F)
  
  graphics.off()
  
  ### output psv, psa data
  # yy <- data.frame()
  # 
  # # copy from Function_Process_main_step2.R
  # psd.v <- rsp_V$sd
  # psd.ns <- rsp_NS$sd
  # psd.ew <- rsp_EW$sd
  # psa.v <- rsp_V$psa
  # psa.ns <- rsp_NS$psa
  # psa.ew <- rsp_EW$psa
  # psv.v <- rsp_V$psv
  # psv.ns <- rsp_NS$psv
  # psv.ew <- rsp_EW$psv
  # psa.sqrt <- sqrt(psa.ns*psa.ew)
  # 
  # period <- rsp_V$Period
  # 
  # #  yy <- cbind(period,psv.ns,psv.ew,psv.v,psa.ns,psa.ew,psa.v,psa.sqrt)
  # #  write.table(yy, file=paste("D:/2019æ¿¾æ³¢_SSHAC/RSP/",filter.ID,"_RSP.txt",sep=""),sep = " ",row.names = F)  
  # datat <- data.frame(t=period,h1=psd.ns,h2=psd.ew,h3=psd.v,h4=psv.ns,h5=psv.ew,h6=psv.v,h7=psa.ns,h8=psa.ew,h9=psa.v,h10=psa.sqrt)
  # datat.fmt <- c(" PERIOD(SEC)     PSD-NS         PSD-EW         PSD-Z         PSV-NS         PSV-EW         PSV-Z         PSA-NS         PSA-EW         PSA-Z         PSA-sqrt",
  #                sprintf("%10.3f%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E",datat$t,datat$h1,datat$h2,datat$h3,datat$h4,datat$h5,datat$h6,datat$h7,datat$h8,datat$h9,datat$h10))
  # path11 <- paste("output_BSFL/RSP_output/",sep="")
  # ifelse(file.exists(path11),paste("file exit!"),dir.create(path11))
  # write.table(datat.fmt,file=paste(path11,rec.id,"_RSP.txt",sep=""),row.names=FALSE,col.names=FALSE, quote=FALSE)
  
  # ### geomean value response spectrum
  # path.12=paste(path2,"/",rec.id,".",filter.ID,".GM_rsp_shape.png",sep="")
  # CairoPNG(filename = path.12, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
  # y <- psa.sqrt
  # yrange <- range(y)
  # yrange[1] <- 10^(floor(log10(yrange[1])))
  # yrange[2] <- 10^(ceiling(log10(yrange[2])))
  # x <- period
  # xrange <- range(x)
  # plot(xrange, yrange, log='xy', type='n', ylab='SA (g)', xlab='Period (sec)')
  # lines(x, y, lwd=2)
  # xtck <- c(array(outer(1:9, c(0.01,0.1,1.0))),10)
  # abline(v=xtck, col="grey90", lty=2)
  # ytck <- log10(yrange)
  # ytck <- 10^(seq(ytck[1], ytck[2]))
  # abline(h=ytck, col="grey90", lty=2) 
  # lines(period,psa.sqrt, type='l', lwd=5, col="orange")
  # uband <- 1.0/fc/1.25
  # mtext(paste(rec.id,"  ID=",file_id," response spectrum (geomean)"), line=3)
  # mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
  # mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
  # legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
  #        y.intersp=1.2)
  # abline(v=uband[1], lwd=2, col="blue", lty=2)
  # graphics.off()
  # 
  #### Output complete TS file
  # xx<- data.frame(rec.id)
  zz <- data.frame((matrix(ncol=10,nrow=nrow(accs), dimnames=list(NULL,c("Time","ACC.Z","ACC.NS","ACC.EW","VEL.Z","VEL.NS","VEL.EW","DIS.Z","DIS.NS","DIS.EW")))))
  zz$Time <- accs$time 
  zz$ACC.Z  <- ACC.Z
  zz$ACC.NS  <- ACC.NS
  zz$ACC.EW  <- ACC.EW
  zz$VEL.Z  <- VEL.Z
  zz$VEL.NS  <- VEL.NS
  zz$VEL.EW  <- VEL.EW
  zz$DIS.Z  <- DIS.Z
  zz$DIS.NS  <- DIS.NS
  zz$DIS.EW  <- DIS.EW
  # 
  path9 <- paste("output_BSFL/Time History/",sep="")
  ifelse(file.exists(path9),paste("file exit!"),dir.create(path9))
  path10 <- paste(path9,"/",rec.id,"_after_fl.txt",sep="")
  write.table(zz, file= path10,sep = ",",row.names = F)
  
  ### for running RCTC 
  # path13 <- paste("D:/2020 RCTC Result/Inputdata/")
  # ifelse(file.exists(path13),paste("file exit!"),dir.create(path13))
  # path14 <- paste("D:/2020 RCTC Result/Outputdata/")
  # ifelse(file.exists(path14),paste("file exit!"),dir.create(path14))
  # path15 <- paste("D:/2020 RCTC Result/Outputplot/")
  # ifelse(file.exists(path15),paste("file exit!"),dir.create(path15))
  #
  # IMplot(inputpath = "D:/2020 RCTC Result_v2/Inputdata/", datatype = "timeseries",
  #        tmax4penalty_in = 10, tmin4penalty_in = 0, combine_index = 50, ang1 = 0, damping = 0.05, fraction = 0.7, Interpolation_factor = "auto")
  # 
  # setwd("D:/Work/Database_20191101ver/03_filtering")
  
}


filter.frame <- read.csv(file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# for (i in 1:14){
#   if (i < 10){
#     filter.ID= paste0("B00000",i)
#     print(filter.ID)
#     ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
#   }
#   else if (i>=10 && i<100){
#     filter.ID= paste0("B0000",i)
#     print(filter.ID)
#     ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
#   }
#   else{
#     filter.ID= paste0("B000",i)
#     print(filter.ID)
#     ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
#   }
# }


filter.ID= "B00001"
ProcessTH(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)


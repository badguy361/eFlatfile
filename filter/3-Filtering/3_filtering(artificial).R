# 2021.07.28 BH filter
###
library(foreign)
library(digest)
library(Cairo)
library(stringr)
library(RSEIS) # New! for applying "rsspec.taper()"
library(RCTC)  # New! for calculating RotD50???...
###
### LOAD Functions
###
setwd("/app/filter/3-Filtering/")
source("SGM_Process/Function_Integrate2VD.r")    
source("SGM_Process/Function_Integrate_Ia.r")   
source("SGM_Process/Function_spectraw3.r")    
source("SGM_Process/Function_Baseline.r")     
source("SGM_Process/Function_Butterworth.r")    
source("SGM_Process/Function_write_DB.r")        
source("SGM_Process/Function_write_File.r")    
source("SGM_Process/Function_write_data.r")     
#source("SGM_Process/Function_tcltk_mesgbox.r")  
#source("SGM_Process/Function_Process.r")       

ProcessTH_art <- function(filter.ID, author, Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5) {
  ## 
  ## Skip and Add are used only for estimating displacement baseline
  ## 
  ## 1. Phase 1 (Vol. 1; type == 1) data may need instrument correction
  ## 2. Need better error checking and handling in 'spectraw'
  ##
  
  #rpage = url(data.info$url,'r')
  
  # filter.ID= "B000001"
  # author="yang"
  # Baseline=TRUE
  # PreBaseline=FALSE
  # Skip=0
  # Add=20
  # Taper=0
  # nDC=2000
  # tb=5
  # te=5
  # nPole=2.5
  
  data.info  <- filter.frame[filter.frame$filter.id==filter.ID,]
  rpage <- as.character(paste0("../../TSMIP_Dataset/picking_result/09/",str_pad(data.info$Month,2, pad = "0"),"/",data.info$Pfile)) 
  accs  <- read.table(rpage, skip=1, col.names=c("time","Z","H1","H2"))
  
  dt <- accs$time[2]-accs$time[1]
  YEAR <- data.info$Year
  MON <- data.info$Month
  DAY <- data.info$Date
  HOUR <- data.info$Hour
  MINUTE <- data.info$Minute
  SEC <- data.info$Second_event
  SGM_ID <- data.info$rec.id #2017_0101_0321_57_EDH
  EQ_ID <- data.info$EQ_ID #2017_0101_0321_57
  STA_ID <- data.info$Sta #EDH
  Lon <- data.info$origins.longitude
  Lat <- data.info$origins.latitude
  Depth <- data.info$origins.depth
  #
  # Hypo <- round(data.info$Hypo,2) #跟Rrup一�?(??�捨五入位置不�?��?)
  Rrup <- round(data.info$Adopted_Rrup,1)
  Mw <- data.info$final_Mw
  ML <- data.info$magnitudes.mag
  # hypo <- (((round(data.info$final.Lon,2)-round(data.info$Lon.Sta.X,2))*101.7)**2 + ((round(data.info$final.Lat,2)-round(data.info$Lat.Sta.Y,2))*110.9)**2)**(1/2)
  # ??�央�?
  
  # Instrument_type <- data.info$Instrument
  SGM_SN <- data.info$filter.id #B000001
  file_id <- data.info$Pfile #13010321.P18
  Pfile <- data.info$Pfile
  file_name <- data.info$file_name #201701010321_EDH_13010321.P18.asc
  print(file_name)
  
  HP_V <- 0 #高通濾�? 低通濾�?
  LP_V <- 0
  HP_NS <- 0
  LP_NS <- 0
  HP_EW <- 0
  LP_EW <- 0 
  
  ifelse(file.exists("Filtering Result/PROCESS_FILE_tmp"),paste("file exit!"),dir.create("Filtering Result/PROCESS_FILE_tmp"))
  path1 <- paste("Filtering Result/PROCESS_FILE_tmp/",YEAR,sep="")
  ifelse(file.exists(path1),paste("file exit!"),dir.create(path1))
  path2 <- paste("Filtering Result/PROCESS_FILE_tmp/",YEAR,"/",EQ_ID,sep="")
  ifelse(file.exists(path2),paste("file exit!"),dir.create(path2))
  
  # path8 <- paste("2017濾波_SSHAC/PROCESS_FILE_??????/",YEAR,"/",EQ_ID,"/PIC",sep="")
  # ifelse(file.exists(path8),paste("file exit!"),dir.create(path8))
  
  
  # if(file.exists(paste("D:/2017濾波_SSHAC/PROCESS_FILE_??????_H1_NS/TXT/",SGM_ID,"_",SGM_SN,".txt",sep=""))){
  #   print(paste(SGM_SN,"has already done!"))
  #   return()
  # }
  
  
  acc.v <- accs$Z/978.88 #�?規�?��?��?�念?
  acc.h1 <- accs$H1/978.88
  acc.h2 <- accs$H2/978.88
  #  x <- seq(1:dim(acc)[1])*data$DT
  npts<-dim(accs)[1] #dim得到該table raw?�� -> 總共??��?��?�個�??(?���?)
  start.time <- 0.0
  acc.1<- ts(acc.v, deltat=dt, start=start.time) # ts() :time series
  acc.2<- ts(acc.h1, deltat=dt, start=start.time)
  acc.3<- ts(acc.h2, deltat=dt, start=start.time)
  
  # for (i in 2:3){
  #   if(i == 2) acc <-acc.2 else acc <- acc.3
  #   if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC])
  #   if (tb > 0) nb <- npts * tb / 100 else nb <- tb
  #   if (te > 0) ne <- npts * te / 100 else ne <- te		
  #   if (Taper > 0) nTaper <- npts * Taper / 100 else nTaper <- Taper
  #   nSkip <- ceiling(Skip/dt)
  #   nAdd  <- ceiling(Add/dt)
  #   acc.bs  <- BslnAdj(acc, nTaper, nSkip, nAdd)
  
  #   vel <- integrate2V(acc*978.88)
  #   vel.bs <- integrate2V(acc.bs*978.88)
  #   #�???? ???位移 
  #   dis <- integrate2D(vel)
  #   dis.bs <- integrate2D(vel.bs)
  # 
  #   if(i == 2) rsp_NS <- spectraw2(acc.bs, 0.05, 'psv') else rsp_EW <- spectraw2(acc.bs, 0.05, 'psv')
  # }
  
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
    if (nDC < 0) 	acc <- acc - mean(acc[1:npts]) else 	acc <- acc - mean(acc[1:nDC]) #?��線校�???��?��??2000點平???
    
    # D. ?��線校�?
    #  Add=2
    #  Skip=0
    #  tb=5
    #  te=5                                                    
    #  nPole=2
    #  Taper=0
    if (tb > 0) nb <- npts * tb / 100 else nb <- tb  #tb?
    if (te > 0) ne <- npts * te / 100 else ne <- te	 #te?
    if (Taper > 0) nTaper <- npts * Taper / 100 else nTaper <- Taper
    nSkip <- ceiling(Skip/dt) #ceiling??�捨五入 skip?
    nAdd  <- ceiling(Add/dt) # add?
    acc.bs  <- BslnAdj(acc, nTaper, nSkip, nAdd) #以�?�小平?��法擬??�出位移歷�?��?�基�?
    
    vel <- integrate2V(acc*978.88)
    vel.bs <- integrate2V(acc.bs*978.88)
    
    dis <- integrate2D(vel)
    dis.bs <- integrate2D(vel.bs)
    
    
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  X11(record = TRUE, width = 9, height = 9)
    X11(width = 6, height = 6)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc, type="l", ylab="Acceleration (g)", xlab="time (sec)") #跑�?��?��??
    lines(acc.bs, col=6) #col -> pink ?��線校�???��?��?��??
    abline(h=0) #y = 0?��一條�??
    title(paste(EQ_ID,STA_ID,"Acceleration Time History",file_id,text.comp,"Baseline Correction", sep=",   "))
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
    
    ################
    
    path.1=paste(path2,"/",SGM_ID,".",SGM_SN,".AVD_bc.",text.comp,".png",sep="" )
    CairoPNG(filename = path.1, width = 1280, height = 1024 ,pointsize = 24, bg = "white") #存�?��??(bc)(?��CairoPNG存�?��?�好???)
    # X11(width = 9, height = 9) 
    layout(matrix(1:4,4,1), heights=c(1.5,4,4,4))
    text1 <-paste(EQ_ID,STA_ID,file_id,"Baseline Correction",text.comp, sep=",   ")
    #text2 <-paste(paste0("ML = ",ML),paste0("Hypo = ",Hypo," (km)"), sep=",   ")
    text2 <-paste(paste0("Mw = ",Mw),paste0("Rrup = ",Rrup," (km)"), sep=",   ")
    par(mar = c(0,0,0,0)) 
    plot(0,0, ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
    #text(x = 0.1, y = 0, text1, cex = 1.7, col = "black",font=2)
    text(x = 0.1, y = -0.8, text2, cex = 1.5, col = "blue",font=1) #Mw Rrup??��?��?��?�色大�??..
    #... 1. Acceleration time history
    par(mar = c(4,4,4,0)) 
    plot(acc, type="l" , ylab="Acceleration (g)", xlab="time (sec)",main=NULL) 
    lines(acc.bs, col=6)
    abline(h=0)
    title(paste0("Acceleration Time History"))
    points(which.max(abs(acc.bs))*dt,acc.bs[which.max(abs(acc.bs))], pch=18, col=2, cex=2)
    text(0,max(acc.bs)*0.5,substr(paste("PGA=",max(abs(acc.bs))),1,12), pos=4)
    # text(0,min(acc.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel, type="l", ylab="Velocity (cm/s)", xlab="time (sec)",ylim=c(min(vel,vel.bs),max(vel,vel.bs)))
    lines(vel.bs, col=6)
    abline(h=0)
    title(paste0("Velocity Time History"))
    points(which.max(abs(vel.bs))*dt,vel.bs[which.max(abs(vel.bs))], pch=18, col=2, cex=2)
    text(0,max(vel.bs)*0.5,substr(paste("PGV=",max(abs(vel.bs))),1,12), pos=4)
    # text(0,min(vel.bs)*0.5,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis, type="l", ylab="Displacement (cm)", xlab="time (sec)",ylim=c(min(dis,dis.bs),max(dis,dis.bs)))
    lines(dis.bs, col=6)
    abline(h=0)
    title(paste0("Displacement Time History"))
    points(which.max(abs(dis.bs))*dt,dis.bs[which.max(abs(dis.bs))], pch=18, col=2, cex=2)
    text(0,max(dis.bs)*0.5,substr(paste("PGD=",max(abs(dis.bs))),1,12), pos=4)
    # text(0,min(dis.bs)*0.5,paste(text.comp," component"), pos=4)
    dev.off()
    
    ###########################
    #  qc <- setqc()
    # ?��??��?��?�波??��??
    #... PSV (pseudo spectral velocit; tripartite plot would be better)
    rsp <- spectraw2(acc.bs, 0.05, 'psv') # spectraw2(acc.bs, damping, 'psv') ?��??��?��?��?�濾�?
    
    # X11(width = 15, height = 9)
    X11(width = 10, height = 6)
    layout(matrix(1:2,1,2))
    plot_spectra(rsp, "psv")
    ## new part (2021.03.26)
    # if(i ==2) lines(rsp_EW$Period, rsp_EW$psv, lwd=2,col="gray80") else if(i == 3) lines(rsp_NS$Period, rsp_NS$psv, lwd=2,col="gray80")
    #title(main = paste("ML =",ML,",", "Hypo =",Hypo,"km",sep=" "))
    title(main = paste("Mw =",Mw,",", "Rrup =",Rrup,"km",sep=" "))
    
    # filtered by human
    fc <- c()
    tmp <- locator(n=1, type='p', pch=16, col=6) #locator??��?��?��?�置座�??
    fc[1] <- 1./tmp$x[1] #得其?��???(?���?�倒數)
    fc[2] <- 100
    # print(c(fc[1]))
    # print(c(fc[2]))
    
    # ??��?��?��?��?��??(要濾波�??)
    nfft <- 2^(floor(logb(npts,2))+1) # logb(npts,2) = log2(npts)
    nNyq <- nfft/2+1
    idf <- 1.0/(nfft*dt)
    freqs <- (seq(1:nNyq)-1)*idf
    #湊長�?????��2???�???? 
    acc.bs2 <- c(acc.bs, rep(0, nfft-npts))
    #... Foward FFT
    fs <- fft(acc.bs2)
    fs.amp <- abs(fs[1:nNyq])
    fs.amp_o <- abs(fs[1:nNyq])    # fs.amp[-1] : ???fs.amp�????????��字拿???
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(text.comp," Component"))
    lines(freqs[-1], fs.amp[-1], type='l', lwd=2,col=6)
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2) #標出?��將highpass??�波段�?�波
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2) 
    
    # # all auto-filtering
    # fc <- c()
    # HP.T <- rsp$Period[which(rsp$psv==min(rsp$psv[57:105]))]
    # # if (HP.T=10.00){
    # #   HP.T <- 15.
    # # }
    # fc[1] <- 1/HP.T
    # fc[2] <- 100
    
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
    
    path.4=paste(path2,"/",SGM_ID,".",SGM_SN,".FFT.",text.comp,".png",sep="")
    CairoPNG(filename = path.4, width = 1280, height = 1024 ,pointsize = 24, bg = "white") #存�?��?��?��?��?��?��??(FFT)
    plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    title(paste(EQ_ID,STA_ID,paste(text.comp,"Component"), sep=",   "),line = 2.2)
    title(text2,line = 0.8)
    lines(freqs[-1], fs.amp_o[-1], type='l', lwd=2,col=6)
    abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
    abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
    lines(freqs[-1], fs.amp[-1], col=2)
    abline(v=fc, col=6, lwd=2)
    dev.off()	
    
    #
    #... Prepare Fourier spectrum for inverse FFT
    #
    fs[1] <- complex(real=Re(fs[1]), imaginary=0) #complex??�數(?��??��?�數=0)
    fs[nNyq] <- complex(real=Re(fs[nNyq]), imaginary=0)
    fs[nfft+2-(2:(nfft/2))] <- Conj(fs[2:(nfft/2)]) #conj?��軛�?�數
    
    #	
    #... Inverse FF 
    #
    acc.flt <- ts(data=Re(fft(fs, inverse=T))/nfft, deltat=dt, start=start.time) #??��?��?�次�?��?��?��?��?��?��?��?��?? Re得到該�?�數??�實?��
    
    #
    #... Keep only the original length
    #  
    acc.flt <- ts(acc.flt[1:npts], deltat=dt, start=start.time) #變�?��?�本??�dt總數
    
    #	
    #... Correct baseline drift after filtering	
    #
    if (Baseline) acc.flt <- BslnAdj(acc.flt, nTaper, nSkip, nAdd) #??�進�?��?�次基線校�?
    vel.flt <- integrate2V(acc.flt*981)
    dis.flt <- integrate2D(vel.flt)
    
    #	
    #... Plot filtered and baseline-corrected time histories
    #
    X11(width = 6, height = 6)
    layout(matrix(1:3,3,1))
    #... 1. Acceleration time history
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)") #?��?��線校�?+濾波+??�基線校�?後�?��??
    lines(acc.flt, col=6)
    abline(h=0)
    title(paste(EQ_ID ,STA_ID,"Acceleration Time History",file_id,text.comp,"Filtering", sep=",   "))
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
    
    path.2=paste(path2,"/",SGM_ID,".",SGM_SN,".AVD_fl.",text.comp,".png",sep="")
    CairoPNG(filename = path.2, width = 1280, height = 1024 ,pointsize = 24, bg = "white") #??��?��?�起�?(fl)
    layout(matrix(1:4,4,1), heights=c(1.5,4,4,4))
    par(mar = c(0,0,0,0))
    plot(0,0, ann = F, bty = 'n', type = 'n', xaxt = 'n', yaxt = 'n')
    text1 <-paste(EQ_ID,STA_ID,file_id,"Filtered",text.comp, sep=",   ")
    text(x = 0.1, y = 0, text1, cex = 1.7, col = "black",font=2)
    text(x = 0.1, y = -0.8, text2, cex = 1.5, col = "blue",font=1)
    #... 1. Acceleration time history 
    par(mar = c(4,4,4,0)) 
    plot(acc.bs, type="l", ylab="Acceleration (g)", xlab="time (sec)",main=NULL)
    lines(acc.flt, col=6)
    abline(h=0)
    title("Acceleration Time History")
    points(which.max(abs(acc.flt))*dt,acc.flt[which.max(abs(acc.flt))], pch=18, col=2, cex=2)
    text(0,max(acc.flt)*0.8,substr(paste("PGA=",max(abs(acc.flt))),1,12), pos=4)
    # text(0,min(acc.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 2. Velocity time history
    plot(vel.bs, type="l", ylab="Velocity (cm/s)", xlab="time (sec)",ylim=c(min(vel.bs,vel.flt),max(vel.bs,vel.flt)))
    lines(vel.flt, col=6)
    abline(h=0)
    title("Velocity Time History")
    points(which.max(abs(vel.flt))*dt,vel.flt[which.max(abs(vel.flt))], pch=18, col=2, cex=2)
    text(0,max(vel.flt)*0.8,substr(paste("PGV=",max(abs(vel.flt))),1,12), pos=4)
    # text(0,min(vel.flt)*0.8,paste(text.comp," component"), pos=4)
    #... 3. Displacement time history
    plot(dis.bs, type="l", ylab="Displacement (cm)", xlab="time (sec)",ylim=c(min(dis.bs,dis.flt),max(dis.bs,dis.flt)))
    lines(dis.flt, col=6)
    abline(h=0)
    title("Displacement Time History")
    points(which.max(abs(dis.flt))*dt,dis.flt[which.max(abs(dis.flt))], pch=18, col=2, cex=2)
    text(0,max(dis.flt)*0.8,substr(paste("PGD=",max(abs(dis.flt))),1,12), pos=4)
    # text(0,min(dis.flt)*0.8,paste(text.comp," component"), pos=4)
    dev.off()
    
    
    #... Compute and plot response spectra
    rsp.flt <- spectraw2(acc.flt, 0.05, "psa") 
    #	rsp <- spectraw2(acc.bs, 0.05, "psa")
    X11(width = 6, height = 6)
    plot_spectra(rsp.flt, "psv") #?��??��?��??(psv) 第�?�張???
    lines(rsp$Period, rsp$psv, type='l', lwd=2, col=8)
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste("ID=",file_id," ",text.comp), line=3)
    abline(v=1/fc[1], lwd=2, col="blue")
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)
    
    ### psv
    path.3=paste(path2,"/",SGM_ID,".",SGM_SN,".rsp_psv.",text.comp,".png",sep="")
    CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white") # ,  res = 100
    plot_spectra(rsp.flt, "psv")
    lines(rsp$Period, rsp$psv, type='l', lwd=2, col=8)
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste(EQ_ID,"_",STA_ID,"  ID=",file_id," ",text.comp), line=3)
    #text3 <- c(paste0("ML = ",ML),
              # paste0("Hypo = ",Hypo," (km)"))
    text3 <- c(paste0("Mw = ",Mw),
              paste0("Rrup = ",Rrup," (km)"))
    legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
          y.intersp=1.2)
    
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)
    abline(v=1/fc[1], lwd=2, col="blue")
    dev.off()
    
    ### psa
    path.3=paste(path2,"/",SGM_ID,".",SGM_SN,".rsp_psa.",text.comp,".png",sep="")
    CairoPNG(filename = path.3, width = 1280, height = 1024 ,pointsize = 24, bg = "white")
    plot_spectra(rsp.flt, "psa") #?��PSA??��?��??
    lines(rsp$Period, rsp$psa, type='l', lwd=2, col=8)
    uband <- 1.0/fc/1.25
    mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
    mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
    mtext(paste(SGM_ID,"  ID=",file_id," ",text.comp), line=3)
    legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
          y.intersp=1.2)
    if (!is.na(uband[1])) abline(v=uband[1], lwd=2, col=6)
    if (!is.na(uband[2])) abline(v=uband[2], lwd=2, col=6)		
    abline(v=1/fc[1], lwd=2, col="blue")
    dev.off()
    
    if(i ==1) PGA_V <-max(abs(acc.flt)) else if(i == 2) PGA_NS <-max(abs(acc.flt)) else PGA_EW <-max(abs(acc.flt))
    if(i ==1) PGV_V <-max(abs(vel.flt)) else if(i == 2) PGV_NS <-max(abs(vel.flt)) else PGV_EW <-max(abs(vel.flt))
    if(i ==1) PGD_V <-max(abs(dis.flt)) else if(i == 2) PGD_NS <-max(abs(dis.flt)) else PGD_EW <-max(abs(dis.flt))
    
    if(i ==1) rsp_V <- rsp.flt else if(i == 2) rsp_NS <-rsp.flt else rsp_EW <- rsp.flt
    
    #Write_to_DB(SGM_SN,SGM_ID,EQ_ID,EVN_ID,STA_ID,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author)
    acc.md5 <- digest(paste(acc.flt, collapse=","), serialize=FALSE) #不�?��?��?�面沒用?��
    #Write_to_DB(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author,acc.md5)
    #Write_to_DB_sort(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,author,acc.md5)
    
    if(i ==1) ACC.Z <-acc.flt else if(i == 2) ACC.NS <-acc.flt else ACC.EW <- acc.flt
    if(i ==1) VEL.Z <-vel.flt else if(i == 2) VEL.NS <-vel.flt else VEL.EW <- vel.flt
    if(i ==1) DIS.Z <-dis.flt else if(i == 2) DIS.NS <-dis.flt else DIS.EW <- dis.flt
    
    ### for running RCTC 
    if(i ==2){
      NS <- c(dt,acc.flt) #輸入濾�?�波後�?�東?��
      write.table(NS,file=paste0("Tmp_save_file/NS.txt"),col.names = FALSE,row.names = FALSE)
    } else if (i==3) {
      EW <- c(dt,acc.flt)
      write.table(EW,file=paste0("Tmp_save_file/EW.txt"),col.names = FALSE,row.names = FALSE)
    }
    nametransfer(filedir1 = paste0("Tmp_save_file/NS.txt"), filedir2 =paste0("Tmp_save_file/EW.txt"), stationname = SGM_SN , sn = SGM_ID,
                outputdir = 'Tmp_save_file/Inputdata')
                #得到RoTD50??��?��??
  }  #end of loop 3 component
  
  # 紀??�地??�波??��?��??
  xx<- data.frame(SGM_SN)
  xx$SGM_ID<-SGM_ID
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
  xx$PGV_V <- round(PGV_V,6)
  xx$PGV_NS <- round(PGV_NS,6)
  xx$PGV_EW <- round(PGV_EW,6)
  xx$PGD_V <- round(PGD_V,6)
  xx$PGD_NS <- round(PGD_NS,6)
  xx$PGD_EW <- round(PGD_EW,6)
  xx$HP_V <- HP_V  
  xx$LP_V <- LP_V  
  xx$HP_NS <-HP_NS 
  xx$LP_NS <-LP_NS 
  xx$HP_EW <-HP_EW 
  xx$LP_EW <-LP_EW 
  xx$author <- as.character(author)
  xx
  
  path9 <- paste("Filtering Result/TXT",sep="") 
  # ifelse(file.exists(path9),paste("file exit!"),dir.create(path9))
  
  path10 <- paste(path9,"/",SGM_ID,"_",SGM_SN,".txt",sep="")
  write.table(xx, file= path10,sep = ",",row.names = F)
  
  graphics.off()
  
  # 紀??��?��?��?��?��?��??
  ### output psv, psa data
  yy <- data.frame()
  # copy from Function_Process_main_step2.R
  psd.v <- rsp_V$sd
  psd.ns <- rsp_NS$sd
  psd.ew <- rsp_EW$sd
  psa.v <- rsp_V$psa
  psa.ns <- rsp_NS$psa
  psa.ew <- rsp_EW$psa
  psv.v <- rsp_V$psv
  psv.ns <- rsp_NS$psv
  psv.ew <- rsp_EW$psv
  psa.sqrt <- sqrt(psa.ns*psa.ew)
  
  period <- rsp_V$Period
  
  #  yy <- cbind(period,psv.ns,psv.ew,psv.v,psa.ns,psa.ew,psa.v,psa.sqrt)
  #  write.table(yy, file=paste("D:/2017濾波_SSHAC/RSP/",SGM_SN,"_RSP.txt",sep=""),sep = " ",row.names = F)  
  datat <- data.frame(t=period,h1=psd.ns,h2=psd.ew,h3=psd.v,h4=psv.ns,h5=psv.ew,h6=psv.v,h7=psa.ns,h8=psa.ew,h9=psa.v,h10=psa.sqrt)
  datat.fmt <- c(" PERIOD(SEC)     PSD-NS         PSD-EW         PSD-Z         PSV-NS         PSV-EW         PSV-Z         PSA-NS         PSA-EW         PSA-Z         PSA-sqrt",
                sprintf("%10.3f%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E",datat$t,datat$h1,datat$h2,datat$h3,datat$h4,datat$h5,datat$h6,datat$h7,datat$h8,datat$h9,datat$h10))
  path11 <- paste("Filtering Result/RSP/",sep="")
  # ifelse(file.exists(path11),paste("file exit!"),dir.create(path11))
  write.table(datat.fmt,file=paste(path11,SGM_ID,"_RSP.txt",sep=""),row.names=FALSE,col.names=FALSE, quote=FALSE)
  
  ### geomean value response spectrum
  path.12=paste(path2,"/",SGM_ID,".",SGM_SN,".GM_rsp_shape.png",sep="")
  CairoPNG(filename = path.12, width = 1280, height = 1024 ,pointsize = 24, bg = "white") #存起來�?�後�?��?��?��?? ?��pga平方後�?��?��??
  y <- psa.sqrt
  yrange <- range(y)
  yrange[1] <- 10^(floor(log10(yrange[1])))
  yrange[2] <- 10^(ceiling(log10(yrange[2])))
  x <- period
  xrange <- range(x)
  plot(xrange, yrange, log='xy', type='n', ylab='SA (g)', xlab='Period (sec)')
  lines(x, y, lwd=2)
  xtck <- c(array(outer(1:9, c(0.01,0.1,1.0))),10)
  abline(v=xtck, col=8, lty=2)
  ytck <- log10(yrange)
  ytck <- 10^(seq(ytck[1], ytck[2]))
  abline(h=ytck, col=8, lty=2) 
  lines(period,psa.sqrt, type='l', lwd=5, col="darkorange")
  uband <- 1.0/fc/1.25
  mtext(paste(SGM_ID,"  ID=",file_id," response spectrum (geomean)"), line=3)
  mtext(paste("Bandpass Filtered Between ", signif(fc[1],4), '(Hz) and ', signif(fc[2],4), "(Hz)", sep=''), line=2)
  mtext(paste("Usable Period Range ", signif(uband[1],4), '(Sec) and ', signif(uband[2],4), "(Sec)", sep=''), line=1)
  legend("bottomleft", legend=text3,bg="transparent",cex=1,bty = "n",
        y.intersp=1.2)
  abline(v=uband[1], lty=5 , lwd=2, col="black")
  dev.off()
}

filter.frame <- read.csv(file="sgm.2021_Frv_Fnm.rec_Rrup.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
for (i in 1:14){
  if (i < 10){
    filter.ID= paste0("B00000",i)
    print(filter.ID)
    ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
  }
  else if (i>=10 && i<100){
    filter.ID= paste0("B0000",i)
    print(filter.ID)
    ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
  }
  else{
    filter.ID= paste0("B000",i)
    print(filter.ID)
    ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
  }
}


# filter.ID= "B000841"
# ProcessTH_art(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
# 

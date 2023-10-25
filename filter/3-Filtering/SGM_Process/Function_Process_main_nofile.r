### Set Work directory
setwd('C:/Users/stella/Desktop/SGMDB16/SGM/')
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
source("SGM_Process/Function_Integrate2VD.r")    #¿n¤À¨ç¼Æ•¸
source("SGM_Process/Function_Integrate_Ia.r")    #Ia­pºâ
source("SGM_Process/Function_spectraw3.r")       #­pºâ¤ÏÀ³ÃÐ
source("SGM_Process/Function_Baseline.r")        #°ò½u®Õ¥¿
source("SGM_Process/Function_Butterworth.r")     #ButterworthÂoªi¨ç¼Æ
source("SGM_Process/Function_write_DB.r")        #¼g¤J¸ê®Æ®w
source("SGM_Process/Function_write_File.r")      #¼g¤JÀÉ®×
source("SGM_Process/Function_write_data.r")      #¼g¸ê®Æ
#source("SGM_Process/Function_tcltk_mesgbox.r")  #¿ï¨ú¸ê®Æ«~½èµøµ¡
#source("SGM_Process/Function_Process.r")        #¥Dµ{¦¡

###
#  source("SGM_Process/Function_plot_processed_SGM.r")    #

data.all <- read.table("filter_list/filter2016.txt",header=T)

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
  YEAR <- data.info$Year
  MON <- data.info$Month
  DAY <- data.info$Day
  HOUR <- data.info$Hour
  MINUTE <- data.info$Minute
  SEC <- data.info$Sec 
  SGM_ID <- data.info$SGM_ID
  EQ_ID <- data.info$EQ_ID
  STA_ID <- data.info$STA_ID
  Lon <- data.info$Lon.X
  Lat <- data.info$Lat.Y
  Depth <- data.info$Depth
  Distance <- data.info$Distance
  Hypo <- data.info$Hypo
  ML <- data.info$ML
  Instrument_type <- data.info$Instrument_type
  SGM_SN <- data.info$SGM_SN
  file_id <- data.info$file_id
  Pfile <- data.info$Pfile
  file_name <- data.info$file_name
  file_path <- data.info$url
  
  HP_V <- 0
  LP_V <- 0
  HP_NS <- 0
  LP_NS <- 0
  HP_EW <- 0
  LP_EW <- 0 
  
  #path1 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,sep="")
  #ifelse(file.exists(path1),paste("file exit!"),dir.create(path1))
  #path2 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,sep="")
  #ifelse(file.exists(path2),paste("file exit!"),dir.create(path2))
  #CHECK¦s©ñ¹ÏÀÉ¦ì¸m¬O§_¦s¦b
  #path8 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,"/PIC",sep="")
  #ifelse(file.exists(path8),paste("file exit!"),dir.create(path8))
  #CHECK¦s©ñ³t«×¸ê®ÆÀÉ¦ì¸m¬O§_¦s¦b
  #path5 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,"/VEL",sep="")
  #ifelse(file.exists(path5),paste("file exit!"),dir.create(path5))
  #CHECK¦s©ñ¦ì²¾¸ê®ÆÀÉ¦ì¸m¬O§_¦s¦b
  #path6 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,"/DIS",sep="")
  #ifelse(file.exists(path6),paste("file exit!"),dir.create(path6))
  #CHECK¦s©ñ¤ÏÀ³ÃÐ¸ê®ÆÀÉ¦ì¸m¬O§_¦s¦b
  #path7 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,"/RSP",sep="")
  #ifelse(file.exists(path7),paste("file exit!"),dir.create(path7))
  
  #§â¤§«eÂ²³æ¿é¥XªºÂoªi¸ê®ÆÅª¤J
  SN.txt <- paste("C:/Users/stella/Desktop/SGMDB2016/SGM/PROCESS_FILE/TXT/",SGM_SN,".txt",sep="")
  SN.data <- read.table(file = SN.txt,header = T,sep=",")
  
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
  fc <- c()
  for (i in 1:3){
    if(i ==1) {
      acc <-acc.1 
	    fc[1] <- SN.data$HP_V[1]
	    fc[2] <- SN.data$LP_V[1]
    } else {
	      if(i == 2) {
	        acc <-acc.2 
	        fc[1] <- SN.data$HP_NS[1]
	        fc[2] <- SN.data$LP_NS[1]
	      } else {
	         acc <- acc.3
	         fc[1] <- SN.data$HP_EW[1]
	         fc[2] <- SN.data$LP_EW[1]
	      }
	    }

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
    
    
    #  qc <- setqc()
    # F. Ã¸¹Ï ¤ÏÀ³ÃÐ ³Å¤óÃÐ 
    #... PSV (pseudo spectral velocit; tripartite plot would be better)
    rsp <- spectraw2(acc.bs, 0.05, 'psv')
    #   print("OK")
    # set graphic for plotting
    #  graphics.off()
    #  .SavedPlots <- NULL # Deletes any existing plot history
    #  windows(record = TRUE, width = 15, height = 9)
    
    #windows(width = 15, height = 9)
    #layout(matrix(1:2,1,2))
    #plot_spectra(rsp, "psv")
    
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
    #plot(c(0.01,100), range(fs.amp[-1]), log='xy', type='n',xlab='Frequency (Hz)', ylab='Fourier Amplitude')
    #title(paste(text.comp," Component"))
    #lines(freqs[-1], fs.amp[-1], type='l', lwd=2,col=6)
    #abline(v=array(outer(1:9, c(0.01,0.1,1,10,100))), col=8, lty=2)
    #abline(h=c(0.00001,0.0001,0.001,0.01,0.1,1,10,100), col=8, lty=2)
    
    #
    #... Locate corners of bandpass filter
    #
   #fc <- locator(n=2, type='p', pch=16, col=6)
   #fc <- sort(fc$x)
    #fc <- c(0.1,25) #©T©wÀW¬qÂoªi
    
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
    #lines(freqs[-1], fs.amp[-1], col=2)
    #abline(v=fc, col=6, lwd=2)
    
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
    
    
    #... Compute and plot response spectra
    rsp.flt <- spectraw2(acc.flt, 0.05, "psa")
    #	rsp <- spectraw2(acc.bs, 0.05, "psa")
    
    if(i ==1) PGA_V <-max(abs(acc.flt)) else if(i == 2) PGA_NS <-max(abs(acc.flt)) else PGA_EW <-max(abs(acc.flt))
    if(i ==1) PGV_V <-max(abs(vel.flt)) else if(i == 2) PGV_NS <-max(abs(vel.flt)) else PGV_EW <-max(abs(vel.flt))
    if(i ==1) PGD_V <-max(abs(dis.flt)) else if(i == 2) PGD_NS <-max(abs(dis.flt)) else PGD_EW <-max(abs(dis.flt))
    #PGA <- max(abs(acc.flt))
    #PGV <- max(abs(vel.flt))
    #PGD <- max(abs(dis.flt))
    if(i ==1) rsp_V <- rsp.flt else if(i == 2) rsp_NS <-rsp.flt else rsp_EW <- rsp.flt
    
    #Write_to_DB(SGM_SN,SGM_ID,EQ_ID,EVN_ID,STA_ID,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author)
    acc.md5 <- digest(paste(acc.flt, collapse=","), serialize=FALSE) 
    #Write_to_DB(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,rsp$psa,author,acc.md5)
    #Write_to_DB_sort(file_id,Pfile,file_name,i,nPole,fc[1],fc[2],PGA,PGV,PGD,author,acc.md5)
    
    if(i ==1) ACC.Z <-acc.flt else if(i == 2) ACC.NS <-acc.flt else ACC.EW <- acc.flt
    if(i ==1) VEL.Z <-vel.flt else if(i == 2) VEL.NS <-vel.flt else VEL.EW <- vel.flt
    if(i ==1) DIS.Z <-dis.flt else if(i == 2) DIS.NS <-dis.flt else DIS.EW <- dis.flt
    
  }  #end of loop 3 component
  
  psa.v <- rsp_V$psa
  psa.ns <- rsp_NS$psa
  psa.ew <- rsp_EW$psa
  psv.v <- rsp_V$psv
  psv.ns <- rsp_NS$psv
  psv.ew <- rsp_EW$psv
  period <- rsp_V$Period
  # ¼g¨ìÀÉ®× 
  #md5s <- Write_to_file(SGM_ID,EQ_ID,YEAR,MON,DAY,HOUR,MINUTE,SEC,Lon,Lat,Depth,ML,Distance,Hypo,
  #                      STA_ID,dt,npts,Instrument_type,PGA_V,PGA_NS,PGA_EW,PGV_V,PGV_NS,PGV_EW,
  #                      PGD_V,PGD_NS,PGD_EW,HP_V,HP_NS,HP_EW,LP_V,LP_NS,LP_EW,author,ACC.Z,ACC.NS,ACC.EW,SGM_SN)
  #CHECK¦s©ñ­ì©l°O¿ýÀÉ¦ì¸m¬O§_¦s¦b
  #path4 <- paste("C:/Users/stella/Desktop/SGMDB16/SGM/PROCESS_FILE/",YEAR,"/",EQ_ID,"/ACC/",SGM_ID,".IFO",sep="")
  #ifelse(file.exists(path4),paste("file exit!"),file.copy(from=rpage,to=path4))
  
  #¿é¥X³t«×¸ê®Æ
  #Write_data(paste(path5,"/",SGM_ID,".VEL",sep=""),SGM_ID,VEL.Z,VEL.NS,VEL.EW,npts,dt)
  #¿é¥X¦ì²¾¸ê®Æ
  #Write_data(paste(path6,"/",SGM_ID,".DIS",sep=""),SGM_ID,DIS.Z,DIS.NS,DIS.EW,npts,dt)
  #¿é¥X¤ÏÀ³ÃÐ¸ê®Æ
  #Write_rsp_data(paste(path7,"/",SGM_ID,".RSP050",sep=""),SGM_ID,psa.v,psa.ns,psa.ew,psv.v,psv.ns,psv.ew,period)
  
  # ¼g¦^¸ê®Æ®w	
  #Write_ACC_to_DB(file_id,Pfile,file_name,dt,npts,md5s, author)
  
  #graphics.off()
  
  #Update_Proces_List(SGM_SN)
  
  #xx<- SGM_SN 
  #path4<- paste("C:/Users/user/Desktop/meinon/data_f/",SGM_SN,".txt",sep="")
  #write.table(xx, file= path4,sep = ",",row.names = F)
  
  #SGM_SN <-"R000001"
  #xx <- read.table(paste("C:/Users/user/Desktop/meinon/data_f/",SGM_SN,".txt",sep=""), stringsAsFactors=FALSE, header=TRUE, sep=",")
  
  
  xx<- data.frame(SGM_SN)
  
  xx$SGM_SN<-SGM_SN
  #xx$EVN_ID<-EVN_ID
  xx$STA_ID<-STA_ID
  xx$dt<-dt
  xx$npts<-npts
  #xx$time<-accs$time
  xx$file_id    <-  file_id   
  xx$Pfile      <-  Pfile     
  xx$file_name  <-  file_name 
  xx$HP_V <- HP_V  
  xx$LP_V <- LP_V  
  xx$HP_NS <-HP_NS 
  xx$LP_NS <-LP_NS 
  xx$HP_EW <-HP_EW 
  xx$LP_EW <-LP_EW 
  xx$PGA_V <- PGA_V 
  xx$PGA_NS <- PGA_NS
  xx$PGA_EW <- PGA_EW
  xx$PGV_V <- PGV_V 
  xx$PGV_NS <- PGV_NS
  xx$PGV_EW <- PGV_EW
  xx$PGD_V <- PGD_V
  xx$PGD_NS <- PGD_NS
  xx$PGD_EW <- PGD_EW
  
  xx$T0_010S_V  <-  rsp_V$psa[1 ]
  xx$T0_020S_V  <-  rsp_V$psa[2 ]
  xx$T0_022S_V  <-  rsp_V$psa[3 ]
  xx$T0_025S_V  <-  rsp_V$psa[4 ]
  xx$T0_029S_V  <-  rsp_V$psa[5 ]
  xx$T0_030S_V  <-  rsp_V$psa[6 ]
  xx$T0_032S_V  <-  rsp_V$psa[7 ]
  xx$T0_035S_V  <-  rsp_V$psa[8 ]
  xx$T0_036S_V  <-  rsp_V$psa[9 ]
  xx$T0_040S_V  <-  rsp_V$psa[10]
  xx$T0_042S_V  <-  rsp_V$psa[11]
  xx$T0_044S_V  <-  rsp_V$psa[12]
  xx$T0_045S_V  <-  rsp_V$psa[13]
  xx$T0_046S_V  <-  rsp_V$psa[14]
  xx$T0_048S_V  <-  rsp_V$psa[15]
  xx$T0_050S_V  <-  rsp_V$psa[16]
  xx$T0_055S_V  <-  rsp_V$psa[17]
  xx$T0_060S_V  <-  rsp_V$psa[18]
  xx$T0_065S_V  <-  rsp_V$psa[19]
  xx$T0_067S_V  <-  rsp_V$psa[20]
  xx$T0_070S_V  <-  rsp_V$psa[21]
  xx$T0_075S_V  <-  rsp_V$psa[22]
  xx$T0_080S_V  <-  rsp_V$psa[23]
  xx$T0_085S_V  <-  rsp_V$psa[24]
  xx$T0_090S_V  <-  rsp_V$psa[25]
  xx$T0_095S_V  <-  rsp_V$psa[26]
  xx$T0_100S_V  <-  rsp_V$psa[27]
  xx$T0_110S_V  <-  rsp_V$psa[28]
  xx$T0_120S_V  <-  rsp_V$psa[29]
  xx$T0_130S_V  <-  rsp_V$psa[30]
  xx$T0_133S_V  <-  rsp_V$psa[31]
  xx$T0_140S_V  <-  rsp_V$psa[32]
  xx$T0_150S_V  <-  rsp_V$psa[33]
  xx$T0_160S_V  <-  rsp_V$psa[34]
  xx$T0_170S_V  <-  rsp_V$psa[35]
  xx$T0_180S_V  <-  rsp_V$psa[36]
  xx$T0_190S_V  <-  rsp_V$psa[37]
  xx$T0_200S_V  <-  rsp_V$psa[38]
  xx$T0_220S_V  <-  rsp_V$psa[39]
  xx$T0_240S_V  <-  rsp_V$psa[40]
  xx$T0_250S_V  <-  rsp_V$psa[41]
  xx$T0_260S_V  <-  rsp_V$psa[42]
  xx$T0_280S_V  <-  rsp_V$psa[43]
  xx$T0_290S_V  <-  rsp_V$psa[44]
  xx$T0_300S_V  <-  rsp_V$psa[45]
  xx$T0_320S_V  <-  rsp_V$psa[46]
  xx$T0_340S_V  <-  rsp_V$psa[47]
  xx$T0_350S_V  <-  rsp_V$psa[48]
  xx$T0_360S_V  <-  rsp_V$psa[49]
  xx$T0_380S_V  <-  rsp_V$psa[50]
  xx$T0_400S_V  <-  rsp_V$psa[51]
  xx$T0_420S_V  <-  rsp_V$psa[52]
  xx$T0_440S_V  <-  rsp_V$psa[53]
  xx$T0_450S_V  <-  rsp_V$psa[54]
  xx$T0_460S_V  <-  rsp_V$psa[55]
  xx$T0_480S_V  <-  rsp_V$psa[56]
  xx$T0_500S_V  <-  rsp_V$psa[57]
  xx$T0_550S_V  <-  rsp_V$psa[58]
  xx$T0_600S_V  <-  rsp_V$psa[59]
  xx$T0_650S_V  <-  rsp_V$psa[60]
  xx$T0_667S_V  <-  rsp_V$psa[61]
  xx$T0_700S_V  <-  rsp_V$psa[62]
  xx$T0_750S_V  <-  rsp_V$psa[63]
  xx$T0_800S_V  <-  rsp_V$psa[64]
  xx$T0_850S_V  <-  rsp_V$psa[65]
  xx$T0_900S_V  <-  rsp_V$psa[66]
  xx$T0_950S_V  <-  rsp_V$psa[67]
  xx$T1_000S_V  <-  rsp_V$psa[68]
  xx$T1_100S_V  <-  rsp_V$psa[69]
  xx$T1_200S_V  <-  rsp_V$psa[70]
  xx$T1_300S_V  <-  rsp_V$psa[71]
  xx$T1_400S_V  <-  rsp_V$psa[72]
  xx$T1_500S_V  <-  rsp_V$psa[73]
  xx$T1_600S_V  <-  rsp_V$psa[74]
  xx$T1_700S_V  <-  rsp_V$psa[75]
  xx$T1_800S_V  <-  rsp_V$psa[76]
  xx$T1_900S_V  <-  rsp_V$psa[77]
  xx$T2_000S_V  <-  rsp_V$psa[78]
  xx$T2_200S_V  <-  rsp_V$psa[79]
  xx$T2_400S_V  <-  rsp_V$psa[80]
  xx$T2_500S_V  <-  rsp_V$psa[81]
  xx$T2_600S_V  <-  rsp_V$psa[82]
  xx$T2_800S_V  <-  rsp_V$psa[83]
  xx$T3_000S_V  <-  rsp_V$psa[84]
  xx$T3_200S_V  <-  rsp_V$psa[85]
  xx$T3_400S_V  <-  rsp_V$psa[86]
  xx$T3_500S_V  <-  rsp_V$psa[87]
  xx$T3_600S_V  <-  rsp_V$psa[88]
  xx$T3_800S_V  <-  rsp_V$psa[89]
  xx$T4_000S_V  <-  rsp_V$psa[90]
  xx$T4_200S_V  <-  rsp_V$psa[91]
  xx$T4_400S_V  <-  rsp_V$psa[92]
  xx$T4_600S_V  <-  rsp_V$psa[93]
  xx$T4_800S_V  <-  rsp_V$psa[94]
  xx$T5_000S_V  <-  rsp_V$psa[95]
  xx$T5_500S_V  <-  rsp_V$psa[96]
  xx$T6_000S_V  <-  rsp_V$psa[97]
  xx$T6_500S_V  <-  rsp_V$psa[98]
  xx$T7_000S_V  <-  rsp_V$psa[99]
  xx$T7_500S_V  <-  rsp_V$psa[100]
  xx$T8_000S_V  <-  rsp_V$psa[101]
  xx$T8_500S_V  <-  rsp_V$psa[102]
  xx$T9_000S_V  <-  rsp_V$psa[103]
  xx$T9_500S_V  <-  rsp_V$psa[104]
  xx$T10_000S_V <-  rsp_V$psa[105]
  
  xx$T0_010S_NS  <-  rsp_NS$psa[1 ]  
  xx$T0_020S_NS  <-  rsp_NS$psa[2 ]  
  xx$T0_022S_NS  <-  rsp_NS$psa[3 ]  
  xx$T0_025S_NS  <-  rsp_NS$psa[4 ]  
  xx$T0_029S_NS  <-  rsp_NS$psa[5 ]  
  xx$T0_030S_NS  <-  rsp_NS$psa[6 ]  
  xx$T0_032S_NS  <-  rsp_NS$psa[7 ]  
  xx$T0_035S_NS  <-  rsp_NS$psa[8 ]  
  xx$T0_036S_NS  <-  rsp_NS$psa[9 ]  
  xx$T0_040S_NS  <-  rsp_NS$psa[10]  
  xx$T0_042S_NS  <-  rsp_NS$psa[11]  
  xx$T0_044S_NS  <-  rsp_NS$psa[12]  
  xx$T0_045S_NS  <-  rsp_NS$psa[13]  
  xx$T0_046S_NS  <-  rsp_NS$psa[14]  
  xx$T0_048S_NS  <-  rsp_NS$psa[15]  
  xx$T0_050S_NS  <-  rsp_NS$psa[16]  
  xx$T0_055S_NS  <-  rsp_NS$psa[17]  
  xx$T0_060S_NS  <-  rsp_NS$psa[18]  
  xx$T0_065S_NS  <-  rsp_NS$psa[19]  
  xx$T0_067S_NS  <-  rsp_NS$psa[20]  
  xx$T0_070S_NS  <-  rsp_NS$psa[21]  
  xx$T0_075S_NS  <-  rsp_NS$psa[22]  
  xx$T0_080S_NS  <-  rsp_NS$psa[23]  
  xx$T0_085S_NS  <-  rsp_NS$psa[24]  
  xx$T0_090S_NS  <-  rsp_NS$psa[25]  
  xx$T0_095S_NS  <-  rsp_NS$psa[26]  
  xx$T0_100S_NS  <-  rsp_NS$psa[27]  
  xx$T0_110S_NS  <-  rsp_NS$psa[28]  
  xx$T0_120S_NS  <-  rsp_NS$psa[29]  
  xx$T0_130S_NS  <-  rsp_NS$psa[30]  
  xx$T0_133S_NS  <-  rsp_NS$psa[31]  
  xx$T0_140S_NS  <-  rsp_NS$psa[32]  
  xx$T0_150S_NS  <-  rsp_NS$psa[33]  
  xx$T0_160S_NS  <-  rsp_NS$psa[34]  
  xx$T0_170S_NS  <-  rsp_NS$psa[35]  
  xx$T0_180S_NS  <-  rsp_NS$psa[36]  
  xx$T0_190S_NS  <-  rsp_NS$psa[37]  
  xx$T0_200S_NS  <-  rsp_NS$psa[38]  
  xx$T0_220S_NS  <-  rsp_NS$psa[39]  
  xx$T0_240S_NS  <-  rsp_NS$psa[40]  
  xx$T0_250S_NS  <-  rsp_NS$psa[41]  
  xx$T0_260S_NS  <-  rsp_NS$psa[42]  
  xx$T0_280S_NS  <-  rsp_NS$psa[43]  
  xx$T0_290S_NS  <-  rsp_NS$psa[44]  
  xx$T0_300S_NS  <-  rsp_NS$psa[45]  
  xx$T0_320S_NS  <-  rsp_NS$psa[46]  
  xx$T0_340S_NS  <-  rsp_NS$psa[47]  
  xx$T0_350S_NS  <-  rsp_NS$psa[48]  
  xx$T0_360S_NS  <-  rsp_NS$psa[49]  
  xx$T0_380S_NS  <-  rsp_NS$psa[50]  
  xx$T0_400S_NS  <-  rsp_NS$psa[51]  
  xx$T0_420S_NS  <-  rsp_NS$psa[52]  
  xx$T0_440S_NS  <-  rsp_NS$psa[53]  
  xx$T0_450S_NS  <-  rsp_NS$psa[54]  
  xx$T0_460S_NS  <-  rsp_NS$psa[55]  
  xx$T0_480S_NS  <-  rsp_NS$psa[56]  
  xx$T0_500S_NS  <-  rsp_NS$psa[57]  
  xx$T0_550S_NS  <-  rsp_NS$psa[58]  
  xx$T0_600S_NS  <-  rsp_NS$psa[59]  
  xx$T0_650S_NS  <-  rsp_NS$psa[60]  
  xx$T0_667S_NS  <-  rsp_NS$psa[61]  
  xx$T0_700S_NS  <-  rsp_NS$psa[62]  
  xx$T0_750S_NS  <-  rsp_NS$psa[63]  
  xx$T0_800S_NS  <-  rsp_NS$psa[64]  
  xx$T0_850S_NS  <-  rsp_NS$psa[65]  
  xx$T0_900S_NS  <-  rsp_NS$psa[66]  
  xx$T0_950S_NS  <-  rsp_NS$psa[67]  
  xx$T1_000S_NS  <-  rsp_NS$psa[68]  
  xx$T1_100S_NS  <-  rsp_NS$psa[69]  
  xx$T1_200S_NS  <-  rsp_NS$psa[70]  
  xx$T1_300S_NS  <-  rsp_NS$psa[71]  
  xx$T1_400S_NS  <-  rsp_NS$psa[72]  
  xx$T1_500S_NS  <-  rsp_NS$psa[73]  
  xx$T1_600S_NS  <-  rsp_NS$psa[74]
  xx$T1_700S_NS  <-  rsp_NS$psa[75]
  xx$T1_800S_NS  <-  rsp_NS$psa[76]
  xx$T1_900S_NS  <-  rsp_NS$psa[77]  
  xx$T2_000S_NS  <-  rsp_NS$psa[78]  
  xx$T2_200S_NS  <-  rsp_NS$psa[79]  
  xx$T2_400S_NS  <-  rsp_NS$psa[80]  
  xx$T2_500S_NS  <-  rsp_NS$psa[81]  
  xx$T2_600S_NS  <-  rsp_NS$psa[82]  
  xx$T2_800S_NS  <-  rsp_NS$psa[83]  
  xx$T3_000S_NS  <-  rsp_NS$psa[84]  
  xx$T3_200S_NS  <-  rsp_NS$psa[85]  
  xx$T3_400S_NS  <-  rsp_NS$psa[86]  
  xx$T3_500S_NS  <-  rsp_NS$psa[87]  
  xx$T3_600S_NS  <-  rsp_NS$psa[88]  
  xx$T3_800S_NS  <-  rsp_NS$psa[89]  
  xx$T4_000S_NS  <-  rsp_NS$psa[90]  
  xx$T4_200S_NS  <-  rsp_NS$psa[91]  
  xx$T4_400S_NS  <-  rsp_NS$psa[92]  
  xx$T4_600S_NS  <-  rsp_NS$psa[93]  
  xx$T4_800S_NS  <-  rsp_NS$psa[94]  
  xx$T5_000S_NS  <-  rsp_NS$psa[95]  
  xx$T5_500S_NS  <-  rsp_NS$psa[96]  
  xx$T6_000S_NS  <-  rsp_NS$psa[97]  
  xx$T6_500S_NS  <-  rsp_NS$psa[98]  
  xx$T7_000S_NS  <-  rsp_NS$psa[99]  
  xx$T7_500S_NS  <-  rsp_NS$psa[100]  
  xx$T8_000S_NS  <-  rsp_NS$psa[101]  
  xx$T8_500S_NS  <-  rsp_NS$psa[102]  
  xx$T9_000S_NS  <-  rsp_NS$psa[103]  
  xx$T9_500S_NS  <-  rsp_NS$psa[104]  
  xx$T10_000S_NS <-  rsp_NS$psa[105]
  
  xx$T0_010S_EW  <-  rsp_EW$psa[1 ]  
  xx$T0_020S_EW  <-  rsp_EW$psa[2 ]  
  xx$T0_022S_EW  <-  rsp_EW$psa[3 ]  
  xx$T0_025S_EW  <-  rsp_EW$psa[4 ]  
  xx$T0_029S_EW  <-  rsp_EW$psa[5 ]  
  xx$T0_030S_EW  <-  rsp_EW$psa[6 ]  
  xx$T0_032S_EW  <-  rsp_EW$psa[7 ]  
  xx$T0_035S_EW  <-  rsp_EW$psa[8 ]  
  xx$T0_036S_EW  <-  rsp_EW$psa[9 ]  
  xx$T0_040S_EW  <-  rsp_EW$psa[10]  
  xx$T0_042S_EW  <-  rsp_EW$psa[11]  
  xx$T0_044S_EW  <-  rsp_EW$psa[12]  
  xx$T0_045S_EW  <-  rsp_EW$psa[13]  
  xx$T0_046S_EW  <-  rsp_EW$psa[14]  
  xx$T0_048S_EW  <-  rsp_EW$psa[15]  
  xx$T0_050S_EW  <-  rsp_EW$psa[16]  
  xx$T0_055S_EW  <-  rsp_EW$psa[17]  
  xx$T0_060S_EW  <-  rsp_EW$psa[18]  
  xx$T0_065S_EW  <-  rsp_EW$psa[19]  
  xx$T0_067S_EW  <-  rsp_EW$psa[20]  
  xx$T0_070S_EW  <-  rsp_EW$psa[21]  
  xx$T0_075S_EW  <-  rsp_EW$psa[22]  
  xx$T0_080S_EW  <-  rsp_EW$psa[23]  
  xx$T0_085S_EW  <-  rsp_EW$psa[24]  
  xx$T0_090S_EW  <-  rsp_EW$psa[25]  
  xx$T0_095S_EW  <-  rsp_EW$psa[26]  
  xx$T0_100S_EW  <-  rsp_EW$psa[27]  
  xx$T0_110S_EW  <-  rsp_EW$psa[28]  
  xx$T0_120S_EW  <-  rsp_EW$psa[29]  
  xx$T0_130S_EW  <-  rsp_EW$psa[30]  
  xx$T0_133S_EW  <-  rsp_EW$psa[31]  
  xx$T0_140S_EW  <-  rsp_EW$psa[32]  
  xx$T0_150S_EW  <-  rsp_EW$psa[33]  
  xx$T0_160S_EW  <-  rsp_EW$psa[34]  
  xx$T0_170S_EW  <-  rsp_EW$psa[35]  
  xx$T0_180S_EW  <-  rsp_EW$psa[36]  
  xx$T0_190S_EW  <-  rsp_EW$psa[37]  
  xx$T0_200S_EW  <-  rsp_EW$psa[38]  
  xx$T0_220S_EW  <-  rsp_EW$psa[39]  
  xx$T0_240S_EW  <-  rsp_EW$psa[40]  
  xx$T0_250S_EW  <-  rsp_EW$psa[41]  
  xx$T0_260S_EW  <-  rsp_EW$psa[42]  
  xx$T0_280S_EW  <-  rsp_EW$psa[43]  
  xx$T0_290S_EW  <-  rsp_EW$psa[44]  
  xx$T0_300S_EW  <-  rsp_EW$psa[45]  
  xx$T0_320S_EW  <-  rsp_EW$psa[46]  
  xx$T0_340S_EW  <-  rsp_EW$psa[47]  
  xx$T0_350S_EW  <-  rsp_EW$psa[48]  
  xx$T0_360S_EW  <-  rsp_EW$psa[49]  
  xx$T0_380S_EW  <-  rsp_EW$psa[50]  
  xx$T0_400S_EW  <-  rsp_EW$psa[51]  
  xx$T0_420S_EW  <-  rsp_EW$psa[52]  
  xx$T0_440S_EW  <-  rsp_EW$psa[53]  
  xx$T0_450S_EW  <-  rsp_EW$psa[54]  
  xx$T0_460S_EW  <-  rsp_EW$psa[55]  
  xx$T0_480S_EW  <-  rsp_EW$psa[56]  
  xx$T0_500S_EW  <-  rsp_EW$psa[57]  
  xx$T0_550S_EW  <-  rsp_EW$psa[58]  
  xx$T0_600S_EW  <-  rsp_EW$psa[59]  
  xx$T0_650S_EW  <-  rsp_EW$psa[60]  
  xx$T0_667S_EW  <-  rsp_EW$psa[61]  
  xx$T0_700S_EW  <-  rsp_EW$psa[62]  
  xx$T0_750S_EW  <-  rsp_EW$psa[63]  
  xx$T0_800S_EW  <-  rsp_EW$psa[64]  
  xx$T0_850S_EW  <-  rsp_EW$psa[65]  
  xx$T0_900S_EW  <-  rsp_EW$psa[66]  
  xx$T0_950S_EW  <-  rsp_EW$psa[67]  
  xx$T1_000S_EW  <-  rsp_EW$psa[68]  
  xx$T1_100S_EW  <-  rsp_EW$psa[69]  
  xx$T1_200S_EW  <-  rsp_EW$psa[70]  
  xx$T1_300S_EW  <-  rsp_EW$psa[71]  
  xx$T1_400S_EW  <-  rsp_EW$psa[72]  
  xx$T1_500S_EW  <-  rsp_EW$psa[73]  
  xx$T1_600S_EW  <-  rsp_EW$psa[74]  
  xx$T1_700S_EW  <-  rsp_EW$psa[75]  
  xx$T1_800S_EW  <-  rsp_EW$psa[76]  
  xx$T1_900S_EW  <-  rsp_EW$psa[77]  
  xx$T2_000S_EW  <-  rsp_EW$psa[78]  
  xx$T2_200S_EW  <-  rsp_EW$psa[79]  
  xx$T2_400S_EW  <-  rsp_EW$psa[80]  
  xx$T2_500S_EW  <-  rsp_EW$psa[81]  
  xx$T2_600S_EW  <-  rsp_EW$psa[82]  
  xx$T2_800S_EW  <-  rsp_EW$psa[83]  
  xx$T3_000S_EW  <-  rsp_EW$psa[84]  
  xx$T3_200S_EW  <-  rsp_EW$psa[85]  
  xx$T3_400S_EW  <-  rsp_EW$psa[86]  
  xx$T3_500S_EW  <-  rsp_EW$psa[87]  
  xx$T3_600S_EW  <-  rsp_EW$psa[88]  
  xx$T3_800S_EW  <-  rsp_EW$psa[89]  
  xx$T4_000S_EW  <-  rsp_EW$psa[90]  
  xx$T4_200S_EW  <-  rsp_EW$psa[91]  
  xx$T4_400S_EW  <-  rsp_EW$psa[92]  
  xx$T4_600S_EW  <-  rsp_EW$psa[93]  
  xx$T4_800S_EW  <-  rsp_EW$psa[94]  
  xx$T5_000S_EW  <-  rsp_EW$psa[95]  
  xx$T5_500S_EW  <-  rsp_EW$psa[96]  
  xx$T6_000S_EW  <-  rsp_EW$psa[97]  
  xx$T6_500S_EW  <-  rsp_EW$psa[98]  
  xx$T7_000S_EW  <-  rsp_EW$psa[99]  
  xx$T7_500S_EW  <-  rsp_EW$psa[100]  
  xx$T8_000S_EW  <-  rsp_EW$psa[101]  
  xx$T8_500S_EW  <-  rsp_EW$psa[105]  
  xx$T9_000S_EW  <-  rsp_EW$psa[103]  
  xx$T9_500S_EW  <-  rsp_EW$psa[104]  
  xx$T10_000S_EW <-  rsp_EW$psa[105]
  
  xx$T0_010S <- sqrt(rsp_NS$psa[1]*rsp_EW$psa[1])
  xx$T0_020S <- sqrt(rsp_NS$psa[2]*rsp_EW$psa[2])  
  xx$T0_022S <- sqrt(rsp_NS$psa[3]*rsp_EW$psa[3])  
  xx$T0_025S <- sqrt(rsp_NS$psa[4]*rsp_EW$psa[4])  
  xx$T0_029S <- sqrt(rsp_NS$psa[5]*rsp_EW$psa[5])  
  xx$T0_030S <- sqrt(rsp_NS$psa[6]*rsp_EW$psa[6])  
  xx$T0_032S <- sqrt(rsp_NS$psa[7]*rsp_EW$psa[7])  
  xx$T0_035S <- sqrt(rsp_NS$psa[8]*rsp_EW$psa[8])   
  xx$T0_036S <- sqrt(rsp_NS$psa[9]*rsp_EW$psa[9])  
  xx$T0_040S <- sqrt(rsp_NS$psa[10]*rsp_EW$psa[10])  
  xx$T0_042S <- sqrt(rsp_NS$psa[11]*rsp_EW$psa[11])  
  xx$T0_044S <- sqrt(rsp_NS$psa[12]*rsp_EW$psa[12])  
  xx$T0_045S <- sqrt(rsp_NS$psa[13]*rsp_EW$psa[13])  
  xx$T0_046S <- sqrt(rsp_NS$psa[14]*rsp_EW$psa[14])  
  xx$T0_048S <- sqrt(rsp_NS$psa[15]*rsp_EW$psa[15])  
  xx$T0_050S <- sqrt(rsp_NS$psa[16]*rsp_EW$psa[16])  
  xx$T0_055S <- sqrt(rsp_NS$psa[17]*rsp_EW$psa[17])  
  xx$T0_060S <- sqrt(rsp_NS$psa[18]*rsp_EW$psa[18])
  xx$T0_065S <- sqrt(rsp_NS$psa[19]*rsp_EW$psa[19])  
  xx$T0_067S <- sqrt(rsp_NS$psa[20]*rsp_EW$psa[20])  
  xx$T0_070S <- sqrt(rsp_NS$psa[21]*rsp_EW$psa[21])  
  xx$T0_075S <- sqrt(rsp_NS$psa[22]*rsp_EW$psa[22])  
  xx$T0_080S <- sqrt(rsp_NS$psa[23]*rsp_EW$psa[23])  
  xx$T0_085S <- sqrt(rsp_NS$psa[24]*rsp_EW$psa[24])  
  xx$T0_090S <- sqrt(rsp_NS$psa[25]*rsp_EW$psa[25])  
  xx$T0_095S <- sqrt(rsp_NS$psa[26]*rsp_EW$psa[26])  
  xx$T0_100S <- sqrt(rsp_NS$psa[27]*rsp_EW$psa[27])  
  xx$T0_110S <- sqrt(rsp_NS$psa[28]*rsp_EW$psa[28])  
  xx$T0_120S <- sqrt(rsp_NS$psa[29]*rsp_EW$psa[29])  
  xx$T0_130S <- sqrt(rsp_NS$psa[30]*rsp_EW$psa[30])  
  xx$T0_133S <- sqrt(rsp_NS$psa[31]*rsp_EW$psa[31])  
  xx$T0_140S <- sqrt(rsp_NS$psa[32]*rsp_EW$psa[32])
  xx$T0_150S <- sqrt(rsp_NS$psa[33]*rsp_EW$psa[33])  
  xx$T0_160S <- sqrt(rsp_NS$psa[34]*rsp_EW$psa[34])  
  xx$T0_170S <- sqrt(rsp_NS$psa[35]*rsp_EW$psa[35])  
  xx$T0_180S <- sqrt(rsp_NS$psa[36]*rsp_EW$psa[36])  
  xx$T0_190S <- sqrt(rsp_NS$psa[37]*rsp_EW$psa[37])  
  xx$T0_200S <- sqrt(rsp_NS$psa[38]*rsp_EW$psa[38])  
  xx$T0_220S <- sqrt(rsp_NS$psa[39]*rsp_EW$psa[39])  
  xx$T0_240S <- sqrt(rsp_NS$psa[40]*rsp_EW$psa[40])  
  xx$T0_250S <- sqrt(rsp_NS$psa[41]*rsp_EW$psa[41])  
  xx$T0_260S <- sqrt(rsp_NS$psa[42]*rsp_EW$psa[42])  
  xx$T0_280S <- sqrt(rsp_NS$psa[43]*rsp_EW$psa[43])  
  xx$T0_290S <- sqrt(rsp_NS$psa[44]*rsp_EW$psa[44])  
  xx$T0_300S <- sqrt(rsp_NS$psa[45]*rsp_EW$psa[45])  
  xx$T0_320S <- sqrt(rsp_NS$psa[46]*rsp_EW$psa[46])  
  xx$T0_340S <- sqrt(rsp_NS$psa[47]*rsp_EW$psa[47])  
  xx$T0_350S <- sqrt(rsp_NS$psa[48]*rsp_EW$psa[48])  
  xx$T0_360S <- sqrt(rsp_NS$psa[49]*rsp_EW$psa[49])  
  xx$T0_380S <- sqrt(rsp_NS$psa[50]*rsp_EW$psa[50])  
  xx$T0_400S <- sqrt(rsp_NS$psa[51]*rsp_EW$psa[51])  
  xx$T0_420S <- sqrt(rsp_NS$psa[52]*rsp_EW$psa[52])  
  xx$T0_440S <- sqrt(rsp_NS$psa[53]*rsp_EW$psa[53])  
  xx$T0_450S <- sqrt(rsp_NS$psa[54]*rsp_EW$psa[54])  
  xx$T0_460S <- sqrt(rsp_NS$psa[55]*rsp_EW$psa[55])  
  xx$T0_480S <- sqrt(rsp_NS$psa[56]*rsp_EW$psa[56])  
  xx$T0_500S <- sqrt(rsp_NS$psa[57]*rsp_EW$psa[57])
  xx$T0_550S <- sqrt(rsp_NS$psa[58]*rsp_EW$psa[58])  
  xx$T0_600S <- sqrt(rsp_NS$psa[59]*rsp_EW$psa[59])  
  xx$T0_650S <- sqrt(rsp_NS$psa[60]*rsp_EW$psa[60])  
  xx$T0_667S <- sqrt(rsp_NS$psa[61]*rsp_EW$psa[61])  
  xx$T0_700S <- sqrt(rsp_NS$psa[62]*rsp_EW$psa[62])  
  xx$T0_750S <- sqrt(rsp_NS$psa[63]*rsp_EW$psa[63])  
  xx$T0_800S <- sqrt(rsp_NS$psa[64]*rsp_EW$psa[64])  
  xx$T0_850S <- sqrt(rsp_NS$psa[65]*rsp_EW$psa[65])  
  xx$T0_900S <- sqrt(rsp_NS$psa[66]*rsp_EW$psa[66])  
  xx$T0_950S <- sqrt(rsp_NS$psa[67]*rsp_EW$psa[67])  
  xx$T1_000S <- sqrt(rsp_NS$psa[68]*rsp_EW$psa[68])  
  xx$T1_100S <- sqrt(rsp_NS$psa[69]*rsp_EW$psa[69])  
  xx$T1_200S <- sqrt(rsp_NS$psa[70]*rsp_EW$psa[70])  
  xx$T1_300S <- sqrt(rsp_NS$psa[71]*rsp_EW$psa[71])  
  xx$T1_400S <- sqrt(rsp_NS$psa[72]*rsp_EW$psa[72])  
  xx$T1_500S <- sqrt(rsp_NS$psa[73]*rsp_EW$psa[73])  
  xx$T1_600S <- sqrt(rsp_NS$psa[74]*rsp_EW$psa[74])  
  xx$T1_700S <- sqrt(rsp_NS$psa[75]*rsp_EW$psa[75])  
  xx$T1_800S <- sqrt(rsp_NS$psa[76]*rsp_EW$psa[76])  
  xx$T1_900S <- sqrt(rsp_NS$psa[77]*rsp_EW$psa[77])  
  xx$T2_000S <- sqrt(rsp_NS$psa[78]*rsp_EW$psa[78])  
  xx$T2_200S <- sqrt(rsp_NS$psa[79]*rsp_EW$psa[79])  
  xx$T2_400S <- sqrt(rsp_NS$psa[80]*rsp_EW$psa[80])  
  xx$T2_500S <- sqrt(rsp_NS$psa[81]*rsp_EW$psa[81])  
  xx$T2_600S <- sqrt(rsp_NS$psa[82]*rsp_EW$psa[82])  
  xx$T2_800S <- sqrt(rsp_NS$psa[83]*rsp_EW$psa[83])  
  xx$T3_000S <- sqrt(rsp_NS$psa[84]*rsp_EW$psa[84])  
  xx$T3_200S <- sqrt(rsp_NS$psa[85]*rsp_EW$psa[85])  
  xx$T3_400S <- sqrt(rsp_NS$psa[86]*rsp_EW$psa[86])  
  xx$T3_500S <- sqrt(rsp_NS$psa[87]*rsp_EW$psa[87])
  xx$T3_600S <- sqrt(rsp_NS$psa[88]*rsp_EW$psa[88])  
  xx$T3_800S <- sqrt(rsp_NS$psa[89]*rsp_EW$psa[89])  
  xx$T4_000S <- sqrt(rsp_NS$psa[90]*rsp_EW$psa[90])  
  xx$T4_200S <- sqrt(rsp_NS$psa[91]*rsp_EW$psa[91])  
  xx$T4_400S <- sqrt(rsp_NS$psa[92]*rsp_EW$psa[92])  
  xx$T4_600S <- sqrt(rsp_NS$psa[93]*rsp_EW$psa[93])  
  xx$T4_800S <- sqrt(rsp_NS$psa[94]*rsp_EW$psa[94])  
  xx$T5_000S <- sqrt(rsp_NS$psa[95]*rsp_EW$psa[95])  
  xx$T5_500S <- sqrt(rsp_NS$psa[96]*rsp_EW$psa[96])  
  xx$T6_000S <- sqrt(rsp_NS$psa[97]*rsp_EW$psa[97])  
  xx$T6_500S <- sqrt(rsp_NS$psa[98]*rsp_EW$psa[98])   
  xx$T7_000S <- sqrt(rsp_NS$psa[99]*rsp_EW$psa[99])   
  xx$T7_500S <- sqrt(rsp_NS$psa[100]*rsp_EW$psa[100])    
  xx$T8_000S <- sqrt(rsp_NS$psa[101]*rsp_EW$psa[101])    
  xx$T8_500S <- sqrt(rsp_NS$psa[102]*rsp_EW$psa[102])    
  xx$T9_000S <- sqrt(rsp_NS$psa[103]*rsp_EW$psa[103])    
  xx$T9_500S <- sqrt(rsp_NS$psa[104]*rsp_EW$psa[104])    
  xx$T10_000S <- sqrt(rsp_NS$psa[105]*rsp_EW$psa[105])  
  
  xx$author     <-    "stella"  
  xx
}

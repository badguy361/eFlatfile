#---------------------------------
#  Write SGM to file
#
#---------------------------------

Write_to_file <- function(SGM_ID,EQ_ID,Year,Month,Day,Hour,Minute,Sec,Lon,Lat,Depth,ML,Distance,Hypo,
                          STA_ID,DT,npts,Instrument_type,PGA_V,PGA_NS,PGA_EW,PGV_V,PGV_NS,PGV_EW,
                          PGD_V,PGD_NS,PGD_EW,HP_V,HP_NS,HP_EW,LP_V,LP_NS,LP_EW,author,Z,NS,EW,SGM_SN){
  path1 <- paste("/app/filter/3-Filtering/PROCESS_FILE/",Year,sep="")
  path2 <- paste("/app/filter/3-Filtering/PROCESS_FILE/",Year,"/",EQ_ID,sep="")
  path3 <- paste("/app/filter/3-Filtering/PROCESS_FILE/",Year,"/",EQ_ID,"/ACC",sep="")
  
  ifelse(file.exists(path1),paste("file exit!"),dir.create(path1))
  ifelse(file.exists(path2),paste("file exit!"),dir.create(path2))
  ifelse(file.exists(path3),paste("file exit!"),dir.create(path3))
  
  filename <- paste(path3,"/",SGM_ID,".ACC", sep="")

  Z.md5 <- digest(paste(Z,collapse =","), serialize=FALSE)
  NS.md5 <- digest(paste(NS,collapse =","), serialize=FALSE)
  EW.md5 <- digest(paste(EW,collapse =","), serialize=FALSE)
  md5s <- digest(paste(Z.md5, NS.md5, EW.md5, sep=""), serialize=FALSE)
  
  write(paste("Station Name                 :",STA_ID),filename)
  write(paste("Instrument Type              :",Instrument_type),filename,append=TRUE)
  write(paste("Processing DateTime          :",format(Sys.time(),"%Y/%m/%d %X %Z")),filename,append=TRUE)
  write(paste("Recording Time               : ",Year,"/",formatC(Month, width=2, flag="0"),"/",formatC(Day, width=2, flag="0"),
            " ",formatC(Hour, width=2, flag="0"),":",formatC(Minute, width=2, flag="0"),":",Sec," UT",sep=""),filename,append=TRUE)
  write(paste("Sampling Interval (DT)       :",DT),filename,append=TRUE)
  write(paste("Data Set Number (NP)         :",npts),filename,append=TRUE)
  write(paste("Earthquake Location          :",round(Lon,digits=4),"E,",round(Lat,digits=4),"N, Depth=",Depth,"KM"),filename,append=TRUE)
  write(paste("Magnitude ML                 :",ML),filename,append=TRUE)
  write(paste("Epicenter Distance           :",Distance,"KM"),filename,append=TRUE)
  write(paste("Hypocenter Distance          :",round(Hypo,digits=3),"KM"),filename,append=TRUE)
  write(paste("Acceleration Unit            : CM/SEC/SEC"),filename,append=TRUE)
  write(paste("Filter Low cut Z NS EW (Hz)  :",HP_V,HP_NS,HP_EW,sep=" "),filename,append=TRUE)
  write(paste("Filter High cut Z NS EW (Hz) :",LP_V,LP_NS,LP_EW,sep=" "),filename,append=TRUE)
  write(paste("PGA Z NS EW (gal)            :",round(PGA_V*981,digits=2),round(PGA_NS*981,digits=2),round(PGA_EW*981,digits=2),sep=" "),filename,append=TRUE)
  write(paste("PGV Z NS EW (cm/s)           :",round(PGV_V*981,digits=2),round(PGV_NS*981,digits=2),round(PGV_EW*981,digits=2),sep=" "),filename,append=TRUE)
  write(paste("PGD Z NS EW (cm)             :",round(PGD_V*981,digits=2),round(PGD_NS*981,digits=2),round(PGD_EW*981,digits=2),sep=" "),filename,append=TRUE)
  write(paste("ACC Header"))
  
  #write(cbind(ACC.Z, ACC.NS, ACC.EW), filename,append = TRUE)
  x <- (seq(1:npts)*DT)-DT
  acc <- data.frame(t=x,v=Z*978.88,h1=NS*978.88,h2=EW*978.88)
  acc.fmt <- c("    T(SEC)    Z-COM     NS-COM   EW-COM",sprintf("%10.3f%10.3f%10.3f%10.3f",acc$t,acc$v,acc$h1,acc$h2))
  write.table(acc.fmt, filename,row.names=FALSE,col.names=FALSE, quote=FALSE, append=TRUE)
  md5s
}
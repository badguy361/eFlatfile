#---------------------------------
#  Write data to file
#
#---------------------------------

#寫出VEL.DIS資料
Write_data <- function(file.target,SGM_ID,Z,NS,EW,npts,DT){
  x <- (seq(1:npts)*DT)-DT
  datat <- data.frame(t=x,v=Z*978.88,h1=NS*978.88,h2=EW*978.88)
  datat.fmt <- c("    T(SEC)    Z-COM     NS-COM   EW-COM",sprintf("%13.3f%13.3f%13.3f%13.3f",datat$t,datat$v,datat$h1,datat$h2))
  write.table(datat.fmt, file.target,row.names=FALSE,col.names=FALSE, quote=FALSE, append=FALSE)

}

#寫出反應譜資料
Write_rsp_data <- function(file.target,SGM_ID,PSA_V,PSA_NS,PSA_EW,PSV_V,PSV_NS,PSV_EW,Period){
  datat <- data.frame(t=Period,h1=PSA_V,h2=PSA_NS,h3=PSA_EW,h4=PSV_V,h5=PSV_NS,h6=PSV_EW)
  datat.fmt <- c(" PERIOD(SEC)     RSA-Z       RSA-NS        RSA-EW         RSV-Z          RSV-NS          RSV-EW",
                 sprintf("%10.3f%15.5E%15.5E%15.5E%15.5E%15.5E%15.5E",datat$t,datat$h1,datat$h2,datat$h3,datat$h4,datat$h5,datat$h6))
  write.table(datat.fmt, file.target,row.names=FALSE,col.names=FALSE, quote=FALSE)
  
}
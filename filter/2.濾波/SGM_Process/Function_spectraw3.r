# 2011/10 Brian???Ѫ??s??,��?Ӥ??|???ø??ʪ????ΦA?o??

spectraw2 <- function(acc, damping, pdata="") 
{
	period.dat <- scan("SGM_Process/period.dat", skip=1)
	period.dat <- sort(period.dat)
#
#... Checking the input time series
#
	if(!is.ts(acc)) stop("Input array is not a regular time history") 
	# is.ts() check the data is time series or not
#		
#... Extract time-series paramters
#
  dt <- deltat(acc)   # return time interval ?ɶ????jdt
	npts <- length(acc) # npts ?????I?ƶq
#
#... Create arrays to be used as the arguments to subroutine 'rsp'
# 		when prd <= 10*dt, the dimension of these output arrays (aa,rv,rd) must be large enough to handle the 
#  		increased sampling rate. As a result of the denser resampling, argument dt will also be modified by subroutine 'rsp'.
#
	   npts1 <- npts * (as.integer(10*dt/min(period.dat))+3) 
	   aa <- numeric(npts1)
	   rv <- numeric(npts1)
	   rd <- numeric(npts1)       
	   ax <- as.double(acc)
     pr <- as.double(period.dat)
     npr <- length(pr)
     z  <- matrix(0.0, ncol=npr,nrow=3)

##	
## In this version, subroutine 'rsp' computes and returns spectra at multiple periods; 
#     this version of rsp does not return response time series to avoid the large size of the returned arrays.
#  In an earlier version, 'sapply' was used (in lieu of a do-loop) to compute spectra one period at a time. It 
#     sometimes behaves erratically (returning unreasonably large value), which I thought may be due to the use of 'sapply'.
#     With the revised code, the reutnred spectral values seem to be less frquently unstable.  
## 	
	if (!is.loaded('rsp')) dyn.load("SGM_Process/dll/rsp_new.dll")
 	# dyn.load() : Load or unload DLLs (also known as shared objects), and test whether a C function or Fortran subroutine is available.
#  tmp <- .Fortran("rsp", as.integer(npts), as.double(ax), as.integer(npr), as.double(pr), as.double(damping), as.double(dt),
#						    				 as.double(z) #, as.double(rd), as.double(rv), as.double(aa)
  returned.data <- .Fortran("rsp", npts=as.integer(npts), ax=ax, npr=as.integer(npr), pr=pr, damping=as.double(damping), 
                                   dt=as.double(dt), z=z #, rd, rv, aa
                           )				
	
  if (is.loaded('rsp')) dyn.unload("SGM_Process/dll/rsp_new.dll")
  
	rsp <- data.frame(Period=period.dat, t(matrix(returned.data$z, ncol=npr, nrow=3)))
	names(rsp) <- c("Period", "sd","sv","aa")
	rsp$psv <- rsp$sd *  (2*pi/rsp$Period)
	rsp$psa <- rsp$psv * (2*pi/rsp$Period)

# 	if (pdata!='') {
# 		y <- rsp[,pdata]
# 		yrange <- range(y)
# 		yrange[1] <- 10^(floor(log10(yrange[1])))
# 		yrange[2] <- 10^(ceiling(log10(yrange[2])))
# 		x <- rsp$Period
# 		xrange <- range(x)
# 		PlotIt1(xrange, yrange, log='xy', type='n', xaxs='i', col='red', 
#           ylab=casefold(paste(pdata), upper=T), xlab='Period (sec)', lwd=2, xpower=F, ypower=T, xgrid=T, ygrid=T)
#     lines(x, y, col='blue', lwd=2)
# 	}
	rsp
}


plot_spectra <- function(rsp,pdata){
  if(pdata=='') stop("Please input spectra type (psa, psv, sd)")
	y <- rsp[,pdata]
	yrange <- range(y)
	yrange[1] <- 10^(floor(log10(yrange[1])))
	yrange[2] <- 10^(ceiling(log10(yrange[2])))
	x <- rsp$Period
	xrange <- range(x)
	plot(xrange, yrange, log='xy', type='n', ylab=casefold(paste(pdata), upper=T), xlab='Period (sec)')
	lines(x, y, lwd=2)
	xtck <- c(array(outer(1:9, c(0.01,0.1,1.0))),10)
	abline(v=xtck, col=8, lty=2)
	ytck <- log10(yrange)
	ytck <- 10^(seq(ytck[1], ytck[2]))
  abline(h=ytck, col=8, lty=2) 
}

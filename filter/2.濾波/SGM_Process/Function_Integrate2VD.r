#--------------------------------------
#¿n¤À¨ç¼Æ
integrate2V <- function(a) {
#  a<- accts
	if(!is.ts(a)) stop("Input array is not a regular time history")
	dt <- 1/tsp(a)[3] # The tsp() attribute gives the start time in time units, the end time and the frequency
	npts <- length(a)
	a1 <- array(a[1:(npts-1)])
	a2 <- array(a[2:npts])
	v <- cumsum((a1 + a2)*dt*0.5)
	v <- c(0, v)
	ts(data=v, deltat=dt, start=start(a)) # ts() : create time series
}

integrate2D <- function(v) {
	if(!is.ts(v)) stop("Input array is not a regular time history")
	dt <- 1/tsp(v)[3]
	npts <- length(v)
	v1 <- array(v[1:(npts-1)])
	v2 <- array(v[2:npts])
	d <- cumsum((v1 + v2)*dt*0.5)
	d <- c(0, d)
	ts(data=d, deltat=dt, start=start(v))
}


# From Brian Chiou's S-Plus Code
#integrate2V <- function(a) {
#	if(!is.rts(a)) stop("Input array is not a regular time history")
#	dt <- tspar(a)[2]
#	npts <- length(a)
#	a1 <- array(a[1:(npts-1)])
#	a2 <- array(a[2:npts])
#	v <- cumsum((a1 + a2)*dt*0.5)
#	v <- c(0, v)
#	rts(x=v, deltat=dt, start=start(a))
#}
#
#integrate2D <- function(a, v) {
#	if(!is.rts(a)) stop("Input acc is not a regular time history")
#	if(!is.rts(v)) stop("Input vel is not a regular time history")
#	dt <- tspar(a)[2]
#	if (tspar(v)[2] != dt) stop ("Input vel does not have the same dt")
#	npts <- length(a)
#	if (length(v) != npts) stop ("Input vel does not have the same lenght")
#	a1 <- array(a[1:(npts-1)])
#	a2 <- array(a[2:npts])
#	v1 <- array(v[1:(npts-1)])
#	d <- cumsum((v1 + dt * (a1/3.0 + a2/6.0))*dt)
#	d <- c(0, d)
#	rts(x=d, deltat=dt, start=start(a))
#}

intgflt <- function(acc, integrate = T, nlp = 0, fclp = 0, nhp = 0, fchp = 0)
{
	## Intregrae and/or fliter a time history;
	## Default to integration.
	## Retrieve ts paramters
	if(!is.rts(acc)) stop("Input array is not a regular time history")
	deltat <- tspar(acc)[2]
	npts <- length(acc)
	acc <- acc
	## Remove DC
	acc <- acc - mean(acc)
	## Foward FFT
	acc <- fft(acc)
	## Filter
	if(nlp > 0) {
		lp <- lpass(npts, deltat, fclp, nlp)
		acc[1:(npts/2 + 1)] <- acc[1:(npts/2 + 1)] * lp
	}
	## Filter
	if(nhp > 0) {
		hp <- hpass(npts, deltat, fchp, nhp)
		acc[1:(npts/2 + 1)] <- acc[1:(npts/2 + 1)] * hp
	}
	## Integrate
	if(integrate) {
		acc[2:npts] <- acc[2:npts]/complex(imaginary = (-2. * pi * (2:npts) - 1)/(npts * deltat))
	}
	acc[1] <- 0
	## Folding
	acc[1] <- complex(real = Re(acc[1]), imaginary = 0)
	acc[npts/2 + 1] <- complex(real = Re(acc[npts/2 + 1]), imaginary = 0)
	acc[npts + 2 - (2:(npts/2))] <- Conj(acc[2:(npts/2)])
	## Inverse FFT
	rts(x = Re(fft(acc, inverse = T))/npts, deltat = deltat, start=start(acc))
}

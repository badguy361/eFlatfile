###
hpassButterworth <- function(npts, deltat, hfc, n){
	deltaf <- 1.0/(deltat*npts)
	domega <- deltaf/hfc
	omega <- rep(0,npts/2+1)
	omega <- (seq(1:(npts/2+1))-1)*domega
	hp <- sqrt(omega^(2*n)/(1.0+omega^(2*n)))
	hp
}

lpassButterworth <- function(npts, deltat, lfc, n){
	deltaf <- 1.0/(deltat*npts)
	domega <- deltaf/lfc
	omega <- rep(0,npts/2+1)
	omega <- (seq(1:(npts/2+1))-1)*domega
	lp <- sqrt(1.0/(1.0+omega^(2*n)))
	lp
}

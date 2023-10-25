#--------------------------------------
# Ia Arias Intensity ¿n¤À¨ç¼Æ
integrateAI <- function(a) {
#  a<- accts1
  if(!is.ts(a)) stop("Input array is not a regular time history")
	dt <- 1/tsp(a)[3]
	npts <- length(a)
	a1 <- array(a[1:(npts-1)])
	a2 <- array(a[2:npts])
	v <- sum((a1 + a2)*dt*0.5)
	ia <- 3.1415926/19.6*v
  ia
}
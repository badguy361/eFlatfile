BslnAdj <- function(accts, nTaper, nSkip, nAdd) {
  
  npts <- length(accts)
  dt <- deltat(accts)
  start.time <- 0.0
  
  #		1. Integrate uncorrected acc to velocity & displacement;
  #		2. Pad zeros to improve stability of baseline estimation
  #		3. Estimate baseline of displacement record
  
  #... 1. Integrate (by time-domain integration) to Vel. and Dis.
  
  velts <- integrate2V(accts)
  dists <- integrate2D(velts)	
  
  #... 2. Skip the first nSkip points and append nAdd points 
  xx <- c(dists, rep(dists[npts], nAdd))  # rep( [ 指定的向量 ], [使之重複的次數]) 
  xx <- xx[-(1:nSkip)]
  
  #... 3. Estimate polynomial baseline
  yy <- dt * ((1:length(xx))-1)	
  ypol <-  cbind(yy^2, yy^3, yy^4, yy^5, yy^6) 
  bl <- lm(xx ~ ypol - 1)
  
  # Baseline
  b.dis <- ypol %*% coef(bl)
  b.vel <- (cbind(yy, ypol[,1:4])    %*% (coef(bl)*(2:6)))
  b.acc <- (cbind(1, yy, ypol[,1:3]) %*% (coef(bl)*(2:6)*(1:5)))
  
  b.dis <- c(rep(0,nSkip), b.dis)[1:npts]
  b.vel <- c(rep(0,nSkip), b.vel)[1:npts]
  b.acc <- c(rep(0,nSkip), b.acc)[1:npts]	
  
  # End taper
  w <- numeric(npts)
  w <- w + 1.0
  w.vel <- numeric(npts) 
  w.acc <- numeric(npts) 
  if (nTaper > 0) {
    w[(npts-nTaper+1):npts]     <- sapply(1:nTaper, function(i, ne)     { ( 1.0 + cos(pi*(i-1)/ne))*0.5}, ne=nTaper)
    w.vel[(npts-nTaper+1):npts] <- sapply(1:nTaper, function(i, ne, dt) { (sin(pi*(i-1)/ne))*(pi/ne/dt)*(-0.5)}, ne=nTaper, dt=dt)	
    w.acc[(npts-nTaper+1):npts] <- sapply(1:nTaper, function(i, ne, dt) { (cos(pi*(i-1)/ne))*(pi/ne/dt)^2*(-0.5)}, ne=nTaper, dt=dt)
  }
  # Remove baseline and apply taper
  accts <- (accts - b.acc)*w + 2.0 * (velts - b.vel)*w.vel + (dists - b.dis)*w.acc
  accts <- ts(accts, deltat=dt, start=start.time)
}


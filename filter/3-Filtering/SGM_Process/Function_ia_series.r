#-------------------------------------------------------------------------------
# Program Name: Ia_series
# Description: read RSPMatch input/output acceleration file .acc
# Date: 2014/10/01
# Author: Bowmei
#
#-------------------------------------------------------------------------------

#' Calculate Arias Intensity time series
#'
#' \code{Ia.series} returns Arias Intensity time series of a acceleration Time-series object.
#'
#' @param a Acceleration(g) time-series(ts) objest.
#'
#' @return A time-series(ts) objest of Arias Intensity.
#'
#' @examples
#' Ia.series(CHY080.E)
#'
#' @export
Ia.series <- function(a) {
  #  a<- acc
  if(!is.ts(a)) stop("Input array is not a regular time history")
  dt <- 1/tsp(a)[3]
  npts <- length(a)
  a <- a*9.81       #convert to m/sec
  a <- a**2
  a1 <- array(c(0,a[1:(npts-1)]))
  #  a1 <- array(a[1:(npts-1)])
  #  a2 <- array(a[2:npts])
  a2 <- array(a[1:npts])
  seg <- (a1 + a2)*dt*0.5
  vcum <-  cumsum(seg)
  #  v <- sum((a0 + a2)*dt*0.5)
  ia <- 3.1415926/19.6*vcum
  max(ia)
  #  iaValue <- 3.1415926/19.6*v
  #  iaValue
  ia <- ts(ia, deltat=dt)
  return(ia)
}

#' Calculate Arias Intensity
#'
#' \code{Ia} returns Arias Intensity value of a acceleration Time-series object.
#'
#' @param a Acceleration(g) time-series(ts) objest.
#'
#' @return Arias Intensity value of a acceleration time series.
#'
#' @examples
#' Ia(CHY080.E)
#'
#' @export
Ia <- function(a) {
  #  a<- acc
  if(!is.ts(a)) stop("Input array is not a regular time history")
  dt <- 1/tsp(a)[3]
  npts <- length(a)
  a <- a*9.81       #convert to m/sec
  a <- a**2
  a1 <- array(c(0,a[1:(npts-1)]))
  #  a1 <- array(a[1:(npts-1)])
  #  a2 <- array(a[2:npts])
  a2 <- array(a[1:npts])
  #  seg <- (a1 + a2)*dt*0.5
  #  vcum <-  cumsum(seg)
  v <- sum((a1 + a2)*dt*0.5)
  #  ia <- 3.1415926/19.6*vcum
  #  max(ia)
  iaValue <- 3.1415926/19.6*v
  iaValue
  return(iaValue)
}

#' Calculate duration time base on Arias Intensity.
#'
#' \code{Ia.duration.time} returns duration time of acceleration Time-series object.
#'
#' @param a Acceleration time-series(ts) objest.
#' @param Ia.low Percentage of Arias Intensity value for the starting time of calculation of duration time.
#' @param Ia.high Percentage of Arias Intensity value for the ending time of calculation of duration time
#'
#' @return A duration time(sec) of a acceleration time series.
#'
#' @examples
#' Ia.duration.time(CHY080.E, Ia.low = 0.05, Ia.high = 0.75)
#'
#' @export
Ia.duration.time <- function(a, Ia.low = 0.05, Ia.high = 0.75){
  if(!is.ts(a)) stop("Input array is not a regular time history")
  a.Ia.series <- Ia.series(a)
  a.Ia <- Ia(a)
  a.Ia.ratio <- a.Ia.series/a.Ia
  dt <- 1/tsp(a)[3]
  duration <- (min(which(a.Ia.ratio > Ia.high)) - min(which(a.Ia.ratio > Ia.low)))*dt
  return(duration)
}

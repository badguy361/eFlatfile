# #
# Argv <- commandArgs(TRUE)
# initial.start <- Argv[1]
# end <- Argv[2]
# #
# print('HI')
# print(paste0('initial:  ',initial.start))
# print(paste0('end: ',end))

#
initial.start <- 791
end <- 1131

# RUN
# filter.frame <- read.csv(file="../4-Rrup/rec_FM_Vs30_Rrup.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# filter.frame$filter.id <- as.character(filter.frame$filter.id)
# filter.frame$rec.id <- as.character(filter.frame$rec.id)
# #
# fc.list <- read.table(file="previous result/filter_txt.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# names(fc.list)[1] <- "filter.id.old"
# fc.list <- fc.list[,c(1,2,4,5,18:23)]
# filter.frame2 <- merge(filter.frame,fc.list,by=c("rec.id"),all.x = TRUE,all.y=TRUE)
# write.table(filter.frame2,file="filter.frame2.csv",sep=",",col.names = TRUE,row.names = FALSE)

filter.frame <- read.csv(file="filter.frame2.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)

### LOAD Library
###
library(DBI)
library(RMySQL)
library(RMySQL)
library(foreign)
library(digest)
library(Cairo)
library(stringr)
library(RCTC)  # New! for calculating RotD50?€?...
library(RSEIS) # New! for applying "rsspec.taper()"
###
### LOAD Functions
###
source("SGM_Process/Function_Integrate2VD.r")    #ç©å?†å‡½?•¸?ž²
source("SGM_Process/Function_Integrate_Ia.r")    #Iaè¨ˆç??
source("SGM_Process/Function_spectraw3.r")       #è¨ˆç?—å?æ?‰è??
source("SGM_Process/Function_Baseline.r")        #?Ÿºç·šæ ¡æ­?
source("SGM_Process/Function_Butterworth.r")     #Butterworthæ¿¾æ³¢?‡½?•¸
source("SGM_Process/Function_write_DB.r")        #å¯«å…¥è³‡æ?™åº«
source("SGM_Process/Function_write_File.r")      #å¯«å…¥æª”æ??
source("SGM_Process/Function_write_data.r")      #å¯«è?‡æ??
#source("SGM_Process/Function_tcltk_mesgbox.r")  #?¸??–è?‡æ?™å?è³ªè¦–ç??
#source("SGM_Process/Function_Process.r")        #ä¸»ç?‹å??

# warning and error message
tmp <- data.frame(matrix(ncol = 4,nrow=0))
names(tmp) <- c("rec.id","Pfile","filter.ID","Error message")
warn <- err <- NULL

# 
source('2_filtering.R')

  for(i in initial.start:end){ 
    # i <- 1
    print(paste0("================= ",i," starts to run!"))

    filter.ID <- filter.frame$filter.id[i]
    rec.id <- filter.frame[which(filter.frame$filter.id==filter.ID),"rec.id"]
    File.name <- filter.frame[which(filter.frame$filter.id==filter.ID),"Pfile"]
    
    tryCatch({
      ProcessTH(filter.ID, "yang", Baseline=TRUE, PreBaseline=FALSE, Skip=0, Add=20, Taper=0, nDC=2000, tb=5, te=5, nPole=2.5)
    },
    warning = function(msg) {
      warn <<- conditionMessage(msg)
      tmp[1,] <- c(rec.id,File.name,filter.ID,warn)
      write.table(tmp,file="filtering_Warning_message.csv", append = T, sep=',', row.names=F,  col.names=F )
    },
    error = function(msg) {
      err <<- conditionMessage(msg)
      tmp[1,] <- c(rec.id,File.name,filter.ID,err)
      write.table(tmp,file="filtering_Error_message.csv", append = T, sep=',', row.names=F,  col.names=F )
    })
    graphics.off()
    
  }

  
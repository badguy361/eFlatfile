library(stringr)
# Pfile
load(file = "C:/Users/user/Desktop/Central/internship/2-consolidating/@P-file/P_file_1973_202012_new.Rdata")
`%!in%` = Negate(`%in%`)
sgm.2020 <- sgm.index[which(sgm.index$Year==2020),]
rm(sgm.index)

# ts file
path <- "C:/Users/user/Desktop/Central/internship/events_2020/"
DD <- list.files(path=path, pattern="^[0-9]")
CC <- c(11,12)
ts.frame <- setNames(data.frame(matrix(ncol = 5, nrow = 0)), c("ts_name", "Pfile", "P_arr_time","S_arr_time","Index"))

for (i in 1:length(DD)){
  # i <- 1
  path1 <- paste0(path,DD[i],"/")
  list.files <- list.files(path=path1, pattern="^[0-9]")
  ts.frame.tmp <- data.frame(ts_name=list.files,Pfile=NA,Sta=NA,P_arr_time=NA,S_arr_time=NA,Index=NA,stringsAsFactors = FALSE)
  # merge Pfile dataframe and ts_name
  for (j in 1:nrow(ts.frame.tmp)){
    # j <- 1
    FF <- ts.frame.tmp$ts_name[j]
    L1 <- readLines(file(paste0(path1,FF)),n=1)
    ts.frame.tmp$Pfile[j] <- str_sub(strsplit(FF,split='_')[[1]][3], end=-5)
    ts.frame.tmp$Sta[j] <- str_sub(strsplit(FF,split='_')[[1]][2])
    ts.frame.tmp$P_arr_time[j] <- strsplit(L1,split='\\s+')[[1]][2]
    ts.frame.tmp$S_arr_time[j] <- strsplit(L1,split='\\s+')[[1]][3]
    ts.frame.tmp$Index[j] <- strsplit(L1,split='\\s+')[[1]][4]
  }
  ts.frame <- rbind(ts.frame, ts.frame.tmp)
}
#
sgm.2020 <- merge(sgm.2020,ts.frame,by=c("Pfile"),all.x = TRUE,all.y = TRUE)
sgm.2020.BH <- sgm.2020[!is.na(sgm.2020$Index),]

write.table(sgm.2020,file="C:/Users/user/Desktop/Central/internship/2-consolidating/1-Flatfile/sgm.2020.all.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)
write.table(sgm.2020.BH,file="C:/Users/user/Desktop/Central/internship/2-consolidating/1-Flatfile/sgm.2020.BH.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)

sgm.2020.BH <- read.table(file="C:/Users/user/Desktop/Central/internship/2-consolidating/1-Flatfile/sgm.2020.BH.rec.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# + EQ_ID + rec.id + filter.id
sgm.2020.BH$EQ_ID <- paste0(sgm.2020.BH$Year,"_",str_pad(sgm.2020.BH$Month, 2, pad = "0"),str_pad(sgm.2020.BH$Day, 2, pad = "0"),"_",str_pad(sgm.2020.BH$Hour, 2, pad = "0"),str_pad(sgm.2020.BH$Minute, 2, pad = "0"),"_",str_pad(round(sgm.2020.BH$Sec, 0), 2, pad = "0"))
sgm.2020.BH$rec.id <- paste0(sgm.2020.BH$Year,"_",str_pad(sgm.2020.BH$Month, 2, pad = "0"),str_pad(sgm.2020.BH$Day, 2, pad = "0"),"_",str_pad(sgm.2020.BH$Hour, 2, pad = "0"),str_pad(sgm.2020.BH$Minute, 2, pad = "0"),"_",str_pad(round(sgm.2020.BH$Sec, 0), 2, pad = "0"),"_",sgm.2020.BH$Sta)
for (i in 1:nrow(sgm.2020.BH)){
  sgm.2020.BH$filter.id[i] <- paste0("B",str_pad(i, 6, pad = "0"))
}
sgm.2020.BH <- sgm.2020.BH[,c(32,30,31,2:24,1,25:29)]
write.table(sgm.2020.BH,file="C:/Users/user/Desktop/Central/internship/2-consolidating/1-Flatfile/sgm.2020.BH.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)


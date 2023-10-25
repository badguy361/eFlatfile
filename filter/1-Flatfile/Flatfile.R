library(stringr)
################################################ step 1 ################################################
sgm.2016 <- read.table(file="D:/Myanmar/filter/1-Flatfile/final_merge_event_eq(2016_2021)_focal_mechanism.csv", header = T,sep = ",", fill=TRUE)
sgm.2016 <- subset(sgm.2016,Year=="2016")
# ts file
path <- "D:/Myanmar/filter/@ts data/output_final/2016/" #asc
# DD <- list.files(path=path, pattern="^[0-9]")
# DD <- c("05","07","10","12") # 2021 use this row
DD <- c("05","06","07","08","09","10","12") # 2016 use this row
ts.frame <- setNames(data.frame(matrix(ncol = 7, nrow = 0)), c("Pfile", "file_name","P_arr_time","S_arr_time","start_time","end_time","Index"))

for (i in 1:length(DD)){
  # i <- 1
  path1 <- paste0(path,DD[i],"/")
  list.files <- list.files(path=path1, pattern="MM")
  ts.frame.tmp <- data.frame(Pfile=list.files,file_name=NA,Sta=NA,P_arr_time=NA,S_arr_time=NA,start_time=NA,end_time=NA,Index=NA,stringsAsFactors = FALSE)
  # merge Pfile dataframe and ts_name
  for (j in 1:nrow(ts.frame.tmp)){
    # j <- 1
    FF <- ts.frame.tmp$Pfile[j]
    L1 <- readLines(file(paste0(path1,FF)),n=1)
    ts.frame.tmp$file_name[j] <- paste0(str_sub(strsplit(FF,split='\\.')[[1]][1]),".",str_sub(strsplit(FF,split='\\.')[[1]][2]))
    ts.frame.tmp$Sta[j] <- str_sub(strsplit(FF,split='_')[[1]][2])
    ts.frame.tmp$P_arr_time[j] <- strsplit(L1,split='\\s+')[[1]][2]
    ts.frame.tmp$S_arr_time[j] <- strsplit(L1,split='\\s+')[[1]][3]
    ts.frame.tmp$start_time[j] <- strsplit(L1,split='\\s+')[[1]][4]
    ts.frame.tmp$end_time[j] <- strsplit(L1,split='\\s+')[[1]][5]
    ts.frame.tmp$Index[j] <- strsplit(L1,split='\\s+')[[1]][6]
  }
  ts.frame <- rbind(ts.frame, ts.frame.tmp) 
}
#  
sgm.2016 <- merge(sgm.2016,ts.frame,by=c("file_name"),all.x = TRUE,all.y = TRUE) 
sgm.2016 <- sgm.2016[order(sgm.2016$event_id),]
sgm.2016 <- sgm.2016[complete.cases(sgm.2016$Pfile), ]
write.table(sgm.2016,file="D:/Myanmar/filter/1-Flatfile/sgm.2016.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)

################################################ step 2 ################################################
sgm.2016 <- read.table(file="D:/Myanmar/filter/1-Flatfile/sgm.2016.rec.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# + EQ_ID + rec.id + filter.id 
sgm.2016$EQ_ID <- paste0(sgm.2016$Year,"_",str_pad(sgm.2016$Month, 2, pad = "0"),str_pad(sgm.2016$Day, 2, pad = "0"),"_",str_pad(sgm.2016$Hour, 2, pad = "0"),str_pad(sgm.2016$Minute, 2, pad = "0"),"_",str_pad(round(sgm.2016$Second_event, 0), 2, pad = "0"))
sgm.2016$rec.id <- paste0(sgm.2016$Year,"_",str_pad(sgm.2016$Month, 2, pad = "0"),str_pad(sgm.2016$Day, 2, pad = "0"),"_",str_pad(sgm.2016$Hour, 2, pad = "0"),str_pad(sgm.2016$Minute, 2, pad = "0"),"_",str_pad(round(sgm.2016$Second_event, 0), 2, pad = "0"),"_",sgm.2016$Sta)
for (i in 1:nrow(sgm.2016)){
  sgm.2016$filter.id[i] <- paste0("B",str_pad(i, 6, pad = "0"))
}
# sgm.2016 <- sgm.2016[,c(32,30,31,2:24,1,25:29)]
write.table(sgm.2016,file="D:/Myanmar/filter/1-Flatfile/sgm.2016.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)


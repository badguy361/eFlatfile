library(stringr)
sgm.2016 <- read.table(file="/app/TSMIP_Dataset/GDMS_Record.csv", header = T,sep = ",", fill=TRUE)
# sgm.2016 <- subset(sgm.2016,Year=="2016")
# ts file
path <- "/app/TSMIP_Dataset/picking_result/" #asc
# DD <- list.files(path=path, pattern="^[0-9]")
# DD <- c("05","07","10","12") # 2021 use this row
DD <- c("09") # 2016 use this row
ts.frame <- setNames(data.frame(matrix(ncol = 7, nrow = 0)), c("Pfile", "file_name","start_time","P_arrival","S_arrival","end_time","Index","filter_id"))

for (i in 1:length(DD)){
  # i <- 1
  path1 <- paste0(path,DD[i],"/")
  list.files <- list.files(path=path1, pattern="TW")
  ts.frame.tmp <- data.frame(Pfile=list.files,file_name=NA,start_time=NA,P_arrival=NA,S_arrival=NA,end_time=NA,Index=NA,stringsAsFactors = FALSE)
  # merge Pfile dataframe and ts_name
  for (j in 1:nrow(ts.frame.tmp)){
    # j <- 1
    FF <- ts.frame.tmp$Pfile[j]
    L1 <- readLines(file(paste0(path1,FF)),n=1)
    ts.frame.tmp$file_name[j] <- str_extract(FF, ".*\\.SAC")
    ts.frame.tmp$start_time[j] <- strsplit(L1,split='\\s+')[[1]][2]
    ts.frame.tmp$P_arrival[j] <- strsplit(L1,split='\\s+')[[1]][3]
    ts.frame.tmp$S_arrival[j] <- strsplit(L1,split='\\s+')[[1]][4]
    ts.frame.tmp$end_time[j] <- strsplit(L1,split='\\s+')[[1]][5]
    ts.frame.tmp$Index[j] <- strsplit(L1,split='\\s+')[[1]][6]
  }
  ts.frame <- rbind(ts.frame, ts.frame.tmp) 
}

sgm.2016 <- merge(sgm.2016,ts.frame,by=c("file_name"),all.x = TRUE,all.y = TRUE) 
sgm.2016 <- sgm.2016[order(sgm.2016$event_id),]
sgm.2016 <- sgm.2016[complete.cases(sgm.2016$Pfile), ]
write.table(sgm.2016,file="/app/filter/1-Flatfile/sgm.2016.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)


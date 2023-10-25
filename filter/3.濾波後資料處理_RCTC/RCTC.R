library("RCTC")

filter.frame <- read.csv(file="C:/Users/user/Desktop/Central/internship/2-consolidating/5-Rrup/2020.rec_FM_Vs30_Rrup.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
# filter.frame <- filter.frame[which(is.na(filter.frame$Error.Message)),]
# 
my.file.rename <- function(from, to) {
  todir <- dirname(to)
  if (!isTRUE(file.info(todir)$isdir)) dir.create(todir, recursive=TRUE)
  file.copy(from = from,  to = to)
}

for( i in 591:618){ #
  # i <- 2
  # setwd("C:/Users/user/Desktop/2020.07.27_BH data/6-RCTC")
  data.info <- filter.frame[i,]
  print(i)
  print(data.info$filter.id)
  path0 <- "C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/"
  path1 <- "C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Inputdata/"
  path2 <- "C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Inputdata_For_Run/"
  filelist1 <- list.files(path=path1, pattern = c(data.info$filter.id))
  #
  for (j in 1:2){
    my.file.rename(from = paste0(path1,"/",filelist1[j]),
                   to = paste0(path2,"/",filelist1[j]))
    }
  #
  IMplot(inputpath = path2, datatype = "timeseries",
         tmax4penalty_in = 10, tmin4penalty_in = 0, combine_index = 50, ang1 = 0, damping = 0.05, fraction = 0.7, Interpolation_factor = "auto")
  #
  my.file.rename(from = paste0(path0,"Outputdata/summary.csv"),
                 to = paste0(path0,"Outputdata_gather/summary_",data.info$rec.id,".csv"))
  file.remove(paste0(path2,"/",filelist1))
  print("== Done! ==")
}



#################################
library(stringr)
setwd("C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Outputdata_gather/")
myMergedData.summary <-
  do.call(rbind,lapply(list.files(path = "C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Outputdata_gather/",pattern = ".csv"),read.csv))
names(myMergedData.summary)[1] <- "filter.id"
myMergedData.summary$filter.id <- substring(myMergedData.summary$filter.id,1,7)
myMergedData.summary <- rapply(myMergedData.summary, as.character, classes="factor", how="replace")
#
save(myMergedData.summary,file="myMergedData.summary.Rdata")
write.table(myMergedData.summary,"C:/Users/user/Desktop/Central/internship/4-RCTC/RCTC Result/Outputdata_gather/myMergedData.summary.csv",sep=",",col.names = TRUE,row.names = FALSE)
# write.table(myMergedData.summary,"myMergedData.summary.csv",sep=",",col.names = TRUE,row.names = FALSE)

library(stringr)
myMergedData.summary <-
  do.call(rbind,lapply(list.files(path = "./",pattern = "summary_"), read.csv))
names(myMergedData.summary)[1] <- "filter_id"
myMergedData.summary$filter_id <- substring(myMergedData.summary$filter_id,1,6)
myMergedData.summary <- rapply(myMergedData.summary, as.character, classes="factor", how="replace")
#
write.table(myMergedData.summary,"myMergedData_summary.csv",sep=",",col.names = TRUE,row.names = FALSE)


library(stringr)
myMergedData.summary <-
  do.call(rbind,lapply(list.files(path = "./",pattern = "summary_"), read.csv))
print(myMergedData.summary)
names(myMergedData.summary)[1] <- "filter.id"
myMergedData.summary$filter.id <- substring(myMergedData.summary$filter.id,1,6)
myMergedData.summary <- rapply(myMergedData.summary, as.character, classes="factor", how="replace")
#
write.table(myMergedData.summary,"myMergedData_summary.csv",sep=",",col.names = TRUE,row.names = FALSE)


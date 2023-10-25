library(stringr)
sgm.2016 <- read.table(file="sgm.2016.rec.csv",sep=",",header = TRUE,stringsAsFactors = FALSE)
for (i in 1:nrow(sgm.2016)){
  sgm.2016$filter.id[i] <- paste0("B",str_pad(i, 6, pad = "0"))
}
write.table(sgm.2016,file="sgm.2016.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)


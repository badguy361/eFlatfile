# prepare bat file
NUM <- seq(1,1131,400)
file <- "run_filtering_Rscript.bat"
# 
for (i in 1:2){ 
  j1 <- NUM[i]
  j2 <- NUM[i]+399
  text <- paste("Rscript auto_run_filtering.R",j1,j2,"\n")
  cat(text,file=file,append=TRUE)
}

cat("Rscript auto_run_filtering.R 801 1131\n",file=file,append=TRUE)
cat("pause",file="run_filtering_Rscript.bat",append=TRUE)


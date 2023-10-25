# rec + sta_Vs30
rec_FM <- read.table(file="C:/Users/user/Desktop/Central/internship/2-consolidating/3-Focal Mechanism/rec+FM2017.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
# Sta
Vs30 <- read.table(file="C:/Users/user/Desktop/Central/internship/2-consolidating/4-Vs30/CWB_BH+Vs30.csv",sep=",",header=TRUE)
sgm.2017.BH_Sta <- merge(rec_FM,Vs30,by=c("Sta"))
sgm.2017.BH_Sta <- sgm.2017.BH_Sta[order(sgm.2017.BH_Sta$Year,sgm.2017.BH_Sta$Month,sgm.2017.BH_Sta$Day,sgm.2017.BH_Sta$Hour,sgm.2017.BH_Sta$Minute,sgm.2017.BH_Sta$Second,sgm.2017.BH_Sta$Sta),]

# sgm.2018.BH_Sta2 <- sgm.2018.BH_Sta[,c("filter.id","EQ_ID","rec.id","Year","Month","Day","Hour","Minute","Second",
#                                    "Lat","Lat.min","Lon","Lon.min","Lon.X","Lat.Y","Depth","ML","Pfile",         
#                                    "Sta.num","closest.epi","angle","RMS","ERH","ERZ","N","Number","quality",
#                                    "Sta","Name","County","City","Net","Lon.Sta.X","Lat.Sta.Y","El.","address",
#                                    "ts_name","P_arr_time","S_arr_time","Index")]
sgm.2017.BH_Sta2 <- sgm.2017.BH_Sta[,c(3,2,4:94,1,95:114)]
sgm.2017.BH_Sta2 <- sgm.2017.BH_Sta2[order(sgm.2017.BH_Sta2$filter.id),]
#
# a <- read.table(file="C:/Users/user/Desktop/aaa")
# b <- read.table(file="C:/Users/user/Desktop/sgm.2019.BH.Sta")



write.table(sgm.2017.BH_Sta2,file="C:/Users/user/Desktop/Central/internship/2-consolidating/4-Vs30/sgm.2017.BH.Sta.rec.csv",sep=",",col.names = TRUE,row.names = FALSE)

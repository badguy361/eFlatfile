source(file = "hageodist.R")
library(dplyr)
records <- read.table(file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/TSMIP_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)

# TODO
records_selected <- records %>% select("event_id", your_desired_column1_from_records, ...)
catalog_selected <- catalog %>% select("event_id", your_desired_column2_from_catalog, ...)
stations_selected <- stations %>% select("station", your_desired_column3_from_stations, ...)

tmp <- inner_join(records_selected, catalog_selected, by = "event_id")
rec_FM_Vs30 <- inner_join(tmp, stations_selected, by = "station")


tmp = inner_join(x = records, y = catalog, by = "event_id")
rec_FM_Vs30 = inner_join(x = tmp, y = stations, by = "station")
write.table(rec_FM_Vs30,file="tmp.csv",sep=",",col.names = TRUE,row.names = FALSE)

# Rrup
plane1 <- read.table(file="Fortran_plane1/fy_out_plane1.txt")
names(plane1) <- c("filter_id","Rrup_p1","Rrup.x1","Rrup.y1","Rrup.z1")
plane1.for.merge <- plane1[,c("filter_id","Rrup_p1")]
#
plane2 <- read.table(file="Fortran_plane2/fy_out_plane2.txt")
names(plane2) <- c("filter_id","Rrup_p2","Rrup.x2","Rrup.y2","Rrup.z2")
plane2.for.merge <- plane2[,c("filter_id","Rrup_p2")]
#
rec_FM_Vs30_2 <- merge(rec_FM_Vs30,plane1.for.merge,by=c("filter_id"),all.x=TRUE)
rec_FM_Vs30_2 <- merge(rec_FM_Vs30_2,plane2.for.merge,by=c("filter_id"),all.x=TRUE)
rec_FM_Vs30_2$Avg_Rrup <- (rec_FM_Vs30_2$Rrup_p1+rec_FM_Vs30_2$Rrup_p2)/2.

# Hypo (Mw <= 4.8)
Hori.R <- hageodist(rec_FM_Vs30_2$longitude,rec_FM_Vs30_2$latitude,rec_FM_Vs30_2$lon,rec_FM_Vs30_2$lat)
rec_FM_Vs30_2$Hypo <- sqrt(Hori.R**2+rec_FM_Vs30_2$depth**2)

# Adopted Rrup
rec_FM_Vs30_2$Adopted_Rrup <- rec_FM_Vs30_2$Hypo
rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Adopted_Rrup"] <- rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Avg_Rrup"]

write.table(rec_FM_Vs30_2,file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",row.names = FALSE, col.names = TRUE)


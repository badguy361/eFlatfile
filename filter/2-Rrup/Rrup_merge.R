source(file = "hageodist.R")
library(dplyr)
records <- read.table(file="sgm.2021_Frv_Fnm.rec.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/GDMS_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)

tmp = inner_join(x = records, y = catalog, by = "event_id")
rec_FM_Vs30 = inner_join(x = tmp, y = stations, by = "station")
write.table(rec_FM_Vs30,file="tmp.csv",sep=",",col.names = TRUE,row.names = FALSE)

# Rrup
plane1 <- read.table(file="Fortran_plane1/2016_fy_out_plane1.txt")
names(plane1) <- c("filter.id","Rrup_p1","Rrup.x1","Rrup.y1","Rrup.z1")
plane1.for.merge <- plane1[,c("filter.id","Rrup_p1")]
#
plane2 <- read.table(file="Fortran_plane2/2016_fy_out_plane2.txt")
names(plane2) <- c("filter.id","Rrup_p2","Rrup.x2","Rrup.y2","Rrup.z2")
plane2.for.merge <- plane2[,c("filter.id","Rrup_p2")]
#
rec_FM_Vs30_2 <- merge(rec_FM_Vs30,plane1.for.merge,by=c("filter.id"),all.x=TRUE)
rec_FM_Vs30_2 <- merge(rec_FM_Vs30_2,plane2.for.merge,by=c("filter.id"),all.x=TRUE)
rec_FM_Vs30_2$Avg_Rrup <- (rec_FM_Vs30_2$Rrup_p1+rec_FM_Vs30_2$Rrup_p2)/2.

# Hypo (Mw <= 4.8)
Hori.R <- hageodist(rec_FM_Vs30_2$longitude,rec_FM_Vs30_2$latitude,rec_FM_Vs30_2$lon,rec_FM_Vs30_2$lat)
rec_FM_Vs30_2$Hypo <- sqrt(Hori.R**2+rec_FM_Vs30_2$depth**2)

# Adopted Rrup
rec_FM_Vs30_2$Adopted_Rrup <- rec_FM_Vs30_2$Hypo
rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Adopted_Rrup"] <- rec_FM_Vs30_2[which(!is.na(rec_FM_Vs30_2$Avg_Rrup)),"Avg_Rrup"]

write.table(rec_FM_Vs30_2,file="sgm.2021_Frv_Fnm.rec_tmp2.csv",sep=",",row.names = FALSE, col.names = TRUE)  # ,na="0"


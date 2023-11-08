source(file = "hageodist.R")
library(dplyr)
records <- read.table(file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
catalog <- read.table(file="../../TSMIP_Dataset/GDMS_catalog.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)
stations <- read.table(file="../../TSMIP_Dataset/TSMIP_stations.csv",sep=",",header=TRUE,stringsAsFactors = FALSE)

catalog_selected <- catalog %>% select("event_id", "longitude", "latitude", "depth") %>%
        rename(eq_longitude = longitude,
               eq_latitude = latitude,
               eq_depth = depth)
stations_selected <- stations %>% select("station", "lon", "lat") %>%
        rename(sta_longitude = lon,
               sta_latitude = lat)

tmp = inner_join(x = records, y = catalog_selected, by = "event_id")
total_record = inner_join(x = tmp, y = stations_selected, by = "station")

# Rrup
plane1 <- read.table(file="Fortran_plane1/fy_out_plane1.txt")
names(plane1) <- c("filter_id","Rrup_p1","Rrup.x1","Rrup.y1","Rrup.z1")
plane1.for.merge <- plane1[,c("filter_id","Rrup_p1")]
#
plane2 <- read.table(file="Fortran_plane2/fy_out_plane2.txt")
names(plane2) <- c("filter_id","Rrup_p2","Rrup.x2","Rrup.y2","Rrup.z2")
plane2.for.merge <- plane2[,c("filter_id","Rrup_p2")]
#
total_record <- merge(total_record,plane1.for.merge,by=c("filter_id"),all.x=TRUE)
total_record <- merge(total_record,plane2.for.merge,by=c("filter_id"),all.x=TRUE)
total_record$Avg_Rrup <- (total_record$Rrup_p1+total_record$Rrup_p2)/2.

# Hypo (Mw <= 4.8)
Hori.R <- hageodist(total_record$eq_longitude,total_record$eq_latitude,total_record$sta_lon,total_record$sta_lat)
total_record$Hypo <- sqrt(Hori.R**2+total_record$eq_depth**2)

# Adopted Rrup
total_record$Adopted_Rrup <- total_record$Hypo
total_record[which(!is.na(total_record$Avg_Rrup)),"Adopted_Rrup"] <- total_record[which(!is.na(total_record$Avg_Rrup)),"Avg_Rrup"]

write.table(total_record,file="../../TSMIP_Dataset/GDMS_Record.csv",sep=",",row.names = FALSE, col.names = TRUE)


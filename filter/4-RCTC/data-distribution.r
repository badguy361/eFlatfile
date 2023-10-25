library(ggplot2)
library(gcookbook)
# merge.BH.FF2_1 <- read.table(file="C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2020.csv", header = T,sep = ",")
# merge.BH.FF2_2020 <- read.table(file="C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2020.csv", header = T,sep = ",")
# merge.BH.FF2_2019 <- read.table(file="C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2019.csv", header = T,sep = ",")
# merge.BH.FF2_2018 <- read.table(file="C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2018.csv", header = T,sep = ",")
# merge.BH.FF2_2017 <- read.table(file="C:/Users/user/Desktop/Central/internship/5-Merge Filtering Result/rec_txt_RSP_RCTC_2017.csv", header = T,sep = ",")
# merge.BH.FF2_2016 <- read.table(file="D:/picking/total_file/6-RCTC/rec_txt_RSP_RCTC_2016.csv", header = T,sep = ",")
merge.BH.FF2_2016_2020 <- read.table(file="D:/picking/total_file/6-RCTC/rec_txt_RSP_RCTC_2016-2020.csv", header = T,sep = ",")

# merge.BH.FF2_2018 <- merge.BH.FF2_2018[ ,-1293]
# merge.BH.FF2_1 <- rbind(merge.BH.FF2_2020,merge.BH.FF2_2019,merge.BH.FF2_2018,merge.BH.FF2_2017)
merge.BH.FF2_1 <- rbind(merge.BH.FF2_2016_2020)
merge.BH.FF2 <- merge.BH.FF2_1[which(!is.na(merge.BH.FF2_1$Final_Mw)), ]
merge.BH.FF2$PGA_1.0T <- -log(merge.BH.FF2$T1.000S_RotD50)


range(merge.BH.FF2$Adopted_Rrup) #  5.141244 291.908025s
range(merge.BH.FF2$Final_Mw)  # 3.29 6.40
range(merge.BH.FF2$final.Dep) # 1.01 158.66

# SUB
# plot_rec <- merge.BH.FF2[which(!is.na(merge.BH.FF2$EQ_Type)),] 
# text <- "SUB"
# # CRU
# plot_rec <- merge.BH.FF2[which(is.na(merge.BH.FF2$EQ_Type)),] 
# text <- "CRU"
plot_rec <- merge.BH.FF2
plot_rec <- plot_rec[order(plot_rec$PGA_Rot50),]
# text <- "no type"
# # Rrup vs Mw 
# pic <- paste0("C:/Users/user/Desktop/Central/internship/export image/2017~2020_Rrup_Mw_",text,".png")
# png(pic,width=750,height=750)
# par(pin=c(5,5),mar=c(6,5.8,5,3))
# plot(plot_rec$Adopted_Rrup,plot_rec$Final_Mw,type='n',log="x",ylim=c(2.8,6.5),xlim=c(4.5,550),ann=FALSE, axes=FALSE)
# # 
# grid.x <- c(seq(0.1,0.9,by=0.1),seq(1,10,by=1),seq(10,100,by=10),seq(100,1000,by=100),seq(1000,10000,by=1000))
# grid.y <- c(seq(-2,10,by=0.5))
# abline(h=grid.y,col="grey",lwd=2.4)
# abline(v=grid.x,col="grey",lwd=2.4)
# #
# points(plot_rec$Adopted_Rrup,plot_rec$Final_Mw,pch=1,cex=1.8,col="dodgerblue1")
# #
# x.at <- c(0.1,1,5,10,30,50,100,300,500,1000,5000,10000)
# y.at <- c(-1,0,1,2,3,4,5,6,7,8,9)
# axis(1,at=x.at,labels=c(0.1,1,5,10,30,50,100,300,500,1000,5000,10000),cex.axis=2.3,lwd = 3,padj = 0.3)
# axis(2,at=y.at,labels=c(-1,0,1,2,3,4,5,6,7,8,9),cex.axis=2.5,lwd = 3,las = 2) # 10^-5,10^-4,10^-3,10^-2,10^-1,10^0,10^1,10^2
# axis(3,at=x.at,labels=FALSE,tck=0,lwd = 3)
# axis(4,at=y.at,labels=FALSE,tck=0,lwd = 3)
# # legend 1
# legend.names <- c(paste0("Borehole (2017~2020)"))
# legend("bottomright",legend=legend.names,bg="white",pch=c(1,1), col = c("dodgerblue1"),cex=2.5,inset=c(0.01,0.01))
# # title
# mtext(paste0("Rrup and Mw Distribution of Borehole (2017~2020)"),side=3,line=1,cex=2.5) # , Dep = ",Dep,"(km)
# # axis title
# mtext("Mw",side=2,line=3.3,cex=3.3)
# mtext("Rrup (km)",side=1,line=4.3,cex=3.3)
# dev.off()
# 
# 
# 
# 
# #####
# 
# 
# pic <- paste0("C:/Users/user/Desktop/Central/internship/export image/2017~2020_Dep_Mw_",text,".png")
# png(pic,width=750,height=750)
# par(pin=c(5,5),mar=c(6,5.8,5,3.5))
# plot(plot_rec$final.Dep,plot_rec$Final_Mw,type='n',log="x",ylim=c(2.8,6.5),xlim=c(2,220),ann=FALSE, axes=FALSE)
# grid.x <- c(seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(1,10,by=1),seq(10,100,by=10),seq(100,1000,by=100))
# grid.y <- c(seq(2,10,by=0.5))
# abline(h=grid.y,col="grey",lwd=2.4)
# abline(v=grid.x,col="grey",lwd=2.4)
# #
# points(plot_rec$final.Dep,plot_rec$Final_Mw,pch=1,cex=1.8,col="deeppink")
# #
# x.at <- c(0.01,0.1,1,5,10,30,50,100,300,500,1000)
# y.at <- c(-1,0,1,2,3,4,5,6,7,8,9)
# axis(1,at=x.at,labels=c(0.01,0.1,1,5,10,30,50,100,300,500,1000),cex.axis=2.3,lwd=3,padj = 0.3)
# axis(2,at=y.at,labels=c(-1,0,1,2,3,4,5,6,7,8,9),cex.axis=2.5,lwd=3,las=2) # 10^-5,10^-4,10^-3,10^-2,10^-1,10^0,10^1,10^2
# axis(3,at=x.at,labels=FALSE,tck=0,lwd=3)
# axis(4,at=y.at,labels=FALSE,tck=0,lwd=3)
# # legend 1
# legend.names <- c(paste0("Borehole (2017~2020)"))
# legend("bottomright",legend=legend.names,bg="white",pch=c(1,1), col = c("deeppink"),cex=2.5,inset=c(0.01,0.01))
# # title
# mtext(paste0("Depth and Mw Distribution of Borehole (2017~2020)"),side=3,line=1,cex=2.5) # , Dep = ",Dep,"(km)
# # axis title
# mtext("Mw",side=2,line=3.3,cex=3.3)
# mtext("Depth (km)",side=1,line=4.3,cex=3.3)
# dev.off()








## distance_PGA
png("D:/picking/total_file/6-RCTC/2016-2020_distance_PGA_Rot50.png",width=900,height=750)
ggplot(plot_rec, aes(Adopted_Rrup, PGA_Rot50))+
  geom_point(aes(color=Final_Mw),shape=1,size=5)+
  ggtitle("Distance vs PGA_Rot50 (2016-2020)") + xlab("Distance (km)") + ylab("PGA_Rot50 (g)")+
  scale_y_log10(limits=c(0.000001,10),breaks= c(0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10),minor_breaks=c(seq(0.0000000001,0.0000000009,by=0.0000000001),
                                                                                                  seq(0.000000001,0.000000009,by=0.000000001),
                                                                                                  seq(0.00000001,0.00000009,by=0.00000001),
                                                                                                  seq(0.0000001,0.0000009,by=0.0000001),
                                                                                                  seq(0.000001,0.000009,by=0.000001),
                                                                                                  seq(0.00001,0.00009,by=0.00001),
                                                                                                  seq(0.0001,0.0009,by=0.0001),
                                                                                                  seq(0.001,0.009,by=0.001),
                                                                                                  seq(0.01,0.09,by=0.01),
                                                                                                  seq(0.1,0.9,by=0.1),seq(1,9,by=1),
                                                                                                  seq(10,200,by=20),seq(210,1000,by = 100)))+
  scale_x_continuous(limits=c(5,550),trans='log2',breaks=(c(1,2,5,10,20,50,100,200,500)),minor_breaks=c(seq(0.01,0.09,by=0.01),
                                                                                                      seq(0.1,0.9,by=0.1),seq(1,10,by=1),
                                                                                                      seq(10,100,by=10),seq(100,1000,by=100)))+
  theme(panel.background=element_blank(),#�h���I��
        panel.grid.major=element_line(colour='gray90', size=0.8),
        panel.grid.minor=element_line(colour='gray90', size=0.8),
        panel.border = element_rect(fill=NA,color="black", size=2, linetype="solid"),
        plot.margin = margin(1,1,0.1,0.1, "cm"),
        plot.title = element_text(hjust = 0.5,size=30),
        axis.title.x=element_text(hjust = 0.5,size=30),
        axis.title.y=element_text(hjust = 0.5,size=30),
        axis.text = element_text(size=30),
        legend.position = c(.98, .98),
        legend.justification = c("right", "top"),
        legend.box.just = "top",
        legend.margin = margin(6, 6, 6, 6),
        legend.key.size = unit(40, "pt"),
        legend.title=element_text(hjust = 0.3,size=15),
        legend.text=element_text(size=15),
        legend.background = element_rect(colour = 'black'),
        )+
  scale_colour_gradientn("Mw",colours=rainbow(4),c(3.5,4,5,6,6.3))
  #(�쥻���S��n -> scale_colour_gradient)
dev.off()
# pic1 <- paste0("C:/Users/user/Desktop/Central/internship/export image/2017~2020_distance_RoTD50_1.0T_",text,".png")
#pic1 <- paste0("D:/picking/total_file/6-RCTC/2016_distance_SA(3.0)_Rot50_",".png")
#png(pic1,width=1050,height=950)
#par(pin=c(5,5),mar=c(6,8.7,5,3.7))
#plot(100,0.01,type='n',log="xy",ylim=c(0.000007,7),xlim=c(5,450),ann=FALSE, axes=FALSE)  # ,main="Distance vs PGA"
#grid.x <- c(seq(0.1,0.9,by=0.1),seq(1,10,by=1),seq(10,100,by=10),seq(100,1000,by=100),seq(1000,10000,by=1000))
#grid.y <- c(seq(0.0000000001,0.0000000009,by=0.0000000001),seq(0.000000001,0.000000009,by=0.000000001),seq(0.00000001,0.00000009,by=0.00000001),seq(0.0000001,0.0000009,by=0.0000001),seq(0.000001,0.000009,by=0.000001),seq(0.00001,0.00009,by=0.00001),seq(0.0001,0.0009,by=0.0001),seq(0.001,0.009,by=0.001),seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(1,9,by=1),seq(10,200,by=20),seq(210,1000,by = 100))
#abline(h=grid.y,col="grey",lwd=2.9)
#abline(v=grid.x,col="grey",lwd=2.9)

#x.at <- c(0.1,0.2,0.5,1,2,5,10,20,50,100,200,500,1000,2000,5000,6000)
#y.at <- c(0.000000001,0.00000001,0.0000001,0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10,100,1000)
#axis(1,at=x.at,labels=c(0.1,0.2,0.5,1,2,5,10,20,50,100,200,500,1000,2000,5000,6000),cex.axis=2.7,padj = 0.3,lwd=4)
#axis(2,at=y.at,labels=expression(10^-9,10^-8,10^-7,10^-6,10^-5,10^-4,10^-3,10^-2,10^-1,10^0,10^1,10^2,10^3),cex.axis=2.7,las=2,lwd=4)
#axis(3,at=x.at,labels=FALSE,tck=0,lwd=4)
#axis(4,at=y.at,labels=FALSE,tck=0,lwd=4)

# points
# points(plot_rec[which(plot_rec$Final_Mw>=3&plot_rec$Final_Mw<4),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=3&plot_rec$Final_Mw<4),]$T1.000S_RotD50,pch=1,cex=2.5,col="red")
# points(plot_rec[which(plot_rec$Final_Mw>=4&plot_rec$Final_Mw<5),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=4&plot_rec$Final_Mw<5),]$T1.000S_RotD50,pch=1,cex=2.5,col="orange")
# points(plot_rec[which(plot_rec$Final_Mw>=5&plot_rec$Final_Mw<6),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=5&plot_rec$Final_Mw<6),]$T1.000S_RotD50,pch=1,cex=2.5,col="darkgreen")
# points(plot_rec[which(plot_rec$Final_Mw>=6&plot_rec$Final_Mw<7),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=6&plot_rec$Final_Mw<7),]$T1.000S_RotD50,pch=1,cex=2.5,col="blue")
#points(plot_rec[which(plot_rec$Final_Mw>=3&plot_rec$Final_Mw<4),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=3&plot_rec$Final_Mw<4),]$T3.000S_RotD50,pch=1,cex=2.5,col="red")
#points(plot_rec[which(plot_rec$Final_Mw>=4&plot_rec$Final_Mw<5),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=4&plot_rec$Final_Mw<5),]$T3.000S_RotD50,pch=1,cex=2.5,col="orange")
#points(plot_rec[which(plot_rec$Final_Mw>=5&plot_rec$Final_Mw<6),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=5&plot_rec$Final_Mw<6),]$T3.000S_RotD50,pch=1,cex=2.5,col="darkgreen")
#points(plot_rec[which(plot_rec$Final_Mw>=6&plot_rec$Final_Mw<7),]$Adopted_Rrup,plot_rec[which(plot_rec$Final_Mw>=6&plot_rec$Final_Mw<7),]$T3.000S_RotD50,pch=1,cex=2.5,col="blue")


# ggplot(plot_rec,aes(x=Adopted_Rrup,y=T1.000S_RotD50))+
#   geom_point(aes(color=PGA_1.0T))+
#   scale_y_log10()+
#   scale_x_log10()+
#   scale_colour_gradient(low="red",high="blue")+
#   coord_cartesian(ylim=c(0.0000001,5),xlim=c(5,450))


# legend
# legend.names <- c("Mw = 4.5","Mw = 5.5","Mw = 6.5","Mw = 7.5") # ,"Yeh,2016"
# legend("topright",legend=legend.names,col=c("red","orange","darkgreen","blue","grey"),lwd=c(2,2,2,2,1),lty=c(1,1,1,1),bg="white",cex=2)
#legend.names <- c("3<Mw<=4","4<Mw<=5","5<Mw<=6","6<Mw<=7") # ,paste0("Foreign Data")
#legend("topright",legend=legend.names,pch=c(1,1,1,1),col=c("red","orange","darkgreen","blue","grey"),bg="white",cex=2.3,inset=c(0.01,0.01),ncol = 2)

# title
# mtext(paste0("Distance vs SA(3.0) (2016)"),side=3,line=1.8,cex=3) # , Dep = ",Dep,"(km)

# axis title
# mtext("SA(3.0) (g)",side=2,line=6.2,cex=3.6)
# mtext("Distance (km)",side=1,line=4.2,cex=3.5)
#dev.off()




## Mw_PGA SA
png("D:/picking/total_file/6-RCTC/2016-2020_Mw_SA(3.0)_Rot50.png",width=900,height=750)
ggplot(plot_rec, aes(Final_Mw, T3.000S_RotD50))+
  geom_point(aes(color=Adopted_Rrup),shape=1,size=5)+
  ggtitle("Mw vs SA(3.0) (2016-2020)") + xlab("Mw") + ylab("SA(3.0) (g)")+
  scale_y_log10(limits=c(0.000001,10),breaks= c(0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10),minor_breaks=c(seq(0.0000000001,0.0000000009,by=0.0000000001),
                                                                                                            seq(0.000000001,0.000000009,by=0.000000001),
                                                                                                            seq(0.00000001,0.00000009,by=0.00000001),
                                                                                                            seq(0.0000001,0.0000009,by=0.0000001),
                                                                                                            seq(0.000001,0.000009,by=0.000001),
                                                                                                            seq(0.00001,0.00009,by=0.00001),
                                                                                                            seq(0.0001,0.0009,by=0.0001),
                                                                                                            seq(0.001,0.009,by=0.001),
                                                                                                            seq(0.01,0.09,by=0.01),
                                                                                                            seq(0.1,0.9,by=0.1),seq(1,9,by=1),
                                                                                                            seq(10,200,by=20),seq(210,1000,by = 100)))+
  scale_x_continuous(limits=c(3,7),breaks=(c(3,4,5,6,7)))+
  theme(panel.background=element_blank(),#�h���I��
        panel.grid.major=element_line(colour='gray90', size=0.8),
        panel.grid.minor=element_line(colour='gray90', size=0.8),
        panel.border = element_rect(fill=NA,color="black", size=2, linetype="solid"),
        plot.margin = margin(1,1,0.1,0.1, "cm"),
        plot.title = element_text(hjust = 0.5,size=30),
        axis.title.x=element_text(hjust = 0.5,size=30),
        axis.title.y=element_text(hjust = 0.5,size=30),
        axis.text = element_text(size=30),
        legend.position = c(.98, .98),
        legend.justification = c("right", "top"),
        legend.box.just = "top",
        legend.margin = margin(6, 6, 6, 6),
        legend.key.size = unit(40, "pt"),
        legend.title=element_text(hjust = 0.3,size=15),
        legend.text=element_text(size=15),
        legend.background = element_rect(colour = 'black'),
  )+
  scale_colour_gradientn("Distance(km)",colours=rainbow(5),c(10,100,200,300,400))
dev.off()
# pic1 <- paste0

## Mw_PGA
#pic1 <- paste0("C:/Users/user/Desktop/Central/internship/export image/2017~2020_Mw_PGA_Rot50_",text,".png")
#png(pic1,width=1050,height=950)
#par(pin=c(5,5),mar=c(6,8.7,5,3.7))
#plot(1,0.01,type='n',log="xy",ylim=c(0.000007,3),xlim=c(3.1,6.5),ann=FALSE, axes=FALSE)  # ,main="Distance vs PGA"
#grid.x <- c(seq(-1,10,by=0.5))
#grid.y <- c(seq(0.0000000001,0.0000000009,by=0.0000000001),seq(0.000000001,0.000000009,by=0.000000001),seq(0.00000001,0.00000009,by=0.00000001),seq(0.0000001,0.0000009,by=0.0000001),seq(0.000001,0.000009,by=0.000001),seq(0.00001,0.00009,by=0.00001),seq(0.0001,0.0009,by=0.0001),seq(0.001,0.009,by=0.001),seq(0.01,0.09,by=0.01),seq(0.1,0.9,by=0.1),seq(1,9,by=1),seq(10,200,by=20),seq(210,1000,by=100))
#abline(h=grid.y,col="grey",lwd = 2.9)
#abline(v=grid.x,col="grey",lwd = 2.9)

#x.at <- c(seq(-1,10,by=0.5))
#y.at <- c(0.000000001,0.00000001,0.0000001,0.000001,0.00001,0.0001,0.001,0.01,0.1,1,10,100,1000,10000)
#axis(1,at=x.at,labels=c(seq(-1,10,by=0.5)),cex.axis=2.7,padj=0.3,lwd = 4)
#axis(2,at=y.at,labels=expression(10^-9,10^-8,10^-7,10^-6,10^-5,10^-4,10^-3,10^-2,10^-1,10^0,10^1,10^2,10^3,10^4),cex.axis=2.7,lwd = 4,las=2)
#axis(3,at=x.at,labels=FALSE,tck=0,lwd = 4)
#axis(4,at=y.at,labels=FALSE,tck=0,lwd = 4)
# 


## points
## points(plot_rec$Final_Mw,  plot_rec$PGA.sqrt,pch=1,cex=1,col="blue")
## points(plot_rec[which(plot_rec$Adopted_Rrup>=0.01&plot_rec$Adopted_Rrup<35),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=0.01&plot_rec$Adopted_Rrup<35),]$T1.000S_RotD50,pch=1,cex=2.5,col="red")
## points(plot_rec[which(plot_rec$Adopted_Rrup>=35.01&plot_rec$Adopted_Rrup<100),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=35.01&plot_rec$Adopted_Rrup<100),]$T1.000S_RotD50,pch=1,cex=2.5,col="orange")
## points(plot_rec[which(plot_rec$Adopted_Rrup>=100.01&plot_rec$Adopted_Rrup<150),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=100.01&plot_rec$Adopted_Rrup<150),]$T1.000S_RotD50,pch=1,cex=2.5,col="darkgreen")
## points(plot_rec[which(plot_rec$Adopted_Rrup>=150.01&plot_rec$Adopted_Rrup<300),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=150.01&plot_rec$Adopted_Rrup<300),]$T1.000S_RotD50,pch=1,cex=2.5,col="blue")

#points(plot_rec[which(plot_rec$Adopted_Rrup>=0.01&plot_rec$Adopted_Rrup<35),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=0.01&plot_rec$Adopted_Rrup<35),]$PGA_Rot50,pch=1,cex=2.5,col="red")
#points(plot_rec[which(plot_rec$Adopted_Rrup>=35.01&plot_rec$Adopted_Rrup<100),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=35.01&plot_rec$Adopted_Rrup<100),]$PGA_Rot50,pch=1,cex=2.5,col="orange")
#points(plot_rec[which(plot_rec$Adopted_Rrup>=100.01&plot_rec$Adopted_Rrup<150),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=100.01&plot_rec$Adopted_Rrup<150),]$PGA_Rot50,pch=1,cex=2.5,col="darkgreen")
#points(plot_rec[which(plot_rec$Adopted_Rrup>=150.01&plot_rec$Adopted_Rrup<300),]$Final_Mw,plot_rec[which(plot_rec$Adopted_Rrup>=150.01&plot_rec$Adopted_Rrup<300),]$PGA_Rot50,pch=1,cex=2.5,col="blue")

#legend.names <- c("0.01 ~ 35","35.01 ~ 100","100.01 ~ 150 ","150.01 ~ 300") # ,paste0("Foreign Data")
#legend("topleft",legend=legend.names,col=c("red","orange","darkgreen","blue"),pch=c(1,1,1,1),bg="white",cex=1.6,inset=c(0.01,0.01),ncol = 2, title = "Distance (km)")

# title
#mtext(paste0("Mw vs PGA_Rot50 (2017~2020)"),side=3,line=1.8,cex=4) # , Dep = ",Dep,"(km)

# axis title
#mtext("PGA (g)",side=2,line=6.2,cex=3.6)
#mtext("Mw",side=1,line=4.2,cex=3.6)
#dev.off()



## distance_Mw
png("D:/picking/total_file/6-RCTC/2016-2020_distance_Mw_Rot50.png",width=900,height=750)
ggplot(plot_rec, aes(Adopted_Rrup,Final_Mw))+
  geom_point(aes(color=PGA_Rot50),shape=1,size=5)+
  ggtitle("Distance vs Mw (2016-2020)") + xlab("Distance (km)") + ylab("Mw")+
  scale_x_log10(limits=c(1,500),breaks= c(1,10,100,500),minor_breaks=c(seq(0.0000000001,0.0000000009,by=0.0000000001),
                                                                            seq(0.000000001,0.000000009,by=0.000000001),
                                                                            seq(0.00000001,0.00000009,by=0.00000001),
                                                                            seq(0.0000001,0.0000009,by=0.0000001),
                                                                            seq(0.000001,0.000009,by=0.000001),
                                                                            seq(0.00001,0.00009,by=0.00001),
                                                                            seq(0.0001,0.0009,by=0.0001),
                                                                            seq(0.001,0.009,by=0.001),
                                                                            seq(0.01,0.09,by=0.01),
                                                                            seq(0.1,0.9,by=0.1),seq(1,9,by=1),
                                                                            seq(10,200,by=20),seq(210,1000,by = 100)))+
  scale_y_continuous(limits=c(3,7),breaks=(c(3,4,5,6,7)))+
  theme(panel.background=element_blank(),#�h���I��
        panel.grid.major=element_line(colour='grey', size=0.8),
        panel.grid.minor=element_line(colour='grey', size=0.8),
        panel.border = element_rect(fill=NA,color="black", size=2, linetype="solid"),
        plot.margin = margin(1,1,0.1,0.1, "cm"),
        plot.title = element_text(hjust = 0.5,size=30),
        axis.title.x=element_text(hjust = 0.5,size=30),
        axis.title.y=element_text(hjust = 0.5,size=30),
        axis.text = element_text(size=30),
        legend.position = c(.98, .98),
        legend.justification = c("right", "top"),
        legend.box.just = "top",
        legend.margin = margin(6, 6, 6, 6),
        legend.key.size = unit(40, "pt"),
        legend.title=element_text(hjust = 0.3,size=15),
        legend.text=element_text(size=15),
        legend.background = element_rect(colour = 'black'),
  )+
  scale_colour_gradient("PGA_Rot50(g)",low = "#00FFFF",high = "#FF0000",c(0.00001,0.0001,0.001,0.01,0.1,1),limits=c(0.00001,1),trans="log10")
dev.off()
#�C��https://bootstrappers.umassmed.edu/bootstrappers-courses/pastCourses/rCourse_2016-04/Additional_Resources/Rcolorstyle.html#creating-vectors-of-contiguous-colors
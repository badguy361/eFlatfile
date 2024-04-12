class sac2asc:
    def __init__(self,sacdataz,sacdata1,sacdata2,zory):
        """
            npts: total point ex:48800
            delta: sampling rate ex:0.01
            b: begin point ex:-300
            depmax: max value
            t1: p arrival time
            t2: s arrival time
            t3: end time
            t4: start time
        """
        self.npts1 = int(sacdata1.npts)
        self.npts2 = int(sacdata2.npts)
        self.nptsz = int(sacdataz.npts)
        self.dt1 = float(sacdata1.delta)
        self.dt2 = float(sacdata2.delta)
        self.dtz = float(sacdataz.delta)
        try:
            self.t1 = float(sacdata1.t1)
            self.t2 = float(sacdata1.t2)
            self.t3 = float(sacdata1.t3)
            self.t4 = float(sacdata1.t4)

            # 0403 case
            # self.t1 = float(sacdata1.t1-sacdata1.b)
            # self.t2 = float(sacdata1.t2-sacdata1.b)
            # self.MAX = max(float(sacdataz.depmax),float(sacdata1.depmax),float(sacdata2.depmax))
        except:
            print("plz define t1-t4")
        self.b = float(sacdata1.b)
        self.y1 = sacdata1.data
        self.y2 = sacdata2.data
        self.yz = sacdataz.data
        self.Parr = float(sacdata1.t1-sacdata1.b)
        self.Sarr = float(sacdata1.t2-sacdata1.b)
        self.zory = zory

        # self.mz=sum(self.yz)/self.npts1 # yz -> mean
        # for i in range(self.npts1):
        #     self.yz[i]=self.yz[i]-self.mz # normalize
        # self.m1=sum(self.y1)/self.npts1
        # for i in range(self.npts1):
        #     self.y1[i]=self.y1[i]-self.m1 # normalize
        # self.m2=sum(self.y2)/self.npts1
        # for i in range(self.npts1):
        #     self.y2[i]=self.y2[i]-self.m2 # normalize
            
    def __call__(self, asc_path):
        with open(f"{asc_path}/data.asc","w") as file:
            file.write(" ")
            file.write(str(round(self.t4-self.b,4)))
            # file.write(str(round(0-self.b,2)))
            file.write("\t")
            file.write(str(round(self.Parr,4)))
            file.write("\t")
            file.write(str(round(self.Sarr,4)))
            file.write("\t")
            file.write(str(round(self.t3-self.b,4)))
            # file.write(str(round(self.MAX,2)))
            # file.write("\t")

            # if self.zory == "z":
            #     file.write("z")
            # elif self.zory == "y":
            #     file.write("y")
            file.write("\n")
            for i in range(self.npts1):
                time = (i-1)*self.dt1
                # if time >= 0-self.b: # 0403 PGA case
                if time >= self.t4-self.b and time <= self.t3-self.b: # full wave case
                    file.write(" ")
                    file.write(str(round(time,4)))
                    file.write("   ")
                    try:
                        file.write(str(round(self.yz[i],4)))
                        file.write("   ")
                    except:
                        file.write("0.0000")
                        file.write("   ")
                    
                    try:
                        file.write(str(round(self.y1[i],4)))
                        file.write("   ")
                    except:
                        file.write("0.0000")
                        file.write("   ")

                    try: 
                        file.write(str(round(self.y2[i],4)))
                        file.write("\n")
                    except:
                        file.write("0.0000")
                        file.write("\n")
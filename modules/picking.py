import os
import glob
import pandas as pd
import subprocess
import obspy
from obspy import read
from obspy.clients.fdsn import Client
from obspy import UTCDateTime
from matplotlib import pyplot as plt
from sac2asc import sac2asc
from obspy.io.sac import SACTrace

class picking():
    def __init__(self, sac_path, asc_path):
        os.putenv("SAC_DISPLAY_COPYRIGHT","0")
        self.sac_path = sac_path
        self.asc_path = asc_path

    def sortFile(self, catlog): #TODO
        pass
        # return int(file.split("_")[3]),file.split("_")[1][0]
    def openFile(self, year ,mon ,num):
        files = glob.glob(f"{self.sac_path}/*HLE*.SAC")
        print(files)
        file_names = [os.path.basename(file) for file in files]
        HLE = file_names[0]
        s = f"r {self.sac_path}/{HLE} \n"
        # 畫圖 ＆ 顯示資訊 + pick mode
        s += "qdp of \n"
        s += "ppk m \n"
        s += "w over \n"
        s += "q \n"
        subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(s.encode()) # show the interactivate window

    def checkResult(self, result, read_file_name, check):
        index =  self.num
        if check=="Y" or check=="y": 
            print(f"Accept!! copy! {check}")
            # 存取資訊
            result[f"{index}"] = [read_file_name,"y"]
            # 讀檔（要丟到sac2asc中）
            sac1 = SACTrace.read(f"{HNE}")
            sac2 = SACTrace.read(f"{HNN}")
            sacZ = SACTrace.read(f"{HNZ}")
            zory = "y"
            # print(type(sac1.data[1]))
            # print(sac1.reftime)

            # 改變當前路徑
            os.chdir(f"{asc_path}")
            # 轉出asc檔案
            data = sac2asc(sacZ,sac1,sac2,zory)
            data.__call__()
            os.rename(f'{asc_path}data.asc', f'{asc_path}{read_file_name}.asc')

        elif check=="Z" or check=="z":
            # 同上
            print(f"Accept but Z problem!! copy! {check}")
            result[f"{index}"] = [read_file_name,"z"]
            sac1 = SACTrace.read(f"{HNE}")
            sac2 = SACTrace.read(f"{HNN}")
            sacZ = SACTrace.read(f"{HNZ}")
            zory = "z"
            # print(type(sac1.data[1]))
            # print(sac1.reftime)
            
            os.chdir(f"{asc_path}")
            data = sac2asc(sacZ,sac1,sac2,zory)
            data.__call__()
            os.rename(f'{asc_path}data.asc', f'{asc_path}{read_file_name}.asc')

        # 當判定1-5也要存取輸出檔
        elif check=="1":
            print(f"1 problem!!!")
            result[f"{index}"] = [read_file_name,"1"]
        elif check=="2":
            print(f"2 problem!!!")
            result[f"{index}"] = [read_file_name,"2"]
        elif check=="3":
            print(f"3 problem!!!")
            result[f"{index}"] = [read_file_name,"3"]
        elif check=="4":
            print(f"4 problem!!!")
            result[f"{index}"] = [read_file_name,"4"]
        elif check=="5":
            print(f"5 problem!!!")
            result[f"{index}"] = [read_file_name,"5"]
        else:
            print("NO DEFINE!!!")
            result[f"{index}"] = [read_file_name,"NO DEFINE"]
if __name__=='__main__':
    year = "2021" 
    mon = "05"
    num = 1
    sac_path = f"../TSMIP_Dataset/GuanshanChishangeq"
    asc_path = f"../TSMIP_Dataset/picking_result"

    pick = picking(sac_path, asc_path)
    _ = pick.openFile(year ,mon ,num)

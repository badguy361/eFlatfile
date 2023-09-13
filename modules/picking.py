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
    def __init__(self, sac_path, asc_year_path, asc_path):
        self.sac_path = sac_path
        self.asc_year_path = asc_year_path
        self.asc_path = asc_path
        if not os.path.isdir(self.asc_year_path):
            os.mkdir(self.asc_year_path)
        if not os.path.isdir(self.asc_path):
            os.mkdir(self.asc_path)

    def sortFile(self, catlog): #TODO
        pass
        # return int(file.split("_")[3]),file.split("_")[1][0]
    def openFile(self, year ,mon ,num):
        self.year = year
        self.mon = mon
        self.num = num
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
    sac_path = f"/home/joey/緬甸/dataset/MM_events_20160101-20211026/{year}/{mon}/"
    asc_year_path = f"/home/joey/緬甸/output/{year}"
    asc_path = f"/home/joey/緬甸/output/{year}/{mon}/"


    # 讀入event catalog
    catlog = pd.read_csv("/home/joey/緬甸/merge_event_eq(add_cut_2021).csv")

    # 改變當前路徑
    os.chdir(f"{sac_path}")

    # 讀入所有HNE的資料,主要是獲得檔名
    file_name = glob.glob("*HNE*.sac")
    # file_name.sort(key=sortFile)

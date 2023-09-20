import os
import glob
import pandas as pd
from matplotlib import pyplot as plt
import re
import subprocess
import obspy
from obspy import read
from obspy.clients.fdsn import Client
from obspy import UTCDateTime

from sac2asc import sac2asc
from obspy.io.sac import SACTrace
from data_process import dataProcess


class picking(dataProcess):

    def __init__(self, sac_path, asc_path):
        super().__init__()
        os.putenv("SAC_DISPLAY_COPYRIGHT", "0")
        self.sac_path = sac_path
        self.asc_path = asc_path
        self.result = {}


    def readFile(self, year, mon):
        total_files = glob.glob(f"{self.sac_path}/*HLE*.SAC")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names

    def openFile(self, file_names, num):

        for index, file_name in enumerate(file_names[num - 1::]):
            HLE = file_name
            HLN = re.sub("HLE", "HLN", file_name)
            HLZ = re.sub("HLE", "HLZ", file_name)
            s = f"r {self.sac_path}/{HLZ} \
                {self.sac_path}/{HLE} \
                {self.sac_path}/{HLN} \n"

            # 畫圖 ＆ 顯示資訊 + pick mode
            s += "qdp of \n"
            s += "ppk m \n"
            s += "w over \n"
            s += "q \n"
            subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                s.encode())  # show the interactivate window

            sac1 = SACTrace.read(f"{HLE}")
            sac2 = SACTrace.read(f"{HLN}")
            sacZ = SACTrace.read(f"{HLZ}")
            # print(type(sac1.data[1]))
            # print(sac1.reftime)

    def inputResult(self, file_name, sac1, sac2 , sacZ):
        print("Accept [Y/y] or Accpet but Z [Z/z] or Reject [Others]?")
        check = input()
        if check == "Y" or check == "y":
            print(f"Result : {check}")
            # 存取資訊
            self.result[num] = [file_name, "y"]
            # 讀檔（要丟到sac2asc中）
            zory = "y"

        elif check == "Z" or check == "z":
            print(f"Result : {check}")
            self.result[num] = [file_name, "z"]
            zory = "z"

        # 當判定1-5也要存取輸出檔
        elif check == "1":
            print(f"Result : 1")
            self.result[num] = [file_name, "1"]
        elif check == "2":
            print(f"Result : 2")
            self.result[num] = [file_name, "2"]
        elif check == "3":
            print(f"Result : 3")
            self.result[num] = [file_name, "3"]
        elif check == "4":
            print(f"Result : 4")
            self.result[num] = [file_name, "4"]
        elif check == "5":
            print(f"Result : 5")
            self.result[num] = [file_name, "5"]
        else:
            print("NO DEFINE!!!")
            self.result[num] = [file_name, "NO DEFINE"]
    
    def sacToAsc():
        # 改變當前路徑
        os.chdir(f"{asc_path}")
        # 轉出asc檔案
        data = sac2asc(sacZ, sac1, sac2, zory)
        data.__call__()
        os.rename(f'{asc_path}data.asc', f'{asc_path}{read_file_name}.asc')

if __name__ == '__main__':
    year = "2021"
    mon = "05"
    num = 1
    sac_path = f"../TSMIP_Dataset/GuanshanChishangeq"
    asc_path = f"../TSMIP_Dataset/picking_result"

    pick = picking(sac_path, asc_path)
    file_names = pick.readFile(year, mon)
    _ = pick.openFile(file_names, num)

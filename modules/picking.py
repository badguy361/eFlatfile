import os
import glob
import re
import subprocess
import pandas as pd
from logger import logger
from sac2asc import sac2asc
from obspy.io.sac import SACTrace


class picking():

    def __init__(self, sac_path, asc_path, record, catalog):
        os.putenv("SAC_DISPLAY_COPYRIGHT", "0")
        self.sac_path = sac_path
        self.asc_path = asc_path
        self.record = record
        self.catalog = catalog
        self.result = {}
        self.zory = ''

    def getSACFile(self, year, mon):
        """
            Read all SAC file downloaded from TSMIP
            Output: ['TW.A002.10.HLE.D.20220918144415.SAC', 'TW.A003.10.HLE.D.20220918144415.SAC',...]
        """
        total_files = glob.glob(f"{self.sac_path}/*HLE*.SAC")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names
    
    def getDist(self, sac_HLE):
        """
            Input: sac_HLE = "TW.A002.10.HLE.D.20220918144415.SAC" ; records = record.csv
            Output: sta_dist
        """
        sta_dist = self.record[self.record['file_name'] ==
                               sac_HLE]["sta_dist"].values[0]
        return sta_dist

    def getMw(self, sac_HLE):
        results = pd.merge(self.record,
                           self.catalog,
                           on='event_id',
                           how='inner')
        Mw = results[results['file_name'] == sac_HLE]["Mw"].values[0]
        return Mw


    def inputResult(self, sac_file_name, sac1, sac2, sacZ):
        """
            To determine the output by Y or Z or 1-5
            Input: sac_file_name= "TW.A002.10.HLE.D.20220918144415.SAC"
            Outupt: self.result & self.zory
        """
        logger.info("Accept [Y/y] or Accpet but Z [Z/z] or Reject [Others]?")
        check = input()
        if check == "Y" or check == "y":
            logger.info(f"Result : {check}")
            # 存取資訊
            self.result[num] = [sac_file_name, "y", round(sac1.t4,2), round(sac1.t3), round(sac1.t1) , round(sac1.t2)]
            self.zory = "y"
        elif check == "Z" or check == "z":
            logger.info(f"Result : {check}")
            self.result[num] = [sac_file_name, "z", round(sac1.t4,2), round(sac1.t3), round(sac1.t1) , round(sac1.t2)]
            self.zory = "z"
        elif check == "1":
            logger.info(f"Result : 1")
            self.result[num] = [sac_file_name, "1", None, None, None, None]
        elif check == "2":
            logger.info(f"Result : 2")
            self.result[num] = [sac_file_name, "2", None, None, None, None]
        elif check == "3":
            logger.info(f"Result : 3")
            self.result[num] = [sac_file_name, "3", None, None, None, None]
        elif check == "4":
            logger.info(f"Result : 4")
            self.result[num] = [sac_file_name, "4", None, None, None, None]
        elif check == "5":
            logger.info(f"Result : 5")
            self.result[num] = [sac_file_name, "5", None, None, None, None]
        else:
            logger.info("NO DEFINE!!!")
            self.result[num] = [sac_file_name, "NO DEFINE", None, None, None, None]

    def sacToAsc(self, file_name, sac1, sac2, sacZ, zory):
        """
            To change result sac file to asc file
        """
        data = sac2asc(sacZ, sac1, sac2, zory)
        data.__call__(asc_path)
        os.rename(f'{asc_path}/data.asc', f'{asc_path}/{file_name}.asc')

    def dropDuplicate(self, df):
        # 保留最後的定義
        df = df.drop_duplicates(subset=[0],keep='last', inplace=False)
        # 將資料做排序
        df = df.sort_values(by=[0],ignore_index = True)
        df.to_csv(f"{self.asc_path}/result.csv",header=False,index=False,mode='w')

    def mainProcess(self, sac_file_names, num):
        """
            To open file through SAC package ppk mode
            
            The remove instrument response steps are from CWA website
            ref: https://gdms.cwa.gov.tw/help.php
            Input : sac_file_names= ['TW.A002.10.HLE.D.20220918144415.SAC', ...]
                    instrument_file_names= ['SAC_PZs_TW_A002_HLE_10_2019.051.00.00.00.0000_2599.365.23.59.59.99999', ...]
        """
        try:
            for index, sac_file_name in enumerate(sac_file_names[num - 1::]):
                logger.info(f"{sac_file_name} {index+num}/{len(sac_file_names)}")
                sac_HLE = sac_file_name
                sac_HLN = re.sub("HLE", "HLN", sac_file_name)
                sac_HLZ = re.sub("HLE", "HLZ", sac_file_name)
                Dist = round(self.getDist(sac_file_name), 2)
                Mw = self.getMw(sac_file_name)
                
                s = f"r {self.sac_path}/{sac_HLZ} \
                    {self.sac_path}/{sac_HLE} \
                    {self.sac_path}/{sac_HLN} \n"

                s += "qdp of \n"
                #auto picking
                # s += "p1 \n"
                s += f"title DIST={Dist}_Mw={Mw} Location BOTTOM size large \n"
                s += "ppk m \n"
                # s += "w over \n"
                s += "q \n"
                subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                    s.encode())  # show the interactivate window

                sac1 = SACTrace.read(f"{self.sac_path}/{sac_HLE}")
                sac2 = SACTrace.read(f"{self.sac_path}/{sac_HLN}")
                sacZ = SACTrace.read(f"{self.sac_path}/{sac_HLZ}")
                # print(type(sac1.data[1]))
                # print(sac1.reftime)

                # self.inputResult(sac_file_name, sac1, sac2, sacZ)
                # if self.zory != '':
                #     self.sacToAsc(sac_file_name, sac1, sac2, sacZ, self.zory)
                # logger.info(self.result)

        finally: # 確保臨時中斷也能輸出
            df = pd.DataFrame.from_dict(self.result,orient='index')
            # 轉成csv並加在原有的後面
            df.to_csv(f"{self.asc_path}/result.csv",header=False,index=True,mode='a') 
            df = pd.read_csv(f"{self.asc_path}/result.csv",header=None)
            _ = self.dropDuplicate(df)
            logger.info("finish output!!")

if __name__ == '__main__':
    year = "2021"
    mon = "05"
    num = 1
    sac_path = f"../TSMIP_Dataset/GuanshanChishangeq"
    asc_path = f"../TSMIP_Dataset/picking_result"

    path = "../TSMIP_Dataset"
    record_name = "GDMS_Record.csv"
    catalog_name = "GDMS_catalog.csv"
    records = pd.read_csv(f"{path}/{record_name}")
    catalog = pd.read_csv(f"{path}/{catalog_name}")

    pick = picking(sac_path, asc_path, records, catalog)
    file_names = pick.getSACFile(year, mon)
    _ = pick.mainProcess(file_names, num)

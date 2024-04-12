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
        # total_files = glob.glob(f"{self.sac_path}/*HLE*{year}{mon}*.SAC")
        total_files = glob.glob(f"{self.sac_path}/*.E.*.SAC")
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

    def inputResult(self, num, sac_file_name, sac1, sac2, sacZ):
        """
            To determine the output by Y or Z or 1-5
            Input: sac_file_name= "TW.A002.10.HLE.D.20220918144415.SAC"
            Outupt: self.result: {1: ['TW.A002.10.HLE.D.20220918144415.SAC', 'y', 443.98, 118, 173, 202]}
                    self.zory : "y"
        """
        logger.info("Accept [Y/y] or Accpet but Z [Z/z] or Reject [Others]?")
        check = input()
        if check == "Y" or check == "y":
            logger.info(f"Result : {check}")
            # self.result[num] = [sac_file_name, "y", round(0-sac1.b,2), round(sac1.t1-sac1.b,2) , round(sac1.t2-sac1.b,2), max(round(sac1.depmax,2),round(sac2.depmax,2),round(sacZ.depmax,2))]
            self.result[num] = [sac_file_name, "y", round(sac1.t4-sac1.b,2), round(sac1.t1-sac1.b,2) , round(sac1.t2-sac1.b,2), round(sac1.t3-sac1.b,2)]
            self.zory = "y"
        elif check == "Z" or check == "z":
            logger.info(f"Result : {check}")
            self.result[num] = [sac_file_name, "z", round(sac1.t4-sac1.b,2), round(sac1.t1-sac1.b,2) , round(sac1.t2-sac1.b,2), round(sac1.t3-sac1.b,2)]
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

    def dropDuplicate(self, result):
        """
            To drop duplicate data in the result csv
        """
        result = result.drop_duplicates(subset=["file_name"],keep='last', inplace=False)
        result = result.sort_values(by=["file_name"],ignore_index = True)
        result.to_csv(f"{self.asc_path}/result.csv",index=False,mode='w')

    def mainProcess(self, sac_file_names, num):
        """
            To open file through SAC package ppk mode
            Input : sac_file_names= ['TW.A002.10.HLE.D.20220918144415.SAC', ...]
        """
        try:
            for index, sac_file_name in enumerate(sac_file_names[num - 1::]):
                logger.info(f"{sac_file_name} {index+num}/{len(sac_file_names)}")
                sac_HLE = sac_file_name
                sac_HLN = re.sub(r"\.E\.", ".N.", sac_file_name)
                sac_HLZ = re.sub(r"\.E\.", ".Z.", sac_file_name)
                # sac_HLN = re.sub("HLE", "HLN", sac_file_name)
                # sac_HLZ = re.sub("HLE", "HLZ", sac_file_name)
                # Dist = round(self.getDist(sac_file_name), 2)
                # Mw = self.getMw(sac_file_name)
                
                s = f"r {self.sac_path}/{sac_HLZ} \
                    {self.sac_path}/{sac_HLE} \
                    {self.sac_path}/{sac_HLN} \n"
                s += "qdp of \n"
                s += "p1 \n"
                # s += f"title DIST={Dist}_Mw={Mw} Location BOTTOM size large \n"
                s += "ppk m \n"
                s += "w over \n"
                s += "q \n"
                subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                    s.encode())

                sac1 = SACTrace.read(f"{self.sac_path}/{sac_HLE}")
                sac2 = SACTrace.read(f"{self.sac_path}/{sac_HLN}")
                sacZ = SACTrace.read(f"{self.sac_path}/{sac_HLZ}")
                # print(type(sac1.data[1]))
                # print(sac1.npts)
                # print(sac1.delta)

                self.zory = ''
                self.inputResult(index, sac_file_name, sac1, sac2, sacZ)
                if self.zory == 'y':
                    self.sacToAsc(sac_file_name, sac1, sac2, sacZ, self.zory)
                logger.info(self.result[index])

        finally:
            file_exists = os.path.exists(f"{self.asc_path}/result.csv")
            result = pd.DataFrame.from_dict(self.result,orient='index')
            if not file_exists:
                columns = ["file_name","pick_result","start_time","p_arrival","s_arrival","end_time"]
                # columns = ["file_name","pick_result","start_time","p_arrival","s_arrival","PGA"]
                result.to_csv(f"{self.asc_path}/result.csv",header=columns,index=False,mode='a')
                logger.info("finish add result.csv.")
            else:
                result.to_csv(f"{self.asc_path}/result.csv",header=False,index=False,mode='a')
                check_result = pd.read_csv(f"{self.asc_path}/result.csv")
                _ = self.dropDuplicate(check_result)
                logger.info("finish append result.csv.")

if __name__ == '__main__':
    year = "2022"
    mon = "09"
    num = 1 #395
    sac_path = f"../TSMIP_Dataset/0403/TSMIP_acc_2024Hualien"
    asc_path = f"../TSMIP_Dataset/0403/picking_result"
    record_path = "../TSMIP_Dataset/GDMS_Record.csv"
    catalog_path = "../TSMIP_Dataset/GDMS_catalog.csv"
    records = pd.read_csv(record_path)
    catalog = pd.read_csv(catalog_path)

    pick = picking(sac_path, asc_path, records, catalog)
    file_names = pick.getSACFile(year, mon)
    _ = pick.mainProcess(file_names, num)

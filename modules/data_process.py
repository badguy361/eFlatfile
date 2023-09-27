from obspy.geodetics.base import gps2dist_azimuth, kilometer2degrees
from obspy.taup import TauPyModel
import pandas as pd
from tqdm import tqdm
from datetime import datetime, timedelta
import re
import os
import glob


class SACProcess():

    def __init__(self, sac_path, instrument_path):
        os.putenv("SAC_DISPLAY_COPYRIGHT", "0")
        self.sac_path = sac_path
        self.instrument_path = instrument_path

    def readSACFile(self, sta): # TODO
        total_files = glob.glob(f"{self.sac_path}/*{sta}*HLE*.SAC")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names
    
    def readInstrumentFile(self, sta):
        total_files = glob.glob(f"{self.instrument_path}/*{sta}*HLE*.99999")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names
    
    def reName(self, path, file_name):
        """
            revised formated
            Input : TW.A002.10.HLE.D.2022.260.213900.SAC
            Output : TW.A002.10.HLE.D.20220917213900.SAC
        """
        timestamp = file_name.split('.')[-4:-1]  # date part
        year, day_of_year, time = timestamp
        time = time.zfill(6)
        time = int(time) + 200  # 觀察到mseed轉sac後會少2分鐘
        formatted_timestamp = datetime.strptime(f"{year}{day_of_year}{time}",
                                                "%Y%j%H%M%S")
        converted_timestamp = formatted_timestamp.strftime('%Y%m%d%H%M%S')
        pattern = r'\d{4}\.\d{3}\.\d+'
        new_file_name = re.sub(pattern, converted_timestamp, file_name)
        os.rename(f"{path}/{file_name}", f"{path}/{new_file_name}")
        return new_file_name
    
    def removeInstrumentResponse(self, sac_files, instrument, output):
        for sac_file in sac_files:
            s = f"r {self.sac_path}/{sac_file} \n"
            s += "rmean; rtrend \n"
            s += "taper \n"
            s += f"trans from polezero s {instrument} to acc freq 0.02 0.1 1 10 \n"
            s += f"w {output} \n"

class catalogProcess():

    def __init__(self, catalog):
        self.catalog = catalog

    def GMTtoTaiwanTime(self, date, time):
        """
            To change CWB catalog GMT+0 time to GMT+8 Taiwan time
            Input: 2018/1/101:46:04
            Output: 20180101014604
        """
        date_string = date + 'T' + time
        date_format = "%Y/%m/%dT%H:%M:%S"
        print(date_string)
        formatted_datetime = datetime.strptime(date_string, date_format)
        time_difference = timedelta(hours=8)
        new_datetime = formatted_datetime + time_difference
        new_datetime = new_datetime.strftime('%Y%m%d%H%M%S')
        return new_datetime

    def addTaiwanTime(self, path, new_datetime, catalog_name):
        """
            Add GMT+8 Taiwan time to catalog
        """
        self.catalog["taiwan_time"] = new_datetime
        self.catalog.to_csv(f'{path}/{catalog_name}', index=False)

    def addMw(self, path, new_datetime, catalog_name):
        self.catalog["ML"] = self.catalog["ML"] * 2  # TODO
        self.catalog.to_csv(f'{path}/{catalog_name}', index=False)

    def getArrivalTime(self, catlog, model_name='iasp91'):
        iasp91_P_arrival = []
        iasp91_S_arrival = []
        for i in tqdm(range(catlog.shape[0])):
            try:
                model = TauPyModel(
                    model=model_name)  #ak135 prem jb pwdk can test
                dist = kilometer2degrees(catlog["dist_surface"][i])
                depth = catlog["origins.depth"][i] / 1000
                arrivals = model.get_travel_times\
                    (source_depth_in_km=depth, distance_in_degree=dist,\
                    phase_list=["P","S",'p','s'])
                iasp91_P_arrival.append(arrivals[0].time)
                iasp91_S_arrival.append(arrivals[-1].time)
            except:
                iasp91_P_arrival.append("NA")
                iasp91_S_arrival.append("NA")

        return iasp91_P_arrival, iasp91_S_arrival

    # def updateCatalog(self, catalog, iasp91_P_arrival, iasp91_S_arrival):
    #     catlog["iasp91_P_arrival"] = iasp91_P_arrival
    #     catlog["iasp91_S_arrival"] = iasp91_S_arrival
    #     catlog.to_csv("D:/緬甸BH/merge_event_eq(add_cut_2021).csv",
    #                   index=False,
    #                   mode='w')

    # def mergeTime(self):
    #     new_date = self.catalog['date'].str.replace("/", "")
    #     new_time = self.catalog['time'].str.replace(":", "")
    #     new_eqtime = new_date + new_time
    #     return new_eqtime


class recordProcess():

    def __init__(self):
        # self.path = ""
        pass

    def getRecordDf(self, file_names, catalog):
        """
            To store the SAC file which matched with catalog
        """
        record = {'event_id': [], 'file_name': []}
        for file_name in file_names:
            for index, taiwan_time in enumerate(catalog['taiwan_time']):
                if str(taiwan_time) in file_name:
                    record['event_id'].append(catalog['event_id'][index])
                    record['file_name'].append(file_name)
        return record

    def buildRecordFile(self, record, record_name):
        df_record = pd.DataFrame(record)
        df_record.to_csv(f'{record_name}', index=False)


if __name__ == '__main__':

    # SACProcess
    sac_path = "../TSMIP_Dataset/GuanshanChishangeq"
    instrument_path = "../TSMIP_Dataset/InstrumentResponse"
    sac_process = SACProcess(sac_path, instrument_path)
    sac_files = sac_process.readSACFile("A002")
    instrument_files = sac_process.readInstrumentFile("A002")
    output = "output.sac"
    sac_process.removeInstrumentResponse(sac_files, instrument_files, output)
    # file_names = [sac_process.reName(path, os.path.basename(file)) for file in files]

    # catalogProcess
    # path = "../TSMIP_Dataset"
    # catalog_name = "GDMS_catalog.csv"
    # catalog = pd.read_csv(f"{path}/{catalog_name}")
    # catalog_process = catalogProcess(catalog)
    # new_datetime = []
    # for i in range(catalog.__len__()):
    #     new_datetime.append(
    #         catalog_process.GMTtoTaiwanTime(catalog['date'][i],
    #                                         catalog['time'][i]))
    # _ = catalog_process.addTaiwanTime(path, new_datetime, catalog_name)

    # recordProcess
    # record_process = recordProcess()
    # path = "../TSMIP_Dataset"
    # catalog_name = "GDMS_catalog.csv"
    # catalog = pd.read_csv(f"{path}/{catalog_name}")
    # output_name = "/GDMSRecord_test.csv"
    # files = glob.glob(f"../TSMIP_Dataset/GuanshanChishangeq/*HLE*.SAC")
    # file_names = [os.path.basename(file) for file in files]
    # record = record_process.getRecordDf(file_names, catalog)
    # _ = record_process.buildRecordFile(record, path+output_name)
    # print(record)
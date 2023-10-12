from obspy.geodetics.base import gps2dist_azimuth, kilometer2degrees
from obspy.taup import TauPyModel
import pandas as pd
from tqdm import tqdm
from datetime import datetime, timedelta
import re
import os
import glob
import numpy as np
import subprocess

class SACProcess():

    def __init__(self, sac_path, instrument_path):
        os.putenv("SAC_DISPLAY_COPYRIGHT", "0")
        self.sac_path = sac_path
        self.instrument_path = instrument_path

    def readSACFile(self, read_all=False):
        if read_all == True:
            total_files = glob.glob(f"{self.sac_path}/*HLE*.SAC")
        else:
            total_files = glob.glob(f"{self.sac_path}/*.SAC")

        file_names = [os.path.basename(_) for _ in total_files]
        return file_names
    
    def readInstrumentFile(self, sta):
        """
            Output: ['SAC_PZs_TW_A002_HLE_10_2019.051.00.00.00.0000_2599.365.23.59.59.99999',..]
        """
        total_files = glob.glob(f"{self.instrument_path}/{sta}/*All*.99999")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names
    
    def removeInstrumentResponse(self, sac_file):
        
        # instrument response steps
        s += "rmean; rtrend \n"
        s += "taper \n"
        s += f"trans from polezero s TSMIP.PZs_All.99999 \
                to acc freq 0.02 0.1 1 10 \n"
        # s += "mul 2.45E-6 \n" # 乘常數
        s += "w over \n"
        subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                    s.encode())

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

    def addMw(self, path, catalog_name):
        self.catalog["Mw"] = np.where(
            self.catalog["ML"] > 6.0,
            np.exp((self.catalog["ML"] + 3.131) / 5.115),
            (self.catalog["ML"] - 0.338) / 0.961)
        self.catalog["Mw"] = round(self.catalog["Mw"], 2)
        self.catalog.to_csv(f'{path}/{catalog_name}', index=False)
        #M_L = 0.961M_w+0.338±0.256 (M_L≤6.0)
        #M_L = 5.115 ln⁡(M_w )-3.131±0.379 (M_L≥5.5)
        #鄭世楠等(2010)所建立之芮氏規模與震矩規模轉換關係式進行轉換

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
    
    def getDistance(self, catalog, records, stations):
        tmp = pd.merge(records, catalog, on='event_id', how='inner')
        result = pd.merge(tmp, stations, on='station', how='inner')
        result["sta_dist"] = (((result["longitude"]-result["lon"])*101.7)**2 +  ((result["latitude"]-result["lat"])*110.9)**2 +  (result["depth"]-result["dep"])**2)**(1/2)
        return result["sta_dist"]

    def getArrivalTime(self, catalog, records):
        result = pd.merge(records, catalog, on='event_id', how='inner')
        iasp91_P_arrival = []
        iasp91_S_arrival = []
        for i in tqdm(range(result.shape[0])):
            try:
                model = TauPyModel(model='iasp91') #jb pwdk can test 
                dist = kilometer2degrees(result["sta_dist"][i]) 
                depth = result["depth"][i]
                arrivals = model.get_travel_times\
                    (source_depth_in_km=depth, distance_in_degree=dist,\
                    phase_list=["P","S",'p','s'])
                iasp91_P_arrival.append(arrivals[0].time)
                iasp91_S_arrival.append(arrivals[-1].time)
            except:
                iasp91_P_arrival.append("NA")
                iasp91_S_arrival.append("NA")
        return iasp91_P_arrival, iasp91_S_arrival

    def getRecordDf(self, file_names, catalog):
        """
            To store the SAC file which matched with catalog
            Input : file_names = ['TW.C096.10.HLN.D.20220918145412.SAC',...]
        """
        record = {'event_id': [], 'file_name': [], 'station':[]}
        for file_name in file_names:
            for index, taiwan_time in enumerate(catalog['taiwan_time']):
                if str(taiwan_time) in file_name:
                    record['event_id'].append(catalog['event_id'][index])
                    record['file_name'].append(file_name)
                    record['station'].append(file_name.split('.')[1])
        return record

    def buildRecordFile(self, record, record_name):
        df_record = pd.DataFrame(record)
        df_record.to_csv(f'/{record_name}', index=False)


if __name__ == '__main__':

    # SACProcess
    sac_path = "../TSMIP_Dataset/GuanshanChishangeq/rowdata"
    instrument_path = f"../TSMIP_Dataset/InstrumentResponse"
    sac_process = SACProcess(sac_path, instrument_path)
    
    sac_files = sac_process.readSACFile(read_all=True)
    file_names = [sac_process.reName(sac_path, os.path.basename(file)) for file in sac_files]

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
    # _ = catalog_process.addMw(path, catalog_name)

    # recordProcess
    # record_process = recordProcess()
    # path = "../TSMIP_Dataset"
    # catalog_name = "GDMS_catalog.csv"
    # catalog = pd.read_csv(f"{path}/{catalog_name}")
    # output_name = "GDMS_Record.csv"
    # sac_path = "../TSMIP_Dataset/GuanshanChishangeq/rowdata"
    # sac_process = SACProcess(sac_path)
    # file_names = sac_process.readSACFile()
    # record = record_process.getRecordDf(file_names, catalog)
    # _ = record_process.buildRecordFile(record, path+output_name)

    # stations = [
    #     'A002', 'A003', 'A004', 'A007', 'A008', 'A009', 'A010', 'A013', 'A014',
    #     'A015', 'A016', 'A020', 'A024', 'A025', 'A026', 'A030', 'A032', 'A034',
    #     'A036', 'A037', 'A039', 'A043', 'A044', 'A046', 'A049', 'A051', 'A052',
    #     'A054', 'A057', 'A059', 'A060', 'A061', 'A063', 'A065', 'A066', 'A070',
    #     'A071', 'A076', 'A077', 'A078', 'A079', 'A082', 'A083', 'A084', 'A085',
    #     'A103', 'A107', 'A112', 'A115', 'A124', 'A125', 'A127', 'A128', 'A130',
    #     'A131', 'A134', 'B006', 'B011', 'B012', 'B013', 'B014', 'B016', 'B017',
    #     'B018', 'B019', 'B021', 'B022', 'B023', 'B024', 'B026', 'B027', 'B028',
    #     'B029', 'B030', 'B033', 'B034', 'B035', 'B036', 'B037', 'B039', 'B041',
    #     'B043', 'B045', 'B048', 'B049', 'B051', 'B052', 'B053', 'B059', 'B060',
    #     'B061', 'B062', 'B064', 'B066', 'B068', 'B069', 'B070', 'B071', 'B073',
    #     'B077', 'B078', 'B081', 'B082', 'B084', 'B085', 'B086', 'B090', 'B095',
    #     'B097', 'B099', 'B103', 'B104', 'B107', 'B110', 'B111', 'B112', 'B115',
    #     'B117', 'B118', 'B120', 'B121', 'B123', 'B127', 'B128', 'B129', 'B131',
    #     'B135', 'B136', 'B138', 'B139', 'B143', 'B145', 'B149', 'B162', 'B168',
    #     'B170', 'B171', 'B172', 'B173', 'B174', 'B175', 'B176', 'B177', 'B178',
    #     'B179', 'B180', 'B181', 'B182', 'B184', 'B189', 'B190', 'B200', 'B201',
    #     'B204', 'B207', 'B208', 'B209', 'B210', 'B215', 'B216', 'C001', 'C003',
    #     'C004', 'C005', 'C006', 'C008', 'C010', 'C012', 'C014', 'C015', 'C016',
    #     'C017', 'C021', 'C022', 'C023', 'C024', 'C026', 'C027', 'C029', 'C032',
    #     'C034', 'C035', 'C037', 'C041', 'C043', 'C044', 'C045', 'C047', 'C049',
    #     'C051', 'C053', 'C055', 'C056', 'C058', 'C060', 'C061', 'C062', 'C064',
    #     'C065', 'C066', 'C069', 'C073', 'C074', 'C075', 'C076', 'C077', 'C078',
    #     'C082', 'C084', 'C085', 'C087', 'C088', 'C092', 'C093', 'C094', 'C095',
    #     'C097', 'C098', 'C099', 'C100', 'C102', 'C104', 'C105', 'C106', 'C107',
    #     'C112', 'C113', 'C114', 'C116', 'C118', 'C121', 'C123', 'C124', 'C134',
    #     'C137', 'C138', 'C139', 'C140', 'C141', 'C142', 'C143', 'C144', 'C145',
    #     'C146', 'C150', 'C152', 'C155', 'C156', 'C157', 'C160', 'C161', 'C162',
    #     'D005', 'D008', 'D009', 'D011', 'D012', 'D014', 'D015', 'D017', 'D023',
    #     'D028', 'D029', 'D031', 'D032', 'D033', 'D034', 'D035', 'D039', 'D042',
    #     'D044', 'D046', 'D047', 'D048', 'D049', 'D050', 'D051', 'D054', 'D060',
    #     'D062', 'D063', 'D064', 'D065', 'D066', 'D067', 'D068', 'D069', 'D071',
    #     'D072', 'D074', 'D075', 'D076', 'D077', 'D079', 'D084', 'D086', 'D088',
    #     'D089', 'D090', 'D091', 'D097', 'D103', 'D104', 'D105', 'D106', 'D107',
    #     'D108', 'D109', 'D110', 'D111', 'D112', 'D113', 'D114', 'D115', 'D117',
    #     'D120', 'D122', 'D123', 'D126', 'E004', 'E006', 'E015', 'E022', 'E023',
    #     'E026', 'E033', 'E034', 'E035', 'E037', 'E042', 'E046', 'E049', 'E050',
    #     'E053', 'E059', 'E060', 'E061', 'E062', 'E067', 'E068', 'E069', 'E075',
    #     'E076', 'F002', 'F004', 'F015', 'F019', 'F020', 'F026', 'F028', 'F036',
    #     'F041', 'F042', 'F043', 'F044', 'F045', 'F048', 'F053', 'F054', 'F058',
    #     'F067', 'F068', 'F071', 'F072', 'F073', 'F074', 'F075', 'G001', 'G002',
    #     'G003', 'G014', 'G015', 'G016', 'G017', 'G020', 'G021', 'G022', 'G023',
    #     'G025', 'G026', 'G028', 'G030', 'G032', 'G033', 'G035', 'G036', 'G037',
    #     'G038', 'G041', 'G045', 'G047', 'G048', 'G052', 'G053', 'G055', 'G057',
    #     'G060', 'G061', 'I002', 'J001'
    # ]
    # records = pd.read_csv(f"{path}/{output_name}")
    # stations_name = "GDMS_stations.csv"
    # stations = pd.read_csv(f"{path}/{stations_name}")
    # result = record_process.getDistance(catalog, records, stations)
    # records["sta_dist"] = result
    # iasp91_P_arrival, iasp91_S_arrival = record_process.getArrivalTime(catalog, records)
    # records["iasp91_P_arrival"] = iasp91_P_arrival
    # records["iasp91_S_arrival"] = iasp91_S_arrival
    # _ = record_process.buildRecordFile(records, path+output_name)
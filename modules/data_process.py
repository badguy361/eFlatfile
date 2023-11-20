from obspy.geodetics.base import gps2dist_azimuth, kilometer2degrees
from obspy.taup import TauPyModel
import pandas as pd
from tqdm import tqdm
from datetime import datetime, timedelta
import re
import os
import glob
import subprocess
from logger import logger


class SACProcess():

    def __init__(self, sac_path, instrument_path):
        os.putenv("SAC_DISPLAY_COPYRIGHT", "0")
        self.sac_path = sac_path
        self.instrument_path = instrument_path

    def getSACFile(self, get_all=False):
        if get_all == False:
            total_files = glob.glob(f"{self.sac_path}/*HLE*.SAC")
        else:
            total_files = glob.glob(f"{self.sac_path}/*.SAC")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names

    def getInstrumentFile(self):
        """
            Output: ['SAC_PZs_TW_A002_HLE_10_2019.051.00.00.00.0000_2599.365.23.59.59.99999',..]
        """
        total_files = glob.glob(f"{self.instrument_path}/*All*.99999")
        file_names = [os.path.basename(_) for _ in total_files]
        return file_names

    def removeInstrumentResponse(self, sac_file_names, instrument_file):
        """
            To remove instrument response by instrument file. Please don't remove twice !!!
            The steps are from GDMS website: https://gdms.cwa.gov.tw/help.php
            Note: check if remove instrument response by header-variables: https://seisman.github.io/SAC_Docs_zh/fileformat/header-variables/
        """
        for sac_file_name in sac_file_names:
            s = f"r {self.sac_path}/{sac_file_name}\n"
            s += "rmean; rtrend \n"
            s += "taper \n"
            s += f"trans from polezero s {self.instrument_path}/{instrument_file}\
                    to acc freq 0.02 0.1 1 10 \n"
            s += "w over \n"
            s += "q \n"
            subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                s.encode())
        logger.info("remove finished.")

    def reName(self, path, file_name):
        """
            revised formated
            Input : TW.A002.10.HLE.D.2022.261.064200.SAC
            Output : TW.A002.10.HLE.D.20220918144400.SAC
        """
        timestamp = file_name.split('.')[-4:-1]  # date part
        year, day_of_year, time = timestamp
        formatted_timestamp = datetime.strptime(f"{year}{day_of_year}{time}",
                                                "%Y%j%H%M%S")
        time_difference = timedelta(hours=8, minutes=2)
        formatted_timestamp = formatted_timestamp + time_difference
        converted_timestamp = formatted_timestamp.strftime('%Y%m%d%H%M%S')
        pattern = r'\d{4}\.\d{3}\.\d+'
        new_file_name = re.sub(pattern, converted_timestamp, file_name)
        os.rename(f"{path}/{file_name}", f"{path}/{new_file_name}")
        return new_file_name

    def _getArrivalTime(self, records, sac_HLE):
        """
            To get arrival time from record
        """
        P_arrive = records[records["file_name"] ==
                           sac_HLE]["iasp91_P_arrival"].values[0]+120
        S_arrive = records[records["file_name"] ==
                           sac_HLE]["iasp91_S_arrival"].values[0]+120
        return P_arrive, S_arrive

    def autoPick(self, records, sac_file_names):
        """
            To pick the p and s wave by record data
        """
        for sac_file_name in sac_file_names:
            sac_HLE = sac_file_name
            sac_HLN = re.sub("HLE", "HLN", sac_file_name)
            sac_HLZ = re.sub("HLE", "HLZ", sac_file_name)
            P_arrive, S_arrive = self._getArrivalTime(records, sac_file_name)

            s = f"r {self.sac_path}/{sac_HLZ} \
                {self.sac_path}/{sac_HLE} \
                {self.sac_path}/{sac_HLN} \n"
            s += f"ch t1 {P_arrive} t2 {S_arrive} \n"
            s += "p1 \n"
            s += "w over \n"
            s += "q \n"
            subprocess.Popen(['sac'], stdin=subprocess.PIPE).communicate(
                s.encode())
        logger.info("auto pick finished.")

class recordProcess():

    def __init__(self, gdms_catalog, gcmt_catalog, stations):
        self.gdms_catalog = gdms_catalog
        self.stations = stations
        self.gcmt_catalog = gcmt_catalog

    def getDistance(self, records):
        """
            To calculate the distance between the station and earthquake
            Input : records = Dataframe records csv
            Output : the sta_dist column series
        """
        tmp = pd.merge(records, self.gdms_catalog, on='event_id', how='inner')
        result = pd.merge(tmp, self.stations, on='station', how='inner')
        result["sta_dist"] = (((result["lon_x"]-result["lon_y"])*101.7)**2 + (
            (result["lat_x"]-result["lat_y"])*110.9)**2 + (result["depth"]-result["height"])**2)**(1/2)
        return result["sta_dist"]

    def getArrivalTime(self, records):
        """
            To calculate the arrival time through iasp91 method
            Input : records = Dataframe records csv
            Output : list P_arrival and S_arrival 
        """
        result = pd.merge(records, self.gdms_catalog,
                          on='event_id', how='inner')
        iasp91_P_arrival = []
        iasp91_S_arrival = []
        for i in tqdm(range(result.shape[0])):
            try:
                model = TauPyModel(model='iasp91')  # jb pwdk can test
                dist = kilometer2degrees(result["sta_dist"][i])
                depth = result["depth"][i]
                arrivals = model.get_travel_times(source_depth_in_km=depth, distance_in_degree=dist,
                                                  phase_list=["P", "S", 'p', 's'])
                iasp91_P_arrival.append(arrivals[0].time)
                iasp91_S_arrival.append(arrivals[-1].time)
            except:
                iasp91_P_arrival.append("NA")
                iasp91_S_arrival.append("NA")
        return iasp91_P_arrival, iasp91_S_arrival

    def getFocalMechanism(self, records):
        """
            To get the GCMT Focal mechanism from merged catalog
            Input : records = Dataframe records csv
            Output : the strike dip slip column series
        """
        result = pd.merge(records, self.gcmt_catalog,
                          on='event_id', how='inner')
        return result["strike1"], result["dip1"], result["slip1"], result["strike2"], result["dip2"], result["slip2"]

    def getFnmFrv(self, records):
        def Fnm(value):
            if value == "NULL":
                return "NA"
            elif value > -150 and value < -30:
                return 1
            else:
                return 0

        def Frv(value):
            if value == "NULL":
                return "NA"
            elif value > 30 and value < 150:
                return 1
            else:
                return 0
        records['Fnm_1'] = records['dip1'].apply(lambda x: Fnm(x))
        records['Frv_1'] = records['dip1'].apply(lambda x: Frv(x))
        records['Fnm_2'] = records['dip2'].apply(lambda x: Fnm(x))
        records['Frv_2'] = records['dip2'].apply(lambda x: Frv(x))

        return records['Fnm_1'], records['Frv_1'], records['Fnm_2'], records['Frv_2']

    def getMagnitudes(self, records):
        result = pd.merge(records, self.gdms_catalog,
                          on='event_id', how='inner')
        return result["Mw"], result["ML"]

    def getVs30(self, records):
        result = pd.merge(records, self.stations, on="station", how="inner")
        return result["Vs30"],result["Z1.0"]

    def getRecordDf(self, file_names):
        """
            To store the SAC file which matched with catalog
            Input : file_names = ['TW.C096.10.HLN.D.20220918145412.SAC',...]
        """
        record = {'event_id': [], 'file_name': [], 'station': [], 'year': [
        ], 'month': [], 'day': [], 'hour': [], 'minute': [], 'second': []}
        for file_name in file_names:
            for index, taiwan_time in enumerate(self.gdms_catalog['taiwan_time']):
                if str(taiwan_time) in file_name:
                    record['event_id'].append(
                        self.gdms_catalog['event_id'][index])
                    record['file_name'].append(file_name)
                    record['station'].append(file_name.split('.')[1])
                    record['year'].append(file_name.split('.')[5][0:4])
                    record['month'].append(file_name.split('.')[5][4:6])
                    record['day'].append(file_name.split('.')[5][6:8])
                    record['hour'].append(file_name.split('.')[5][8:10])
                    record['minute'].append(file_name.split('.')[5][10:12])
                    record['second'].append(file_name.split('.')[5][12:14])
        return record

    def buildRecordFile(self, record, record_path):
        df_record = pd.DataFrame(record)
        df_record.to_csv(f'{record_path}', index=False)


if __name__ == '__main__':

    #! SACProcess
    sac_path = "../TSMIP_Dataset/GuanshanChishangeq"
    instrument_path = f"../TSMIP_Dataset/InstrumentResponse/All"
    sac_process = SACProcess(sac_path, instrument_path)

    # ? step-2 remove instrument response
    # sac_files = sac_process.getSACFile(get_all=True)
    # instrument_file = sac_process.getInstrumentFile()
    # sac_process.removeInstrumentResponse(sac_files, instrument_file[0])

    # ? step-3 rename
    # file_names = [sac_process.reName(sac_path, os.path.basename(file)) for file in sac_files]

    #! recordProcess
    stations_path = "../TSMIP_Dataset/TSMIP_stations.csv"
    record_path = "../TSMIP_Dataset/GDMS_Record.csv"
    gdms_catalog_path = "../TSMIP_Dataset/GDMS_catalog.csv"
    gdms_catalog = pd.read_csv(gdms_catalog_path)
    records = pd.read_csv(record_path)
    stations = pd.read_csv(stations_path)
    gcmt_catalog = pd.read_csv("../TSMIP_Dataset/merged_catalog.csv")
    record_process = recordProcess(gdms_catalog, gcmt_catalog, stations)

    # #? step-4 build record csv
    # sac_files = sac_process.getSACFile(get_all=False)
    # record = record_process.getRecordDf(sac_files)
    # _ = record_process.buildRecordFile(record, record_path)

    # #? step-5 merge Magnitudes
    # Mw, ML = record_process.getMagnitudes(records)
    # records["Mw"] = Mw
    # records["ML"] = ML

    # #? step-6 merge Distance
    # result = record_process.getDistance(records)
    # records["sta_dist"] = result

    # #? step-7 merge P S arrival
    # iasp91_P_arrival, iasp91_S_arrival = record_process.getArrivalTime(records)
    # records["iasp91_P_arrival"] = iasp91_P_arrival
    # records["iasp91_S_arrival"] = iasp91_S_arrival

    # #? step-8 merge strike dip slip
    # strike1, dip1, slip1, strike2, dip2, slip2 = record_process.getFocalMechanism(records)
    # records["strike1"] = strike1
    # records["dip1"] = dip1
    # records["slip1"] = slip1
    # records["strike2"] = strike2
    # records["dip2"] = dip2
    # records["slip2"] = slip2

    # #? step-9 calculate Fnm Frv
    # Fnm_1, Frv_1, Fnm_2, Frv_2 = record_process.getFnmFrv(records)
    # records["Fnm_1"] = Fnm_1
    # records["Frv_1"] = Frv_1
    # records["Fnm_2"] = Fnm_2
    # records["Frv_2"] = Frv_2

    # #? step-10 merge Vs30
    vs30, z1_0 = record_process.getVs30(records)
    records["Vs30"] = vs30
    records["Z1.0"] = z1_0
    _ = record_process.buildRecordFile(records, record_path)

    # ? step-10 auto pick
    # records = pd.read_csv(record_path)
    # sac_files = sac_process.getSACFile(get_all=False)
    # sac_process.autoPick(records, sac_files)

from obspy.geodetics.base import gps2dist_azimuth, kilometer2degrees
from obspy.taup import TauPyModel
import pandas as pd
from tqdm import tqdm
from matplotlib import pyplot as plt
import numpy as np
from datetime import datetime
import re
import os
import glob

class dataProcess():
    def __init__(self):
        pass
    
    def reName(self, path, file_name):
        """
            revised formated
            Before : TW.A002.10.HLE.D.2022.260.213900.SAC
            After : TW.A002.10.HLE.D.20220917213900.SAC
        """
        timestamp = file_name.split('.')[-4:-1] # date part
        year, day_of_year, time = timestamp
        time = time.zfill(6)
        formatted_timestamp = datetime.strptime(f"{year}{day_of_year}{time}", "%Y%j%H%M%S")
        converted_timestamp = formatted_timestamp.strftime('%Y%m%d%H%M%S')
        pattern = r'\d{4}\.\d{3}\.\d+'
        new_file_name = re.sub(pattern, converted_timestamp, file_name)
        os.rename(f"{path}/{file_name}",f"{path}/{new_file_name}")
        return new_file_name
    
    def getArrivalTime(self, catlog ,model_name='iasp91'):
        iasp91_P_arrival = []
        iasp91_S_arrival = []
        for i in tqdm(range(catlog.shape[0])):
            try:
                model = TauPyModel(model=model_name) #ak135 prem jb pwdk can test 
                dist = kilometer2degrees(catlog["dist_surface"][i]) 
                depth = catlog["origins.depth"][i]/1000 
                arrivals = model.get_travel_times\
                    (source_depth_in_km=depth, distance_in_degree=dist,\
                    phase_list=["P","S",'p','s'])
                iasp91_P_arrival.append(arrivals[0].time)
                iasp91_S_arrival.append(arrivals[-1].time)
            except:
                iasp91_P_arrival.append("NA")
                iasp91_S_arrival.append("NA")
        
        return iasp91_P_arrival, iasp91_S_arrival
    
    def updateCatalog(self, catalog, iasp91_P_arrival, iasp91_S_arrival):
        catlog["iasp91_P_arrival"] = iasp91_P_arrival
        catlog["iasp91_S_arrival"] = iasp91_S_arrival
        catlog.to_csv("D:/緬甸BH/merge_event_eq(add_cut_2021).csv",index=False,mode='w')


if __name__ == '__main__':
    data = dataProcess()
    path = "../TSMIP_Dataset/GuanshanChishangeq"
    files = glob.glob(f"{path}/*.SAC")
    file_names = [data.reName(path, os.path.basename(file)) for file in files]
    # new_file_name = data.reName(file_names)
    print(file_names)

    
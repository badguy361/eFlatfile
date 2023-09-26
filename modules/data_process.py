from obspy.geodetics.base import gps2dist_azimuth, kilometer2degrees
from obspy.taup import TauPyModel
import pandas as pd
from tqdm import tqdm
from matplotlib import pyplot as plt
import numpy as np

class AutoPickModel():
    def __init__(self):
        pass

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
    catlog = pd.read_csv("D:/緬甸BH/merge_event_eq(add_cut_2021).csv")
    
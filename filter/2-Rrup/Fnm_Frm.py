import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
df = pd.read_csv('../1-Flatfile/sgm.2021.rec.csv')
df = df.fillna('na')
# df['GCMT_Dip1'] = df['GCMT_Dip1'].fillna("na")
# df['GCMT_Dip2'] = df['GCMT_Dip2'].fillna("na")
def Fnm(value):
    if value == "na":
        return "NA"
    elif value>-150 and value<-30:
        return 1
    else:
        return 0

def Frv(value):
    if value == "na":
        return "NA"
    elif value>30 and value<150:
        return 1
    else:
        return 0
df['Fnm_1'] = df['GCMT_Dip1'].apply(lambda x:Fnm(x))
df['Frv_1'] = df['GCMT_Dip1'].apply(lambda x:Frv(x))
df['Fnm_2'] = df['GCMT_Dip2'].apply(lambda x:Fnm(x))
df['Frv_2'] = df['GCMT_Dip2'].apply(lambda x:Frv(x))

df.to_csv('sgm.2021_Frv_Fnm.rec.csv',index=False)









# from obspy.clients.fdsn import Client
# from obspy import UTCDateTime
# client = Client("IRIS")
# t1 = UTCDateTime("2016-10-01T00:00:00")
# t2 = UTCDateTime("2016-10-01T06:00:00")
# cat = client.get_events(starttime=t1,endtime=t2)
# cat
# smi:service.iris.edu/fdsnws/event/1/query?originid=14205422
# smi:service.iris.edu/fdsnws/event/1/query?eventid=5182994
# smi:service.iris.edu/fdsnws/event/1/query?magnitudeid=179516164
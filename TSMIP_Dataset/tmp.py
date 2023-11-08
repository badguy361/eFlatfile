import pandas as pd
from datetime import datetime
gcmt=pd.read_csv("GCMT_catalog.csv")
gdms=pd.read_csv("GDMS_catalog.csv")

gcmt['centroid_time'].apply(lambda x: datetime.strptime(x, '%H:%M:%S'))
gdms['time'].apply(lambda x: datetime.strptime(x, '%H:%M:%S'))

time_str1 = gcmt['date'] + 'T' + gcmt['centroid_time']
time_str2 = gdms['date'] + 'T' + gdms['time']

s1_datetime = pd.to_datetime(time_str1)
s2_datetime = pd.to_datetime(time_str2)

time_difference = (s1_datetime - s2_datetime).apply(lambda x: x.seconds)

cross_join = gdms.merge(gcmt, how='cross')


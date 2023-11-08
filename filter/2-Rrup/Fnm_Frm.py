import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
df = pd.read_csv('../1-Flatfile/sgm.2016.rec.csv')
def Fnm(value):
    if value == "NULL":
        return "NA"
    elif value>-150 and value<-30:
        return 1
    else:
        return 0

def Frv(value):
    if value == "NULL":
        return "NA"
    elif value>30 and value<150:
        return 1
    else:
        return 0
df['Fnm_1'] = df['dip1'].apply(lambda x:Fnm(x))
df['Frv_1'] = df['dip1'].apply(lambda x:Frv(x))
df['Fnm_2'] = df['dip2'].apply(lambda x:Fnm(x))
df['Frv_2'] = df['dip2'].apply(lambda x:Frv(x))

df.to_csv('sgm.2021_Frv_Fnm.rec.csv',index=False)




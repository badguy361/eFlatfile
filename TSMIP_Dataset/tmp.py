import pandas as pd

df=pd.read_csv("GDMS_stations.csv")

df["station"] = df["station"].str.slice(0, 4)

df.to_csv("GDMS_stations.csv",index=False)
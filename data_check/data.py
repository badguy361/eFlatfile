import matplotlib as plt
import pandas as pd
import pygmt
df=pd.read_csv("GCMT_catalog.csv")
condition1 = "2021/6/8"
condition2 = "05:40:05"
filter_data=df[(df["date"]==condition1) & (df["time"]==condition2)].head()

fig = pygmt.Figure()
# region = [119.5, 122.5, 21.5, 25.5] # gcmt search range
region = [118, 126, 20, 26] # gdms search range
fig.basemap(region=region,
            projection="M12c",
            frame=["af", f"WSne+t{filter_data['date'].iloc[0]}_{filter_data['time'].iloc[0]}"])
fig.coast(land="gray", water="gray")
fig.plot(x=filter_data["lon"], y=filter_data["lat"], style="kstar4/0.3c",color="red")
fig.coast(shorelines="1p,black")
fig.savefig(f"1.png", dpi=300)
fig.show()


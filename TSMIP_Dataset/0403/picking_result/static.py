import numpy as np
import pandas as pd
result = pd.read_csv("result.csv")
choose_file = result.loc[result["pick_result"] == "y"].copy()
choose_file["station"] = choose_file["file_name"].apply(
    lambda x: x.split(".")[-6])
choose_file["PGA"] = choose_file["PGA"]/980

TSMIP_stations = pd.read_csv("TSMIP_stations.csv")

merged = pd.merge(choose_file[['station', 'PGA']],
                  TSMIP_stations[['station', 'lon', 'lat']], on='station', how='left')

merged.to_csv("merged.csv", index=False)
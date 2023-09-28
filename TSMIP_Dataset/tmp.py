import pandas as pd

df=pd.read_csv("GDMS_Record_test.csv")

file=df["file_name"]

sta_list = []
for i in file:
    sta_list.append(i.split(".")[1])

sta_str = ', '.join(sta_list)
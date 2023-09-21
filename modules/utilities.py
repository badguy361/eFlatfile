import re
import pandas as pd

def setUpTimelist(catalog):
    date = catalog["date"].values
    time = catalog["time"].values
    combined_list = [f"{d}T{t}" for d, t in zip(date, time)]
    combined_string = '\\n'.join(combined_list)

    with open('../config_template.yml', 'r') as file:
        lines = file.readlines()

    for i, line in enumerate(lines):
        if re.search(r'timelist:*', line):
            lines[i] = f"\t\t'timelist': \"{combined_string}\",\n"
            
    with open('../config.yml', 'w') as file:
        file.writelines(lines)

catalog = pd.read_csv("../TSMIP_Dataset/GDMScatalog_test.csv")
_ = setUpTimelist(catalog)
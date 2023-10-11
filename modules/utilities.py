import re
import pandas as pd
import tarfile
import glob
import os

def setUpTimelist(catalog):
    """
        set up time list in yml file which base on config_template.yml
        Input: catalog.csv
        Output: config.yml
    """
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

def auto_unzip(zipdata, unzip_path):
    """
        To unzip total instrumentResponse file which download from GDSN website
        Input :      
            zipdatas = glob.glob(f"../TSMIP_Dataset/InstrumentResponse/rowdata/*.tgz")
            unzip_path = '../TSMIP_Dataset/InstrumentResponse'
    """
    with tarfile.open(zipdata, 'r:gz') as tar:
        tar.extractall(unzip_path)

if __name__ == '__main__':
    # catalog = pd.read_csv("../TSMIP_Dataset/GDMScatalog_test.csv")
    # _ = setUpTimelist(catalog)

    zipdatas = glob.glob(f"../TSMIP_Dataset/InstrumentResponse/rowdata/*.tgz")
    unzip_path = '../TSMIP_Dataset/InstrumentResponse'
    for zipdata in zipdatas:
        _ = auto_unzip(zipdata, unzip_path)

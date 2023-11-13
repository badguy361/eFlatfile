import requests
from config import config
from logger import logger
from dotenv import load_dotenv
from urllib.parse import urlsplit
import pandas as pd
import os
import glob
import numpy as np


class afterPickProcess():
    def __init__(self, record_path, pick_result) -> None:
        self.record_path = record_path
        self.record = pd.read_csv(record_path)
        self.pick_result = pick_result

    def mergePick(self):
        self.record = self.record.merge(
            self.pick_result, on="file_name", how="left")
        self.record.to_csv(self.record_path, index=False, na_rep='NA')

    def addFilterID(self):
        """
            To add filter_id follow by save column
        """
        self.record['filter_id'] = np.nan
        number_of_updates = self.record.loc[self.record['save']
                                            == 'y', 'filter_id'].shape[0]
        new_ids = ['B{:05d}'.format(i)
                   for i in range(1, number_of_updates + 1)]
        self.record.loc[self.record['save'] == 'y', 'filter_id'] = new_ids
        self.record.to_csv(self.record_path, index=False, na_rep='NA')

    def removeNofilter(self):
        self.record.dropna().to_csv(self.record_path, index=False)


if __name__ == '__main__':
    record_path = "../TSMIP_Dataset/GDMS_Record.csv"
    pick_result = pd.read_csv("../TSMIP_Dataset/picking_result/09/result.csv")
    merge = afterPickProcess(record_path, pick_result)
    # _ = merge.mergePick()
    # _ = merge.addFilterID()
    _ = merge.removeNofilter()

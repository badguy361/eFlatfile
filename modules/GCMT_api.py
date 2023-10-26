import requests
from config import config
from logger import logger
import obspy
import os
from dotenv import load_dotenv
import csv
from bs4 import BeautifulSoup
import re
from urllib.parse import urlsplit
import csep


class GCMT():
    """
        A class for interacting with the GCMT API and its following process.
    """

    def __init__(self):
        self.api_url = config.get("GCMT_api_url")
        self.output_path = config.get("download_path")
    
    def getCatalog(self, year ,month):
        get_catalog_url = f"{self.api_url}/{year}/{month}.ndk"
        cat = requests.get(get_catalog_url)
        # cat = obspy.read_events(get_catalog_url)
        return cat


if __name__ == '__main__':
    gcmt = GCMT()
    cat = gcmt.getCatalog(2023,"mar23")
    print(cat)
    with open("test.ndk","w") as f:
        f.write(cat.text)
    ccc=csep.load_catalog("test.ndk")
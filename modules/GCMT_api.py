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

    def getCatalog(self):
        catalog_condition = config.get("gcmt_catalog_range")
        itype = catalog_condition.get("itype")
        yr = catalog_condition.get("yr")
        mo = catalog_condition.get("mo")
        day = catalog_condition.get("day")
        otype = catalog_condition.get("otype")
        oyr = catalog_condition.get("oyr")
        omo = catalog_condition.get("omo")
        oday = catalog_condition.get("oday")
        jyr = catalog_condition.get("jyr")
        jday = catalog_condition.get("jday")
        ojyr = catalog_condition.get("ojyr")
        ojday = catalog_condition.get("ojday")
        nday = catalog_condition.get("nday")
        lmw = catalog_condition.get("lmw")
        umw = catalog_condition.get("umw")
        lms = catalog_condition.get("lms")
        ums = catalog_condition.get("ums")
        lmb = catalog_condition.get("lmb")
        umb = catalog_condition.get("umb")
        llat = catalog_condition.get("llat")
        ulat = catalog_condition.get("ulat")
        llon = catalog_condition.get("llon")
        ulon = catalog_condition.get("ulon")
        lhd = catalog_condition.get("lhd")
        uhd = catalog_condition.get("uhd")
        lts = catalog_condition.get("lts")
        uts = catalog_condition.get("uts")
        lpe1 = catalog_condition.get("lpe1")
        upe1 = catalog_condition.get("upe1")
        lpe2 = catalog_condition.get("lpe2")
        upe2 = catalog_condition.get("upe2")
        list = catalog_condition.get("list")
        get_catalog_url = f"{self.api_url}/cgi-bin/globalcmt-cgi-bin/CMT5/form?itype={itype}&yr={yr}&mo={mo}&day={day}&otype={otype}&oyr={oyr}&omo={omo}&oday={oday}&jyr={jyr}&jday={jday}&ojyr={ojyr}&ojday={ojday}&nday={nday}&lmw={lmw}&umw={umw}&lms={lms}&ums={ums}&lmb={lmb}&umb={umb}&llat={llat}&ulat={ulat}&llon={llon}&ulon={ulon}&lhd={lhd}&uhd={uhd}&lts={lts}&uts={uts}&lpe1={lpe1}&upe1={upe1}&lpe2={lpe2}&upe2={upe2}&list={list}"

        cat = requests.get(get_catalog_url)
        return cat


if __name__ == '__main__':
    gcmt = GCMT()
    cat = gcmt.getCatalog()
    print(cat)

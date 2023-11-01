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
import json
import time

class GCMT():
    """
        A class for interacting with the GCMT API and its following process.
    """

    def __init__(self):
        self.api_url = config.get("GCMT_api_url")
        self.output_path = config.get("download_path")

    def getAllCatalog(self, _next = True, next_page = None):
        """
            Input: _next -> To check if need to keep iterate
                next_page -> To check if result have next page 
                next_page = http://www.globalcmt.org/cgi-bin/globalcmt-cgi-bin/CMT5/form?itype=ymd&yr=2022&mo=1&day=1&otype=ymd&oyr=2022&omo=4&oday=1&jyr=1976&jday=1&ojyr=1976&ojday=1&nday=1&lmw=0&umw=10&lms=0&ums=10&lmb=0&umb=10&llat=21.5&ulat=26&llon=119&ulon=123&lhd=0&uhd=1000<s=-9999&uts=9999&lpe1=0&upe1=90&lpe2=0&upe2=90&list=0&start=60249
        """
        total_data = []
        while(_next):
            time.sleep(0.2)
            cat = self._getCatalog(next_page)
            json_data, next_page = self._parserGCMT(cat.text)
            total_data = total_data + json_data
            if next_page == None:
                _next = False
        return total_data

    def _getCatalog(self, next_page=None):
        """
            Input: next_page: check if it have another page
            yr mo day 起始年月日
            oyr omo oday 結束年月日
            llat ulat llon ulon lhd uhd 經緯深範圍
            其餘參數參閱 https://www.globalcmt.org/CMTsearch.html
        """
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
        _list = catalog_condition.get("list")

        if next_page:
            get_catalog_url = next_page
        else:
            get_catalog_url = f"{self.api_url}/cgi-bin/globalcmt-cgi-bin/CMT5/form?itype={itype}&yr={yr}&mo={mo}&day={day}&otype={otype}&oyr={oyr}&omo={omo}&oday={oday}&jyr={jyr}&jday={jday}&ojyr={ojyr}&ojday={ojday}&nday={nday}&lmw={lmw}&umw={umw}&lms={lms}&ums={ums}&lmb={lmb}&umb={umb}&llat={llat}&ulat={ulat}&llon={llon}&ulon={ulon}&lhd={lhd}&uhd={uhd}&lts={lts}&uts={uts}&lpe1={lpe1}&upe1={upe1}&lpe2={lpe2}&upe2={upe2}&list={_list}"
        cat = requests.get(get_catalog_url)
        return cat

    def _parserGCMT(self, cat):
        parser = BeautifulSoup(cat, 'html.parser')
        gcmt_info = parser.find_all("pre")
        next_page = parser.select_one('hr + h2 > a')
        next_page_url = next_page.get('href') if next_page else None

        keys = [
            "date", "centroid_time", "lat", "lon", "depth", "half_duration",
            "centroid_time_minus_hypocenter_time", "mw", "mb", "ms",
            "scalar_moment", "strike1", "dip1", "slip1", "strike2", "dip2",
            "slip2"
        ]
        date = []
        centroid_time = []
        lat = []
        lon = []
        depth = []
        half_duration = []
        centroid_time_minus_hypocenter_time = []
        mw = []
        mb = []
        ms = []
        scalar_moment = []
        strike1 = []
        dip1 = []
        slip1 = []
        strike2 = []
        dip2 = []
        slip2 = []

        for i in gcmt_info[1:]:
            date_match = re.search(r"Date:\s*(\d{4}/\s*\d{1,2}/\s*\d{1,2})",
                                   i.text)
            centroid_time_match = re.search(
                r'(\d+:\s?\d+:\s?\d+(\.\d+)?)', i.text)
            lat_match = re.search(r"Lat=\s*([-\d\.]+)", i.text)
            lon_match = re.search(r"Lon=\s*([-\d\.]+)", i.text)
            depth_match = re.search(r"Depth=\s*([\d\.]+)", i.text)
            half_duration_match = re.search(r"Half duration=\s*([\d\.]+)",
                                            i.text)
            centroid_time_minus_hypocenter_time_match = re.search(
                r"Centroid time minus hypocenter time:\s*(\d{1,2}\.\d{1,2})",
                i.text)
            mw_match = re.search(r"Mw =\s*([\d\.]+)", i.text)
            mb_match = re.search(r"mb =\s*([\d\.]+)", i.text)
            ms_match = re.search(r"Ms =\s*([\d\.]+)", i.text)
            scalar_moment_match = re.search(r"Scalar Moment =\s*([\d\.e\+]+)",
                                            i.text)
            strike1_match = re.findall(r"strike=([-\d\.]+)", i.text)[0]
            dip1_match = re.findall(r"dip=\s*([-\d\.]+)", i.text)[0]
            slip1_match = re.findall(r"slip=\s*([-\d\.]+)", i.text)[0]
            strike2_match = re.findall(r"strike=([-\d\.]+)", i.text)[1]
            dip2_match = re.findall(r"dip=\s*([-\d\.]+)", i.text)[1]
            slip2_match = re.findall(r"slip=\s*([-\d\.]+)", i.text)[1]

            date.append(date_match.group(1)) if date_match else None
            centroid_time.append(
                centroid_time_match.group(1)) if centroid_time_match else None
            lat.append(lat_match.group(1)) if lat_match else None
            lon.append(lon_match.group(1)) if lon_match else None
            depth.append(depth_match.group(1)) if depth_match else None
            half_duration.append(
                half_duration_match.group(1)) if half_duration_match else None
            centroid_time_minus_hypocenter_time.append(
                centroid_time_minus_hypocenter_time_match.group(
                    1)) if centroid_time_minus_hypocenter_time_match else None
            mw.append(mw_match.group(1)) if mw_match else None
            mb.append(mb_match.group(1)) if mb_match else None
            ms.append(ms_match.group(1)) if ms_match else None
            scalar_moment.append(
                scalar_moment_match.group(1)) if scalar_moment_match else None
            strike1.append(strike1_match) if strike1_match else None
            dip1.append(dip1_match) if dip1_match else None
            slip1.append(slip1_match) if slip1_match else None
            strike2.append(strike2_match) if strike2_match else None
            dip2.append(dip2_match) if dip2_match else None
            slip2.append(slip2_match) if slip2_match else None

        data = [{
            "date": date,
            "centroid_time": centroid_time,
            "lat": lat,
            "lon": lon,
            "depth": depth,
            "half_duration": half_duration,
            "centroid_time_minus_hypocenter_time":
            centroid_time_minus_hypocenter_time,
            "mw": mw,
            "mb": mb,
            "ms": ms,
            "scalar_moment": scalar_moment,
            "strike1": strike1,
            "dip1": dip1,
            "slip1": slip1,
            "strike2": strike2,
            "dip2": dip2,
            "slip2": slip2
        } for date, centroid_time, lat, lon, depth, half_duration,
                centroid_time_minus_hypocenter_time, mw, mb, ms, scalar_moment,
                strike1, dip1, slip1, strike2, dip2, slip2 in zip(
                    date, centroid_time, lat, lon, depth, half_duration,
                    centroid_time_minus_hypocenter_time, mw, mb, ms,
                    scalar_moment, strike1, dip1, slip1, strike2, dip2, slip2)]
        return data, next_page_url

    def catalogToCsv(self, json_data, csv_output_name):
        """
            Transform GCMT json catalog to csv file
            Input: [{'event_id': 101072,
                    'date': '2018-01-31',
                    'time': '23:59:44.49',...
                    },...]
            Output: csv file
        """
        columns = ['date', 'centroid_time', 'lat', 'lon', 'depth', 'half_duration',
                'centroid_time_minus_hypocenter_time', 'mw', 'mb', 'ms', 'scalar_moment',
                'strike1', 'dip1', 'slip1', 'strike2', 'dip2', 'slip2']
        with open(csv_output_name, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=columns)
            writer.writeheader()
            for row in json_data:
                writer.writerow(row)


if __name__ == '__main__':
    catalog_path = '../TSMIP_Dataset/GCMT_catalog.csv'
    gcmt = GCMT()
    total_data = gcmt.getAllCatalog()
    gcmt.catalogToCsv(total_data, catalog_path)
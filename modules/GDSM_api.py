import requests
from config import config
from logger import logger
import os
from dotenv import load_dotenv
import csv
from bs4 import BeautifulSoup
import re
from urllib.parse import urlsplit

load_dotenv()

# retur = rs.get("https://gdmsn.cwb.gov.tw/eqconDownload.php")
# cookies = retur.cookies
# cookie_value = cookies.get('PHPSESSID')
# print(retur.text)

class GDMS():
    """
        A class for interacting with the GDMS API and its following process.
    """

    def __init__(self):
        """
            Initialize the GDMS instance.
        """
        self.api_url = config.get("GDMS_api_url")
        self.output_path = config.get("download_path")
        self._login()

    def _login(self):
        """
            Log in to the GDMS API and set the authorization token in the request headers.
        """
        login_url = f"{self.api_url}/php/loginProcess.php"
        login_data = {
            "username": os.getenv("GDMS_ACCOUNT"),
            "password": os.getenv("GDMS_PASSWORD")
        }
        try:
            self.rs = requests.session()
            response = self.rs.post(
                login_url, data=login_data
            )  #login logic: After login it will set up the session id in this machine, and it could login through this info
            if response.status_code == 200:
                logger.info("Logged in to GDMS")
            elif response.status_code != 200:
                logger.error(response.status_code)
                logger.error("Login failed, please check login information")
        except:
            logger.error("Login failed, please check base setting")

    def getWaveform(self):
        """
            Get special condition date waveform through api
        """
        get_waveform_url = f"{self.api_url}/php/sendEqdownload.php"
        eq_condition = config.get("eq_condition")
        try:
            response = self.rs.post(get_waveform_url, data=eq_condition)
            if response.json()["status"] == 1:
                logger.info(
                    "Get waveform successed, please check infomation in GDMS website"
                )
            else:
                logger.error(
                    "Get waveform failed, please check get waveform information"
                )
        except:
            logger.error("Get waveform failed, please check base setting")

    def getCatalog(self):
        """
            Get CWB catalog through api
        """
        get_catalog_url = f"{self.api_url}/php/dbconnect/getCatalog.php"
        catalog_range = config.get("catalog_range")

        try:
            eq_catalog = self.rs.post(get_catalog_url, data=catalog_range)
            if eq_catalog.status_code == 200:
                logger.info(
                    "Get catalog successed, please check infomation in GDMS website"
                )
                return eq_catalog.json()
        except:
            logger.error("Get waveform failed")

    def catalogToCsv(self, json_data, csv_output_name):
        """
            Transform CWB json catalog to csv file
            Input: [{'event_id': 101072,
                    'date': '2018-01-31',
                    'time': '23:59:44.49',...
                    },...]
            Output: csv file
        """
        columns = ['event_id', 'date', 'time', 'ms', 'latitude', 'longitude', 'depth', 'ML',\
                    'nstn', 'dmin', 'gap', 'trms', 'ERH', 'ERZ', 'fixed', 'nph', 'quality']
        with open(csv_output_name, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=columns)
            writer.writeheader()
            for row in json_data:
                writer.writerow(row)

    def getInstrumentResponse(self):
        """
            Get Instrument Response through api
        """
        get_catalog_url = f"{self.api_url}/php/sendRespDownload.php"
        instrument_response = config.get("instrument_response")
        try:
            results = self.rs.post(get_catalog_url,
                                    data=instrument_response)
            if results.status_code == 200:
                logger.info(
                    "Get instrument response successed, please check infomation in GDMS website"
                )
        except:
            logger.error("Get instrument response failed")

    def getDownloadPage(self):
        """
            To get download Page
        """
        download_url = f"{self.api_url}/php/dbconnect/getMemberDownList.php"
        response = self.rs.get(download_url)
        if response.status_code == 200:
            return response.json()
        else:
            logger.info('URL wrong')

    def getDownUrl(self, result, date):
        """
            To get download link from download page
            Input: [{'script': {'zh': '地震 (儀器響應檔)', 'en': 'Seismic (Responds)'},
                    'datetime': '2023-10-14 16:56:23',
                    ...
                    'show_status': '<a href="./userdata/3ef24bbfa8abe4f408a52ad299e582d7/All.tgz" target="_blank">All.tgz</a>'
                    },
                    {...},
                    ]
            Output: [./userdata/3ef24bbfa8abe4f408a52ad299e582d7/All.tgz, ...]
        """
        total_url = []
        matching_entries = [entry for entry in result if re.match(fr'{date}', entry['datetime'])]
        for matching_entry in matching_entries:
            parser = BeautifulSoup(matching_entry['show_status'], 'html.parser')
            url = parser.find("a").get('href')
            total_url.append(url)
        return total_url
    
    def autoDownloadData(self, total_url, file_path):
        """
            To download data from the download link
            Input: [./userdata/3ef24bbfa8abe4f408a52ad299e582d7/All.tgz, ...]
        """
        for url in total_url:
            file_name = urlsplit(url).path.split("/")[-1] # To get file name from the url
            download_link = self.api_url + url[1:]
            response = requests.get(download_link)
            with open(file_path+file_name, 'wb') as file:
                file.write(response.content)

if __name__ == '__main__':
    gdms = GDMS()
    eq_catalog = gdms.getCatalog()
    # catalog_path = '../TSMIP_Dataset/GDMS_catalog.csv'
    # _ = gdms.catalogToCsv(eq_catalog, catalog_path)
    # _ = gdms.getWaveform()
    # _ = gdms.getInstrumentResponse()

    # file_path = "../TSMIP_Dataset/"
    # result = gdms.getDownloadPage()
    # date = '2023-10-14'
    # total_url = gdms.getDownUrl(result, date)
    # _ = gdms.autoDownloadData(total_url, file_path)
    

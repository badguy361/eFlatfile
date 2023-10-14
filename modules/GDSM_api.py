import requests
import pandas as pd
from config import config
from logger import logger
import os
from dotenv import load_dotenv
import pandas as pd
import csv
from bs4 import BeautifulSoup
import re
import time
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
        self.api_url = config.get("api_url")
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

    def catalogToCsv(self, list_data, csv_output_name):
        """
            Transform CWB json catalog to csv file
            Input: list record
            Output: csv file
        """
        columns = ['event_id', 'date', 'time', 'ms', 'latitude', 'longitude', 'depth', 'ML',\
                    'nstn', 'dmin', 'gap', 'trms', 'ERH', 'ERZ', 'fixed', 'nph', 'quality']
        with open(csv_output_name, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=columns)
            writer.writeheader()
            for row in list_data:
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

    def getDownloadUrl(self, html_file, download_time):
        """
            To get download zip link from html file
            Input : html file which download from GDMS website
            Output : download zip link
        """
        with open(html_file, 'r', encoding='utf-8') as file:
            html_content = file.read()
        soup = BeautifulSoup(html_content, 'html.parser')

        pattern = re.compile(fr'{download_time}')  #查詢<td>條件
        td_elements = soup.find_all('td', string=pattern)
        link_elements = []
        for td_element in td_elements:
            try:
                link_element = td_element.find_next_siblings('td')[1].find(
                    'a', href=True)['href']  # 取得url
                link_elements.append(self.api_url + link_element[1:])
            except:
                pass
        return link_elements

    def downloadData(self, download_link, output_name):
        """
            To download infomation from download link
        """
        response = self.rs.get(download_link)
        if response.status_code == 200:
            with open(f'{self.output_path}/InstrumentResponse/{output_name}', 'wb') as file:
                file.write(response.content)
            logger.info('Download successed')
        else:
            logger.info('URL wrong')


if __name__ == '__main__':
    gdms = GDMS()
    # eq_catalog = gdms.getCatalog()
    # _ = gdms.catalogToCsv(eq_catalog, '../TSMIP_Dataset/GDMS_catalog.csv')

    # _ = gdms.getWaveform()
    _ = gdms.getInstrumentResponse()

    # html_file = "download_page.html"
    # download_time = '2023-10-11 08:'
    # link_elements = gdms.getDownloadUrl(html_file, download_time)
    # for index, link_element in enumerate(link_elements):
    #     _ = gdms.downloadData(link_element, link_elements[index][-8:])


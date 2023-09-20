import requests
import pandas as pd
from config import config
from logger import logger
import os
from dotenv import load_dotenv
import pandas as pd
import csv
load_dotenv()

# retur = rs.get("https://gdmsn.cwb.gov.tw/eqconDownload.php")
# cookies = retur.cookies
# cookie_value = cookies.get('PHPSESSID')
# print(retur.text)


class GDMS:
    """A class for interacting with the IMF GO API and its following process."""

    def __init__(self):
        """
            Initialize the IMF_GO instance.
        """
        self.api_url = config.get("api_url")
        self._login()

    def _login(self):
        """
            Log in to the GDMS API and set the authorization token in the request headers.

            Returns:
                None
        """
        login_url = f"{self.api_url}/loginProcess.php"
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

            Returns:
                None
        """
        get_waveform_url = f"{self.api_url}/sendEqdownload.php"
        eq_condition = config.get("eq_condition")
        try:
            eq_data = self.rs.post(get_waveform_url, data=eq_condition)
            if eq_data.json()["status"] == 1:
                logger.info(
                    "Get waveform success, please check infomation in GDMS website"
                )
            else:
                logger.error(
                    "Get waveform fail, please check get waveform information")

            return eq_data
        except:
            logger.error("Get waveform fail, please check base setting")

    def getCatalog(self):
        get_catalog_url = f"{self.api_url}/dbconnect/getCatalog.php"
        catalog_range = config.get("catalog_range")

        try:
            eq_catalog = self.rs.post(get_catalog_url, data=catalog_range)
            if eq_catalog.status_code == 200:
                logger.info(
                    "Get catalog success, please check infomation in GDMS website")
                return eq_catalog.json()
        except:
            logger.error("Get waveform fail")

    def listToCsv(self, list_data, csv_output_name):
        columns = ['event_id', 'date', 'time', 'ms', 'latitude', 'longitude', 'depth', 'ML',\
                    'nstn', 'dmin', 'gap', 'trms', 'ERH', 'ERZ', 'fixed', 'nph', 'quality']
        with open(csv_output_name, mode='w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=columns)
            writer.writeheader()
            for row in list_data:
                writer.writerow(row)


if __name__ == '__main__':
    catalog = pd.read_csv("../TSMIP_Dataset/GDMScatalog_test.csv")
    gdms = GDMS()
    # _ = gdms.getWaveform()
    eq_catalog = gdms.getCatalog()
    _ = gdms.listToCsv(eq_catalog, '../TSMIP_Dataset/GDMS_api_catalog.csv')
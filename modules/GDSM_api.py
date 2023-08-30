import requests
import pandas as pd
import numpy as np
from config import config
from logger import logger
import os
import time

# df = pd.read_csv("TSMIP_Dataset/GDMScatalog_test.csv")
# date = df["date"].values
# time = df["time"].values
# combined_list = [f"{d}T{t}" for d, t in zip(date, time)]
# combined_string = '\n'.join(combined_list)

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

        self._login_with_retry()

    def _login_with_retry(self):
        """
            Log in to the IMF GO API with retry logic and set the authorization token in the request headers.

            Returns:
                None
        """
        max_retries = 3
        retry_count = 0

        while retry_count < max_retries:
            try:
                self._login()
                break  # 登錄成功，退出循環
            except Exception as e:
                logger.error(f"Login attempt {retry_count+1} failed: {str(e)}")
                retry_count += 1
                if retry_count < max_retries:
                    logger.info(f"Retrying login in 5 seconds...")
                    time.sleep(5)

        if retry_count == max_retries:
            logger.error("Login failed after multiple attempts")

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
        rs = requests.session()

        try:
            response = rs.post(login_url, data=login_data) #login logic: After login it will set up the session id in this machine, and it could login through this info
            logger.info("Logged in to GDMS")

            get_catalog_url = f"{self.api_url}/dbconnect/getCatalog.php"
            catalog_range = config.get("catalog_range")
            eq_data = rs.post(get_catalog_url, data=catalog_range)
            logger.info("Get waveform success, please check infomation in GDMS website")
            logger.info(eq_data.text)

        except:
            logger.error("Login failed, please check login information")
    
    def getWaveform(self):
        """
            Log in to the GDMS API and set the authorization token in the request headers.

            Returns:
                None
        """
        get_waveform_url = f"{self.api_url}/sendEqdownload.php"
        eq_condition = config.get("eq_condition")
        try:
            eq_data = self.rs.post(get_waveform_url, data=eq_condition)
            logger.info("Get waveform success, please check infomation in GDMS website")
        except:
            logger.error("Get waveform fail")
    
    def getCatalog(self):
        get_catalog_url = f"{self.api_url}/dbconnect/getCatalog.php"
        catalog_range = config.get("catalog_range")

        try:
            eq_data = self.rs.post(get_catalog_url, data=catalog_range)
            logger.info("Get waveform success, please check infomation in GDMS website")

            return eq_data
        except:
            logger.error("Get waveform fail")

if __name__=='__main__':
    gdms = GDMS()
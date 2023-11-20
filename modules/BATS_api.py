import requests
from config import config
from logger import logger
import os
from dotenv import load_dotenv
import csv
from bs4 import BeautifulSoup
import re
from urllib.parse import urlsplit


class BATS():
    """
        A class for interacting with the BATS API and its following process.
    """

    def __init__(self):
        """
            Initialize the BATS instance.
        """
        self.api_url = config.get("BATS_api_url")
        self.output_path = config.get("download_path")
        self._login()

    def _login(self):
        """
            Log in to the BATS API and set the authorization token in the request headers.
        """
        login_url = f"{self.api_url}/BATSWS/login.php"
        login_data = {
            "account": os.getenv("BATS_ACCOUNT"),
            "password": os.getenv("BATS_PASSWORD"),
            "submit": True
        }
        try:
            self.rs = requests.session()
            response = self.rs.post(
                login_url, data=login_data
            )  # login logic: After login it will set up the session id in this machine, and it could login through this info
            if response.status_code == 200:
                logger.info("Logged in to BATS")

            elif response.status_code != 200:
                logger.error(response.status_code)
                logger.error("Login failed, please check login information")
        except:
            logger.error("Login failed, please check base setting")

    def _getHashPassword(self):
        get_password_url = f"{self.api_url}/BATSWS/cmt.php"
        response = self.rs.get(get_password_url)
        match = re.search(r"password=([a-zA-Z0-9]+)",response.text)
        password = 0
        if match:
            password = match.group(1)
            logger.info("get password successfully")
        else:
            logger.error("get password failed check if it's login")
        return password
    
    def getCatalog(self,file_path = "../TSMIP_Dataset/"):
        password = self._getHashPassword()
        catalog_condition = config.get("bats_catalog_range")
        tb = catalog_condition.get("tb")
        te = catalog_condition.get("te")
        maxmw = catalog_condition.get("maxmw")
        minmw = catalog_condition.get("minmw")
        maxdp = catalog_condition.get("maxdp")
        mindp = catalog_condition.get("mindp")
        label = catalog_condition.get("label")
        get_catalog_url = f"{self.api_url}/BATSWS/cmtquery?type=csv&tb={tb}&te={te}&maxmw={maxmw}&minmw={minmw}&maxdp={maxdp}&mindp={mindp}&l={label}&dl=1&lt=all&account={os.getenv('BATS_ACCOUNT')}&password={password}"
        response = self.rs.get(get_catalog_url)
        with open(f"{file_path}{label}.csv", 'wb') as file:
            file.write(response.content)

    # def getCatalog(self):
    #     """
    #         Log in to the BATS API and set the authorization token in the request headers.
    #     """
    #     get_catalog_url = f"{self.api_url}/FM/AutoBATS/cmtquery.php"
    #     catalog_condition = config.get("bats_catalog_range")
    #     get_catalog_data = {
    #         "InputOutType": catalog_condition.get("InputOutType"),
    #         "InputTB": catalog_condition.get("InputTB"),
    #         "InputTE": catalog_condition.get("InputTE"),
    #         "minlat": catalog_condition.get("minlat"),
    #         "maxlat": catalog_condition.get("maxlat"),
    #         "minlon": catalog_condition.get("minlon"),
    #         "maxlon": catalog_condition.get("maxlon"),
    #         "clat": catalog_condition.get("clat"),
    #         "clon": catalog_condition.get("clon"),
    #         "radius": catalog_condition.get("radius"),
    #         "InputQval": catalog_condition.get("InputQval"),
    #         "MagType": catalog_condition.get("MagType"),
    #         "Location": catalog_condition.get("Location")
    #     }

    #     response = requests.post(
    #         get_catalog_url, data=get_catalog_data
    #     ) 
    #     return response

if __name__ == '__main__':
    bats = BATS()
    result = bats.getCatalog()

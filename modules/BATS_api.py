import requests
from config import config
from logger import logger
import os
import pandas as pd
import numpy as np
import re
from datetime import datetime


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
        """
            To get hash password which show on the js funciton
            Returns:
                str: the password after hash
        """
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
    
    def getCatalog(self, file_path):
        """
            To get catalog from BATS api
            Args:
                file_path (str, optional): [description]. Defaults to "../TSMIP_Dataset/".
        """
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
        with open(f"{file_path}", 'wb') as file:
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

class catalogProcess():

    def __init__(self, gdms_catalog, gdms_catalog_path, bats_catalog, bats_catalog_path):
        self.gdms_catalog_path = gdms_catalog_path
        self.gdms_catalog = gdms_catalog
        self.bats_catalog_path = bats_catalog_path
        self.bats_catalog = bats_catalog

    def removeKeysSpace(self):
        self.bats_catalog.columns = self.bats_catalog.columns.str.strip()

    def addEventId(self, bats_catalog_path):
        gdms_catalog_subset = self.gdms_catalog[['depth', 'ML', 'date', 'event_id']]
        result = pd.merge(self.bats_catalog, gdms_catalog_subset, left_on=['CWB Depth', 'ML', 'Date'], right_on=['depth', 'ML', 'date'], how='left')
        result.drop('depth', axis=1, inplace=True)
        result.drop('date', axis=1, inplace=True)
        columns_reordered = [result.columns[-1]] + list(result.columns[:-1])
        result = result[columns_reordered]
        result.to_csv(f"{bats_catalog_path}",index=False)

if __name__ == '__main__':
    bats_catalog_path = "../TSMIP_Dataset/BATS_catalog.csv"
    # bats = BATS()
    # result = bats.getCatalog(bats_catalog_path)

    gdms_catalog_path = "../TSMIP_Dataset/GDMS_catalog.csv"
    gdms_catalog = pd.read_csv(gdms_catalog_path)
    bats_catalog_path = "../TSMIP_Dataset/BATS_catalog.csv"
    bats_catalog = pd.read_csv(bats_catalog_path)

    bats_catalog_process = catalogProcess(gdms_catalog, gdms_catalog_path, bats_catalog, bats_catalog_path)
    _ = bats_catalog_process.removeKeysSpace()
    _ = bats_catalog_process.addEventId(bats_catalog_path)
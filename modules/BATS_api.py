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

    def getCatalog(self):
        """
            Log in to the BATS API and set the authorization token in the request headers.
        """
        get_catalog_url = f"{self.api_url}/FM/AutoBATS/cmtquery.php"
        catalog_condition = config.get("bats_catalog_range")
        get_catalog_data = {
            "InputOutType": catalog_condition.get("InputOutType"),
            "InputTB": catalog_condition.get("InputTB"),
            "InputTE": catalog_condition.get("InputTE"),
            "minlat": catalog_condition.get("minlat"),
            "maxlat": catalog_condition.get("maxlat"),
            "minlon": catalog_condition.get("minlon"),
            "maxlon": catalog_condition.get("maxlon"),
            "clat": catalog_condition.get("clat"),
            "clon": catalog_condition.get("clon"),
            "radius": catalog_condition.get("radius"),
            "InputQval": catalog_condition.get("InputQval"),
            "MagType": catalog_condition.get("MagType"),
            "Location": catalog_condition.get("Location")
        }

        response = requests.post(
            get_catalog_url, data=get_catalog_data
        ) 
        return response

if __name__ == '__main__':
    gcmt = BATS()
    total_data = gcmt.getCatalog()
    with open("test.txt","w") as f:
        f.write(total_data.text)

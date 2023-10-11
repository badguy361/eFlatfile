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
            eq_data = self.rs.post(get_waveform_url, data=eq_condition)
            if eq_data.json()["status"] == 1:
                logger.info(
                    "Get waveform successed, please check infomation in GDMS website"
                )
            else:
                logger.error(
                    "Get waveform failed, please check get waveform information"
                )

            return eq_data
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
        stations = [
            'A002', 'A003', 'A004', 'A007', 'A008', 'A009', 'A010', 'A013',
            'A014', 'A015', 'A016', 'A020', 'A024', 'A025', 'A026', 'A030',
            'A032', 'A034', 'A036', 'A037', 'A039', 'A043', 'A044', 'A046',
            'A049', 'A051', 'A052', 'A054', 'A057', 'A059', 'A060', 'A061',
            'A063', 'A065', 'A066', 'A070', 'A071', 'A076', 'A077', 'A078',
            'A079', 'A082', 'A083', 'A084', 'A085', 'A103', 'A107', 'A112',
            'A115', 'A124', 'A125', 'A127', 'A128', 'A130', 'A131', 'A134',
            'B006', 'B011', 'B012', 'B013', 'B014', 'B016', 'B017', 'B018',
            'B019', 'B021', 'B022', 'B023', 'B024', 'B026', 'B027', 'B028',
            'B029', 'B030', 'B033', 'B034', 'B035', 'B036', 'B037', 'B039',
            'B041', 'B043', 'B045', 'B048', 'B049', 'B051', 'B052', 'B053',
            'B059', 'B060', 'B061', 'B062', 'B064', 'B066', 'B068', 'B069',
            'B070', 'B071', 'B073', 'B077', 'B078', 'B081', 'B082', 'B084',
            'B085', 'B086', 'B090', 'B095', 'B097', 'B099', 'B103', 'B104',
            'B107', 'B110', 'B111', 'B112', 'B115', 'B117', 'B118', 'B120',
            'B121', 'B123', 'B127', 'B128', 'B129', 'B131', 'B135', 'B136',
            'B138', 'B139', 'B143', 'B145', 'B149', 'B162', 'B168', 'B170',
            'B171', 'B172', 'B173', 'B174', 'B175', 'B176', 'B177', 'B178',
            'B179', 'B180', 'B181', 'B182', 'B184', 'B189', 'B190', 'B200',
            'B201', 'B204', 'B207', 'B208', 'B209', 'B210', 'B215', 'B216',
            'C001', 'C003', 'C004', 'C005', 'C006', 'C008', 'C010', 'C012',
            'C014', 'C015', 'C016', 'C017', 'C021', 'C022', 'C023', 'C024',
            'C026', 'C027', 'C029', 'C032', 'C034', 'C035', 'C037', 'C041',
            'C043', 'C044', 'C045', 'C047', 'C049', 'C051', 'C053', 'C055',
            'C056', 'C058', 'C060', 'C061', 'C062', 'C064', 'C065', 'C066',
            'C069', 'C073', 'C074', 'C075', 'C076', 'C077', 'C078', 'C082',
            'C084', 'C085', 'C087', 'C088', 'C092', 'C093', 'C094', 'C095',
            'C097', 'C098', 'C099', 'C100', 'C102', 'C104', 'C105', 'C106',
            'C107', 'C112', 'C113', 'C114', 'C116', 'C118', 'C121', 'C123',
            'C124', 'C134', 'C137', 'C138', 'C139', 'C140', 'C141', 'C142',
            'C143', 'C144', 'C145', 'C146', 'C150', 'C152', 'C155', 'C156',
            'C157', 'C160', 'C161', 'C162', 'D005', 'D008', 'D009', 'D011',
            'D012', 'D014', 'D015', 'D017', 'D023', 'D028', 'D029', 'D031',
            'D032', 'D033', 'D034', 'D035', 'D039', 'D042', 'D044', 'D046',
            'D047', 'D048', 'D049', 'D050', 'D051', 'D054', 'D060', 'D062',
            'D063', 'D064', 'D065', 'D066', 'D067', 'D068', 'D069', 'D071',
            'D072', 'D074', 'D075', 'D076', 'D077', 'D079', 'D084', 'D086',
            'D088', 'D089', 'D090', 'D091', 'D097', 'D103', 'D104', 'D105',
            'D106', 'D107', 'D108', 'D109', 'D110', 'D111', 'D112', 'D113',
            'D114', 'D115', 'D117', 'D120', 'D122', 'D123', 'D126', 'E004',
            'E006', 'E015', 'E022', 'E023', 'E026', 'E033', 'E034', 'E035',
            'E037', 'E042', 'E046', 'E049', 'E050', 'E053', 'E059', 'E060',
            'E061', 'E062', 'E067', 'E068', 'E069', 'E075', 'E076', 'F002',
            'F004', 'F015', 'F019', 'F020', 'F026', 'F028', 'F036', 'F041',
            'F042', 'F043', 'F044', 'F045', 'F048', 'F053', 'F054', 'F058',
            'F067', 'F068', 'F071', 'F072', 'F073', 'F074', 'F075', 'G001',
            'G002', 'G003', 'G014', 'G015', 'G016', 'G017', 'G020', 'G021',
            'G022', 'G023', 'G025', 'G026', 'G028', 'G030', 'G032', 'G033',
            'G035', 'G036', 'G037', 'G038', 'G041', 'G045', 'G047', 'G048',
            'G052', 'G053', 'G055', 'G057', 'G060', 'G061', 'I002', 'J001'
        ]
        for sta in stations:
            instrument_response['station'] = sta
            instrument_response['label'] = sta
            print(instrument_response['station'],instrument_response['label'])
            try:
                results = self.rs.post(get_catalog_url,
                                       data=instrument_response)
                if results.status_code == 200:
                    logger.info(
                        "Get instrument response successed, please check infomation in GDMS website"
                    )
                time.sleep(0.5)
                
            except:
                logger.error("Get instrument response failed")
                time.sleep(0.5)

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
    # _ = gdms.getWaveform()
    # _ = gdms.getInstrumentResponse()
    html_file = "download_page.html"
    download_time = '2023-10-11 09:'
    link_elements = gdms.getDownloadUrl(html_file, download_time)
    for index, link_element in enumerate(link_elements):
        _ = gdms.downloadData(link_element, link_elements[index][-8:])

    # catalog = pd.read_csv("../TSMIP_Dataset/GDMScatalog_test.csv")
    # eq_catalog = gdms.getCatalog()
    # _ = gdms.catalogToCsv(eq_catalog, '../TSMIP_Dataset/GDMS_catalog.csv')
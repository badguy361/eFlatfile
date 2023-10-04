import pymysql
import pandas as pd
from config import config
import os

if __name__ == "__main__":

    conn = pymysql.connect(host=os.getenv("DATABASE_URL"),
                           port=int(os.getenv("PORT")),
                           user=os.getenv("USER"),
                           password=os.getenv("PASSWORD"),
                           database=os.getenv("DATABASE"))

    cursor = conn.cursor()

    update_query = """
                        UPDATE `waveform_picking` SET `save` = 'N' WHERE `waveform_picking`.`id` = 1;  
                    """

    cursor.execute(update_query)

    conn.commit()

    conn.close()

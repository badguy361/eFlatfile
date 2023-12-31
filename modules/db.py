import pymysql
import pandas as pd
from config import config
import os
import datetime

def merge_gdms_gcmt(start_date, end_date):

    criteria = f"""
    INSERT INTO merged_catalog (
        event_id,
        date, 
        time,
        ms, 
        taiwan_time,
        lat,
        lon,
        depth,  
        ML,
        empirical_Mw, 
        gcmt_date,
        gcmt_time,
        gcmt_lon,
        gcmt_lat,  
        gcmt_depth,
        gcmt_Mw,
        gcmt_Ms,  
        gcmt_strike1,
        gcmt_dip1,
        gcmt_slip1,  
        gcmt_strike2,
        gcmt_dip2,  
        gcmt_slip2
    )
        SELECT
            gdms_original.event_id,
            gdms_original.date, 
            gdms_original.time,
            gdms_original.ms, 
            gdms_original.taiwan_time,
            gdms_original.lat,
            gdms_original.lon,
            gdms_original.depth,
            gdms_original.ML,
            gdms_original.empirical_Mw,
            merged_results.gcmt_date,
            merged_results.gcmt_time,
            merged_results.gcmt_lon,
            merged_results.gcmt_lat,
            merged_results.gcmt_depth,
            merged_results.gcmt_Mw,
            merged_results.gcmt_Ms,
            merged_results.gcmt_strike1,
            merged_results.gcmt_dip1,
            merged_results.gcmt_slip1,
            merged_results.gcmt_strike2,
            merged_results.gcmt_dip2,
            merged_results.gcmt_slip2
        FROM
            gdms_catalog AS gdms_original
        LEFT JOIN
            (
                SELECT
                    gdms.event_id,
                    gdms.gdms_date,
                    gdms.gdms_time,
                    gcmt.gcmt_date,
                    gcmt.gcmt_time,
                    gcmt.gcmt_lon,
                    gcmt.gcmt_lat,
                    gcmt.gcmt_depth,
                    gcmt.gcmt_Mw,
                    gcmt.gcmt_Ms,
                    gcmt.gcmt_strike1,
                    gcmt.gcmt_dip1,
                    gcmt.gcmt_slip1,
                    gcmt.gcmt_strike2,
                    gcmt.gcmt_dip2,
                    gcmt.gcmt_slip2,
                    TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime) AS time_difference,
                    ST_Distance_Sphere(
                        POINT(gdms.lon, gdms.lat),
                        POINT(gcmt.gcmt_lon, gcmt.gcmt_lat)
                    ) / 1000 AS distance_km_difference,
                    ABS(gdms.empirical_Mw - gcmt.gcmt_Mw) AS magnitude_difference
                FROM
                    (
                        SELECT
                        event_id,
                        date AS gdms_date,
                        time AS gdms_time,
                        lon,
                        lat,
                        empirical_Mw,
                        TIMESTAMP(date, time) AS gdms_datetime
                        FROM
                        gdms_catalog
                    ) AS gdms
                    CROSS JOIN
                    (
                        SELECT
                        date AS gcmt_date,
                        time AS gcmt_time,
                        lon AS gcmt_lon,
                        lat AS gcmt_lat,
                        depth AS gcmt_depth,
                        Mw AS gcmt_Mw,
                        Ms AS gcmt_Ms,
                        strike1 AS gcmt_strike1,
                        dip1 AS gcmt_dip1,
                        slip1 AS gcmt_slip1,
                        strike2 AS gcmt_strike2,
                        dip2 AS gcmt_dip2,
                        slip2 AS gcmt_slip2,
                        TIMESTAMP(date, time) AS gcmt_datetime
                        FROM
                        gcmt_catalog
                    ) AS gcmt
                WHERE
                    ABS(TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime)) < 15
                    AND ST_Distance_Sphere(
                            POINT(gdms.lon, gdms.lat),
                            POINT(gcmt.gcmt_lon, gcmt.gcmt_lat)
                        ) / 1000 < 35
                    AND (
                        (gdms.empirical_Mw < 4 AND ABS(gdms.empirical_Mw - gcmt.gcmt_Mw) < 1.2)
                        OR
                        (gdms.empirical_Mw >= 4 AND ABS(gdms.empirical_Mw - gcmt.gcmt_Mw) <= 0.9)
                    )
                    AND gdms.gdms_datetime BETWEEN '{start_date}' AND '{end_date}'
            ) AS merged_results
        ON
            gdms_original.event_id = merged_results.event_id;
    """
    return criteria

def upload_bats_catalog():
    query = """
    INSERT INTO bats_catalog()
    """
if __name__ == "__main__":

    conn = pymysql.connect(host=os.getenv("DATABASE_URL"),
                           port=int(os.getenv("PORT")),
                           user=os.getenv("USER"),
                           password=os.getenv("PASSWORD"),
                           database=os.getenv("DATABASE"))

    cursor = conn.cursor()
    start_date = "2014-01-01"
    end_date = "2023-12-31"
    query = merge_gdms_gcmt(start_date, end_date)
    cursor.execute(query)
    conn.commit() 
    conn.close()

# query_select = """
# SELECT 
#         gdms.gdms_date, 
#         gdms.gdms_time, 
#         gdms.gdms_datetime, 
#         gcmt.gcmt_date, 
#         gcmt.gcmt_time, 
#         gcmt.gcmt_datetime, 
#         TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime) AS difference,
#         ST_Distance_Sphere(
#             POINT(gdms.lon, gdms.lat), 
#             POINT(gcmt.lon, gcmt.lat)
#         ) / 1000 AS distance_km,
#         ABS(gdms.Mw - gcmt.mw) AS magnitude_difference
# FROM 
#     (
#         SELECT 
#         date AS gdms_date, 
#         time AS gdms_time, 
#         eq_lon AS lon, 
#         eq_lat AS lat,
#         Mw,
#         TIMESTAMP(date, time) AS gdms_datetime 
#         FROM 
#         gdms_catalog
#     ) AS gdms
# CROSS JOIN 
#     (
#         SELECT 
#         date AS gcmt_date,
#         centroid_time AS gcmt_time,
#         lon AS lon,
#         lat AS lat,
#         mw,
#         TIMESTAMP(date, centroid_time) AS gcmt_datetime 
#         FROM 
#         gcmt_catalog
#     ) AS gcmt 
# WHERE 
#     ABS(TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime)) < 15
#     AND ST_Distance_Sphere(
#             POINT(gdms.lon, gdms.lat), 
#             POINT(gcmt.lon, gcmt.lat)
#         ) / 1000 < 35  
#     AND  (
#         (gdms.Mw < 4 AND ABS(gdms.Mw - gcmt.Mw) < 1) 
#         OR 
#         (gdms.Mw >= 4 AND ABS(gdms.Mw - gcmt.Mw) < 0.9)
# 	)
#     AND gcmt.gcmt_date BETWEEN "2022-01-01" AND "2022-12-31"
# ORDER BY `gcmt`.`gcmt_datetime` DESC;
# """

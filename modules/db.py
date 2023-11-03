import pymysql
import pandas as pd
from config import config
import os
import datetime

if __name__ == "__main__":

    conn = pymysql.connect(host=os.getenv("DATABASE_URL"),
                           port=int(os.getenv("PORT")),
                           user=os.getenv("USER"),
                           password=os.getenv("PASSWORD"),
                           database=os.getenv("DATABASE"))

    cursor = conn.cursor()

    query = """
        SELECT combined_datetime, difference FROM
        (SELECT
        TIMESTAMP(date, time) AS combined_datetime,
        TIMESTAMPDIFF(MINUTE,TIMESTAMP(date, time), TIMESTAMP("2018-01-01", "20:00:00")) AS difference
        FROM gdms_catalog ) AS sub WHERE ABS(sub.difference) < 100;
    """

    query2 = """
    SELECT 
        gdms.gdms_date, 
        gdms.gdms_time, 
        gdms.gdms_datetime, 
        gcmt.gcmt_date, 
        gcmt.gcmt_time, 
        gcmt.gcmt_datetime, 
        TIMESTAMPDIFF(MINUTE, gdms.gdms_datetime, gcmt.gcmt_datetime) AS difference 
    FROM 
        (
            SELECT 
            date AS gdms_date, 
            time AS gdms_time, 
            TIMESTAMP(date, time) AS gdms_datetime 
            FROM 
            gdms_catalog
        ) AS gdms
    CROSS JOIN 
        (
            SELECT 
            date AS gcmt_date,
            centroid_time AS gcmt_time,
            TIMESTAMP(date, centroid_time) AS gcmt_datetime 
            FROM 
            gcmt_catalog
        ) AS gcmt 
    WHERE 
        ABS(TIMESTAMPDIFF(MINUTE, gdms.gdms_datetime, gcmt.gcmt_datetime)) < 10;
    """

    query3 = """
    SELECT 
            gdms.gdms_date, 
            gdms.gdms_time, 
            gdms.gdms_datetime, 
            gcmt.gcmt_date, 
            gcmt.gcmt_time, 
            gcmt.gcmt_datetime, 
            TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime) AS difference,
            ST_Distance_Sphere(
                POINT(gdms.lon, gdms.lat), 
                POINT(gcmt.lon, gcmt.lat)
            ) / 1000 AS distance_km,
            ABS(gdms.Mw - gcmt.mw) AS magnitude_difference
    FROM 
        (
            SELECT 
            date AS gdms_date, 
            time AS gdms_time, 
            eq_lon AS lon, 
            eq_lat AS lat,
            Mw,
            TIMESTAMP(date, time) AS gdms_datetime 
            FROM 
            gdms_catalog
        ) AS gdms
    CROSS JOIN 
        (
            SELECT 
            date AS gcmt_date,
            centroid_time AS gcmt_time,
            lon AS lon,
            lat AS lat,
            mw,
            TIMESTAMP(date, centroid_time) AS gcmt_datetime 
            FROM 
            gcmt_catalog
        ) AS gcmt 
    WHERE 
        ABS(TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime)) < 15
        AND ST_Distance_Sphere(
                POINT(gdms.lon, gdms.lat), 
                POINT(gcmt.lon, gcmt.lat)
            ) / 1000 < 35  
        AND  (
            (gdms.Mw < 4 AND ABS(gdms.Mw - gcmt.Mw) < 1) 
            OR 
            (gdms.Mw >= 4 AND ABS(gdms.Mw - gcmt.Mw) < 0.9)
    	)
        AND gcmt.gcmt_date BETWEEN "2022-01-01" AND "2022-12-31"
    ORDER BY `gcmt`.`gcmt_datetime` DESC;
    """

    query4="""
        
    INSERT INTO merged_catalog (
        event_id,
        date, 
        time,
        ms, 
        taiwan_time,
        lat,
        lon,
        depth,  
        Mw, 
        ML,
        gcmt_date,
        gcmt_time,  
        time_difference,
        gcmt_lon,
        gcmt_lat,  
        distance_km_difference,
        gcmt_depth,
        gcmt_Mw,
        magnitude_difference,
        gcmt_Ms,  
        strike1,
        dip1,
        slip1,  
        strike2,
        dip2,  
        slip2
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
        gdms_original.Mw, 
        gdms_original.ML,
        merged_results.gcmt_date,
        merged_results.gcmt_time,  
        merged_results.time_difference,
        merged_results.gcmt_lon,
        merged_results.gcmt_lat,  
        merged_results.distance_km_difference,
        merged_results.gcmt_depth,
        merged_results.gcmt_Mw,
        merged_results.magnitude_difference,
        merged_results.gcmt_Ms,  
        merged_results.strike1,
        merged_results.dip1,
        merged_results.slip1,  
        merged_results.strike2,
        merged_results.dip2,  
        merged_results.slip2
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
                gcmt.strike1,
                gcmt.dip1,
                gcmt.slip1,
                gcmt.strike2,
                gcmt.dip2,
                gcmt.slip2,
                TIMESTAMPDIFF(SECOND, gdms.gdms_datetime, gcmt.gcmt_datetime) AS time_difference,
                ST_Distance_Sphere(
                    POINT(gdms.lon, gdms.lat), 
                    POINT(gcmt.gcmt_lon, gcmt.gcmt_lat)
                ) / 1000 AS distance_km_difference,
                ABS(gdms.Mw - gcmt.gcmt_Mw) AS magnitude_difference
            FROM 
                (
                    SELECT 
                    event_id,
                    date AS gdms_date, 
                    time AS gdms_time, 
                    lon, 
                    lat,
                    Mw,
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
                    strike1,
                    dip1,
                    slip1,
                    strike2,
                    dip2,
                    slip2,
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
                    (gdms.Mw < 4 AND ABS(gdms.Mw - gcmt.gcmt_Mw) < 1.2) 
                    OR 
                    (gdms.Mw >= 4 AND ABS(gdms.Mw - gcmt.gcmt_Mw) <= 0.9)
                )
        ) AS merged_results
    ON 
        gdms_original.event_id = merged_results.event_id;
    """
    cursor.execute(query)

    result = cursor.fetchall()
    print(result)

    conn.close()

CREATE DATABASE IF NOT EXISTS TSMIP;
USE TSMIP;

CREATE TABLE eq_catalog (
    event_id VARCHAR(50) PRIMARY KEY,
    date date,
    time time,
    ms Float,
    taiwan_time bigint(50),
    eq_lat Float,
    eq_lon Float,
    eq_depth Float,
    ML Float,
    Mw Float,
    nstn INT(5),
    dmin Float,
    gap INT(5),
    trms Float,
    ERH Float,
    ERZ Float,
    fixed VARCHAR(5),
    nph INT(5),
    quality VARCHAR(1)
);

CREATE TABLE station_infomation (
    station VARCHAR(10) PRIMARY KEY,
    code VARCHAR(20),
    name VARCHAR(20),
    adress VARCHAR(50),
    lon Float,
    lat Float,
    height Float,
    survey_year VARCHAR(10),
    drilling_depth_m VARCHAR(10),
    PS_Logger_depth_m VARCHAR(10),
    site_classification_by_Vs30 VARCHAR(5),
    Vs30 Float,
    Vs30_model VARCHAR(10),
    Z1.0 Float,
    Z1.0_measure_method VARCHAR(8),
    Kappa Float,
    Kappa_measure_method VARCHAR(10)
);

CREATE TABLE waveform_picking (
    event_id VARCHAR(50),
    file_name VARCHAR(50) PRIMARY KEY,
    station VARCHAR(10),
    sta_dist Float,
    save VARCHAR(1),
    start_time_T4 Float,
    end_time_T3 Float,
    p_arrival_T1 Float,
    s_arrival_T2 Float,
    filter_id VARCHAR(50),

    FOREIGN KEY (event_id) REFERENCES eq_catalog(event_id)
    FOREIGN KEY (station) REFERENCES station_infomation(station)
)

CREATE DATABASE IF NOT EXISTS TSMIP;
USE TSMIP;

CREATE TABLE eq_catalog (
    event_id VARCHAR(50) PRIMARY KEY,
    date VARCHAR(15),
    time VARCHAR(10),
    ms Float,
    taiwan_time VARCHAR(20),
    eq_lat Float(10),
    eq_lon Float(10),
    eq_depth Float(10),
    ML Float(5),
    Mw Float(5),
    nstn INT(5),
    dmin Float(10),
    gap INT(5),
    trms Float(5),
    ERH Float(5),
    ERZ Float(5),
    fixed VARCHAR(5),
    nph INT(5),
    quality VARCHAR(1)
);

CREATE TABLE waveform_picking (
    event_id VARCHAR(50),
    file_name VARCHAR(50) PRIMARY KEY,
    station VARCHAR(10),
    sta_dist Float,
    save VARCHAR(1),
    start_time_T4 Float(5),
    end_time_T3 Float(5),
    p_arrival_T1 Float(5),
    s_arrival_T2 Float(5),
    filter_id VARCHAR(50),

    FOREIGN KEY (event_id) REFERENCES eq_catalog(event_id)
    FOREIGN KEY (station) REFERENCES station_infomation(station)
)

CREATE TABLE station_infomation (
    station VARCHAR(10) PRIMARY KEY,
    lon Float,
    lat Float,
    dep Float

)

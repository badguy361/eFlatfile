CREATE DATABASE IF NOT EXISTS TSMIP;
USE TSMIP;

CREATE TABLE gdms_catalog (
    event_id INT NOT NULL PRIMARY KEY,
    date date,
    time time,
    ms Float,
    taiwan_time bigint(50),
    lat Float,
    lon Float,
    depth Float,
    ML Float,
    empirical_Mw Float,
    nstn INT,
    dmin Float,
    gap INT,
    trms Float,
    ERH Float,
    ERZ Float,
    fixed VARCHAR(5),
    nph INT,
    quality VARCHAR(1)
);

CREATE TABLE gcmt_catalog (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    date date,
    time time,
    lat Float,
    lon Float,
    depth Float,
    half_duration Float,
    centroid_time_minus_hypocenter_time Float,
    Mw Float,
    Mb Float,
    Ms Float,
    scalar_moment VARCHAR(20),
    strike1 INT,
    dip1 INT,
    slip1 INT,
    strike2 INT,
    dip2 INT,
    slip2 INT
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
    Z1_0 Float,
    Z1_0_measure_method VARCHAR(8),
    Kappa Float,
    Kappa_measure_method VARCHAR(10)
);

CREATE TABLE waveform_picking (
    event_id INT,
    file_name VARCHAR(50) PRIMARY KEY,
    station VARCHAR(10),
    sta_dist Float,
    iasp91_P_arrival Float,
    iasp91_S_arrival Float,
    save VARCHAR(1),
    start_time_T4 Float,
    end_time_T3 Float,
    p_arrival_T1 Float,
    s_arrival_T2 Float,
    filter_id VARCHAR(50),

    FOREIGN KEY (event_id) REFERENCES gdms_catalog(event_id),
    FOREIGN KEY (station) REFERENCES station_infomation(station)
)

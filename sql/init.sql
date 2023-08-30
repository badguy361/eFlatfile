CREATE DATABASE IF NOT EXISTS TSMIP;
USE TSMIP;

CREATE TABLE eq_catalog (
    id INT PRIMARY KEY,
    event_id VARCHAR(50),
    file_name VARCHAR(100),
    Year INT(5),
    Month INT(5),
    Day INT(5),
    Hour INT(5),
    Minute INT(5),
    Second INT(5),
    eq_lat Float(10),
    eq_lon Float(10),
    eq_depth Float(10),
    ML Float(5),
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
    id INT PRIMARY KEY,
    event_id VARCHAR(50),
    file_name VARCHAR(50),
    save VARCHAR(1),
    start_time(T4) Float(5),
    end_time(T3) Float(5),
    p_arrival(T1) Float(5),
    s_arrival(T2) Float(5),
    filter_id VARCHAR(50),

    FOREIGN KEY (event_id) REFERENCES eq_catalog(event_id)

)

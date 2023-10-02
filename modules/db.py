from sqlalchemy import create_engine, Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import pandas as pd
from config import config
import os

Base = declarative_base()


class Catalog(Base):
    __tablename__ = 'eq_catalog'
    event_id = Column(String, primary_key=True)
    date = Column(String)
    time = Column(String)
    ms = Column(Float)
    eq_lat = Column(Float)
    eq_lon = Column(Float)
    eq_depth = Column(Float)
    ML = Column(Float)
    Mw = Column(Float)
    nstn = Column(Integer)
    dmin = Column(Float)
    gap = Column(Integer)
    trms = Column(Float)
    ERH = Column(Float)
    ERZ = Column(Float)
    fixed = Column(String)
    nph = Column(Integer)
    quality = Column(String)
    taiwan_time = Column(String)


class waveformPicking(Base):
    __tablename__ = 'waveform_picking'
    id = Column(Integer, primary_key=True)
    event_id = Column(String)
    file_name = Column(String)
    station = Column(String)
    sta_lon = Column(Float)
    sta_lat = Column(Float)
    sta_dist = Column(Float)
    save = Column(String)
    start_time_T4 = Column(Float)
    end_time_T3 = Column(Float)
    p_arrival_T1 = Column(Float)
    s_arrival_T2 = Column(Float)
    filter_id = Column(String)

def create_session(database_url):
    engine = create_engine(database_url)
    Session = sessionmaker(bind=engine)
    return Session()


def insert_data(session, model_class, **kwargs):
    new_data = model_class(**kwargs)
    session.add(new_data)
    session.commit()

    
if __name__ == "__main__":
    db_url = os.getenv("DATABASE_URL")
    session = create_session(db_url)

    insert_data(session,
                waveformPicking,
                event_id='1',
                file_name='test',
                save="Y",
                start_time_T4=2,
                end_time_T3=3,
                p_arrival_T1=4,
                s_arrival_T2=56.2,
                filter_id="ss")
    
    # path = "../TSMIP_Dataset"
    # catalog_name = "GDMS_catalog.csv"
    # catalog = pd.read_csv(f"{path}/{catalog_name}")
    # for i in range(catalog.__len__()):
    #     insert_data(session,
    #                 Catalog,
    #                 event_id=str(catalog["event_id"][i]),
    #                 date=str(catalog["date"][i]),
    #                 time=str(catalog["time"][i]),
    #                 ms=catalog["ms"][i],
    #                 eq_lat=catalog["latitude"][i],
    #                 eq_lon=catalog["longitude"][i],
    #                 eq_depth=catalog["depth"][i],
    #                 ML=catalog["ML"][i],
    #                 nstn=int(catalog["nstn"][i]),
    #                 dmin=catalog["dmin"][i],
    #                 gap=int(catalog["gap"][i]),
    #                 trms=catalog["trms"][i],
    #                 ERH=catalog["ERH"][i],
    #                 ERZ=catalog["ERZ"][i],
    #                 fixed=catalog["fixed"][i],
    #                 nph=int(catalog["nph"][i]),
    #                 quality=catalog["quality"][i],
    #                 taiwan_time=str(catalog["taiwan_time"][i]))

    session.close()
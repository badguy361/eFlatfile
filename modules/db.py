from sqlalchemy import create_engine, Column, Integer, String, Float
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import pandas as pd
from config import config
import os

Base = declarative_base()

class waveformPicking(Base):
    __tablename__ = 'waveform_picking'
    id = Column(Integer, primary_key=True)
    event_id = Column(String, default=None)
    file_name = Column(String, default=None)
    station = Column(String, default=None)
    sta_dist = Column(Float, default=None)
    save = Column(String, default=None)
    start_time_T4 = Column(Float, default=None)
    end_time_T3 = Column(Float, default=None)
    p_arrival_T1 = Column(Float, default=None)
    s_arrival_T2 = Column(Float, default=None)
    filter_id = Column(String, default=None)

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
                s_arrival_T2=56.2)

    session.close()
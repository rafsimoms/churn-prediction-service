import pandas as pd
from src.db.engine import get_engine
from pathlib import Path

engine = get_engine()

sql_training_path = Path(__file__).resolve().parents[2] / 'sql' / 'training_dataset.sql'

def get_train_dataset():
    query = sql_training_path.read_text(encoding='utf-8').strip()
    df = pd.read_sql(sql=query, con=engine)
    return df


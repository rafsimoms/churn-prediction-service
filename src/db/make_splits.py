import pandas as pd
from sklearn.model_selection import train_test_split
from src.db.engine import get_engine
from sqlalchemy import text

engine = get_engine()

df = pd.read_sql("SELECT * FROM churn_labels", engine)

X_train, X_val = train_test_split(df, stratify=df['churned'], train_size=0.7, random_state=42)
X_test, X_prod = train_test_split(X_val, stratify=X_val['churned'], train_size=0.5, random_state=42)

X_train['split'] = 'train'
X_test['split'] = 'test'
X_prod['split'] = 'prod_stream'

splits = pd.concat([X_train, X_test, X_prod], ignore_index=True)
splits = splits[['customer_id', 'split']]
splits.to_sql('splits', engine, index=False, if_exists='append')

print(pd.read_sql("SELECT COUNT(*) FROM splits", engine))

X_prod = X_prod.sample(frac=1, random_state=42).reset_index(drop=True)
mid = len(X_prod) // 2

first_half = X_prod[:mid]
second_half = X_prod[mid:]

first_half['batch_stream'] = 1
second_half['batch_stream'] = 2
X_prod = pd.concat([first_half, second_half], ignore_index=True)
X_prod = X_prod[['customer_id', 'batch_stream']]
X_prod.to_sql('prod_stream', engine, index=False, if_exists='append')
with engine.begin() as conn:
    conn.execute(text("""UPDATE charges SET monthly_charges = monthly_charges * 1.15 
    FROM prod_stream 
    WHERE prod_stream.customer_id = charges.customer_id AND batch_stream = 2;"""))

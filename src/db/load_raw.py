from dotenv import load_dotenv
import pandas as pd
from sqlalchemy import create_engine
import os

load_dotenv()

SERVICE_COLUMNS = {
    "PhoneService": "phone",
    "MultipleLines": "multiple_lines",
    "InternetService": "internet",
    "OnlineSecurity": "online_security",
    "OnlineBackup": "online_backup",
    "DeviceProtection": "device_protection",
    "TechSupport": "tech_support",
    "StreamingTV": "streaming_tv",
    "StreamingMovies": "streaming_movies",
}

BOOLEAN = {'Yes' : True, 'No' : False}

def get_engine():
    user = os.environ["POSTGRES_USER"]
    password = os.environ["POSTGRES_PASSWORD"]
    host = os.environ["POSTGRES_HOST"]
    port = os.environ["POSTGRES_PORT"]
    db = os.environ["POSTGRES_DB"]
    return create_engine(f"postgresql+psycopg2://{user}:{password}@{host}:{port}/{db}")

def prepare_customers(df) -> pd.DataFrame:
    res = pd.DataFrame({
        'customer_id' : df['customerID'],
        'gender' : df ['gender'],
        'senior_citizen' : df['SeniorCitizen'].astype(bool),
        'partner' : df['Partner'].map(BOOLEAN),
        'dependents' : df['Dependents'].map(BOOLEAN)
    })
    return res

def prepare_contracts(df) -> pd.DataFrame:
    res = pd.DataFrame({
        'customer_id' : df['customerID'],
        'tenure' : df['tenure'].astype(int),
        'contract' : df['Contract'],
        'paperless_billing' : df['PaperlessBilling'].map(BOOLEAN),
        'payment_method' : df['PaymentMethod']
    })
    return res

def prepare_services(df) -> pd.DataFrame:
    res = pd.melt(
        df,
        id_vars=['customerID'],
        value_vars=['PhoneService', 'MultipleLines', 'InternetService', 'OnlineSecurity', 
                    'OnlineBackup', 'DeviceProtection', 'TechSupport', 'StreamingTV', 'StreamingMovies'],
        var_name='service_type',
        value_name='service_status'
    )
    res = res.rename(columns={'customerID' : 'customer_id'})
    res["service_type"] = res["service_type"].map(SERVICE_COLUMNS)
    return res

def prepare_charges(df) -> pd.DataFrame:
    # замена пробелов на 0 в TotalCharges т.к. у 11 клиентов с tenure = 0 стоит " ", решил что стоит заменить на 0
    total_charges = pd.to_numeric(df["TotalCharges"], errors="coerce").fillna(0)
    res = pd.DataFrame({
        'customer_id' : df['customerID'],
        'monthly_charges' : df['MonthlyCharges'].astype(float),
        'total_charges' : total_charges
    })
    return res

def prepare_churn_labels(df) -> pd.DataFrame:
    res = pd.DataFrame({
        'customer_id' : df['customerID'],
        'churned' : df['Churn'].map(BOOLEAN)
    })
    return res

def main():
    df = pd.read_csv('data/raw/telco_churn.csv')
    engine = get_engine()
    prepare_customers(df).to_sql('customers', engine, if_exists='append', index=False)
    prepare_contracts(df).to_sql('contracts', engine, if_exists='append', index=False)
    prepare_services(df).to_sql('services', engine, if_exists='append', index=False)
    prepare_charges(df).to_sql('charges', engine, if_exists='append', index=False)
    prepare_churn_labels(df).to_sql('churn_labels', engine, if_exists='append', index=False)
    print("Загружено 5 таблиц")

if __name__ == '__main__':
    main()
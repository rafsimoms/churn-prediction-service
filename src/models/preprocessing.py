from sklearn.compose import ColumnTransformer
from sklearn.pipeline import Pipeline
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import StandardScaler, OneHotEncoder, FunctionTransformer


num_features = ['tenure', 'monthly_charges', 'total_charges']
bool_features = ['senior_citizen', 'partner', 'dependents', 'paperless_billing']
cat_features = [
    'gender', 'contract', 'payment_method',
    'internet', 'online_security', 'tech_support', 'online_backup',
    'device_protection', 'streaming_movies', 'streaming_tv',
    'multiple_lines', 'phone',
]

def preprocess():
    numeric_pipe = Pipeline([
        ('imputer', SimpleImputer(strategy='median')),
        ('scaler', StandardScaler()),
        ])

    bool_pipe = Pipeline([
        ('to_int', FunctionTransformer(lambda x: x.astype(int))),
        ('bool_ohe', OneHotEncoder(drop='first')),
    ])

    categorical_pipe = Pipeline([
        ('imputer', SimpleImputer(strategy='most_frequent')),
        ('cat_ohe', OneHotEncoder(drop='first', handle_unknown='ignore')),
    ])

    ct = ColumnTransformer([
        ('num', numeric_pipe, num_features),
        ('bool', bool_pipe, bool_features),
        ('kat', categorical_pipe, cat_features)
    ])
    return ct
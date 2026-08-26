from sklearn.model_selection import StratifiedKFold

def get_cv_splits():
    return StratifiedKFold(n_splits=5, random_state=42, shuffle=True)
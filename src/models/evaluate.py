import pandas as pd
from sklearn.model_selection import cross_validate, cross_val_predict
from sklearn.metrics import confusion_matrix


scoring = ['f1', 'recall', 'roc_auc', 'precision', 'average_precision']

def evaluate_model(pipeline, X, y, cv, model_name):
    cv_res = cross_validate(estimator=pipeline, X=X, y=y, cv=cv, scoring=scoring)
    res = {'model' : model_name}
    for score in scoring:
        res[score] = f"{round(cv_res[f'test_{score}'].mean(), 3)} ± {round(cv_res[f'test_{score}'].std(), 3)}std"
    return pd.DataFrame([res]).set_index('model')

def cv_confusion_matrix(pipeline, X, y, cv, model_name=None, threshold=0.5):
    pred = cross_val_predict(estimator=pipeline, X=X, y=y, cv=cv)
    y_pred = (pred>=threshold).astype(int)
    return confusion_matrix(y_true=y, y_pred=y_pred)

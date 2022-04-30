# import libraries 
import streamlit as st 
import numpy as np 
import matplotlib.pyplot as plt  
import pandas as pd 
import pandas_profiling
from streamlit_pandas_profiling import st_profile_report
from sklearn import datasets
from sklearn.model_selection import train_test_split
from sklearn.decomposition import PCA
from sklearn.svm import SVC
from sklearn.neighbors import KNeighborsClassifier  
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score

st.write("""
## Explore different ML Models and Datasets""")

# dataset selection
dataset_name = st.sidebar.selectbox("Select Dataset", ["Wine","Breast Cancer", "Iris"])

# button
button = st.sidebar.button("Report")

# Ml model selection
ml_model = st.sidebar.selectbox("Choose Model",["KNN", "SVM", "Random Forest"])


@st.cache(suppress_st_warning = True)
def statistics(dataset_name):
    if dataset_name == "Iris":
        data = datasets.load_iris()
        df = pd.DataFrame(data=data.data, columns=data.feature_names)
        if button :
            pr = df.profile_report()
            st_profile_report(pr)
    elif dataset_name == "Wine":
        data = datasets.load_wine()
        df = pd.DataFrame(data=data.data, columns=data.feature_names)
        if button :
            pr = df.profile_report()
            st_profile_report(pr)
    else:
        data = datasets.load_breast_cancer()
        df = pd.DataFrame(data=data.data, columns=data.feature_names)
        if button :
            pr = df.profile_report()
            st_profile_report(pr)


statistics(dataset_name)


# function to select dataset
def dataset(dataset_name):
    data = None 
    if dataset_name == "Iris":
        data = datasets.load_iris()
    elif dataset_name == "Wine":
        data = datasets.load_wine()
    else:
        data = datasets.load_breast_cancer()
    X = data.data
    y = data.target
    return X,y

X,y = dataset(dataset_name)
# shape
st.write("Shape of Dataset :",X.shape)
# unique classes 
st.write("Number of Classes" , len(np.unique(y)))

# parameter of different c;asses
def add_parameter_ui(classifier_name):
    param = dict()
    if classifier_name == "SVM":
        c = st.sidebar.slider("C",0.01,10.0)
        param['C'] = c
    elif classifier_name == "KNN":
        k = st.sidebar.slider("K",1 ,15)
        param['K'] = k
    else :
        max_depth = st.sidebar.slider("Max Depth",2 , 15)
        param['max_depth'] = max_depth
        n_estimators = st.sidebar.slider("N estimators",1, 100)
        param['n_estimators'] = n_estimators
    return param

params = add_parameter_ui(ml_model)

# modeling
def get_classifier(classifier_name, params):
    clf = None
    if classifier_name == "SVM":
        clf = SVC(C = params['C'])
    elif classifier_name == "KNN":
        clf = KNeighborsClassifier(n_neighbors = params['K'])
    else:
        clf = RandomForestClassifier(max_depth=params['max_depth'], n_estimators = params['n_estimators'], random_state=1234)
    return clf 

clf  = get_classifier(ml_model, params)

# train testing split 
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=1234 )

clf.fit(X,y)
y_pred = clf.predict(X_test)


acc = accuracy_score(y_test, y_pred)
st.write("Classifier Name : ", ml_model)
st.write("Accuracy Score :", acc)

# PCA
pca =PCA(2)
X_projected = pca .fit_transform(X)

x1 = X_projected[:,0]
x2 = X_projected[:,1]

fig = plt.figure()
plt.scatter(x1, x2, c=y, alpha=0.8, cmap= "viridis")
plt.xlabel("Principal Component 1")
plt.ylabel("Principal Component 2")
plt.colorbar()

st.pyplot(fig)

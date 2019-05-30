FROM jupyter/tensorflow-notebook:abdb27a6dfbb

LABEL maintainer="Alan CHALK"

USER root

# --- Install python-tk htop python-boost
RUN apt-get update && \
    apt-get install -y --no-install-recommends python-tk software-properties-common htop libboost-all-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Install dependency gcc/g++
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test

# --- Install gcc/g++
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc-7 g++-7 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# --- Update alternatives
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

# --- Install h2o
RUN $CONDA_DIR/bin/python -m pip install -f http://h2o-release.s3.amazonaws.com/h2o/latest_stable_Py.html h2o

# --- Conda xgboost, lightgbm, catboost, h2o, gensim, mlxtend
RUN conda install --quiet --yes \
    'boost' \
    'lightgbm' \
    'xgboost' \
    'catboost' \
    'gensim' \
    'mlxtend' \
    'tabulate' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER


# --- Install vowpalwabbit, hyperopt, tpot, sklearn-deap, yellowbrick, spacy
RUN $CONDA_DIR/bin/python -m pip install vowpalwabbit \
					 hyperopt \
					 tqdm \
					 tpot \
					 yellowbrick \
					 spacy \
                                         skope-rules \
					 shap \
					 lime 

###########
#
# Add some usefull libs, inspired by kaggle's Dockerfile
# CREDITS : https://hub.docker.com/r/kaggle/python/dockerfile
#
###########
RUN $CONDA_DIR/bin/python -m pip install --upgrade scikit-learn \
                                                   pandas
RUN $CONDA_DIR/bin/python -m pip install plotly \
					 git+https://github.com/nicta/dora.git \
					 git+https://github.com/hyperopt/hyperopt.git \
# tflean. Deep learning library featuring a higher-level API for TensorFlow. http://tflearn.org
					 git+https://github.com/tflearn/tflearn.git \
					 heamy \
					 vida \
# Useful data exploration libraries (for missing data and generating reports)
					 missingno \
					 tables
# clean up pip cache
RUN rm -rf /root/.cache/pip/*

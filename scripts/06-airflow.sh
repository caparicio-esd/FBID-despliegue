#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid/01_practica_fbid_standalone
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi

PROJECT_HOME=$CWD_FBID1
AIRFLOW_HOME=$CWD_FBID1/resources/airflow
pip install -r $AIRFLOW_HOME/requirements.txt -c $AIRFLOW_HOME/constraints.txt
pip install -U setproctitle
mkdir $AIRFLOW_HOME/dags
mkdir $AIRFLOW_HOME/logs
mkdir $AIRFLOW_HOME/plugins

AIRFLOW__CORE__DAGS_FOLDER=$AIRFLOW_HOME/dags

# airflow db init
sudo airflow users create \
    --username admin \
    --firstname Jack \
    --lastname Sparrow \
    --role Admin \
    --pass aa \
    --email example@mail.org

airflow scheduler -D --pid ./
sudo airflow webserver --host 127.0.0.1 --port 8081 -d

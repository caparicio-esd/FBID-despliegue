#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid/01_practica_fbid_standalone
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi


# ========================================
# WEBAPP
# ========================================
export PROJECT_HOME=$CWD_FBID1
cd $CWD_FBID1/resources/web
firefox 127.0.0.1:5001 &
python3 predict_flask.py

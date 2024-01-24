#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi

# ========================================
# TRAIN MODEL
# ========================================

cd $CWD_FBID1
./resources/download_data.sh
export JAVA_HOME=/Users/apabook/.sdkman/candidates/java/current
export SPARK_HOME=./lib/spark-3.3.4-bin-hadoop3-scala2.13
python3 ./resources/train_spark_mllib_model.py .
ls ./models
#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi

SCALA_VERSION=2.13
SPARK_VERSION=3.3.4
KAFKA_VERSION=3.3.0


# ========================================
# PREDICTION JOB
# ========================================

# PACKAGE JAR
cd $CWD_FBID1
cd flight_prediction
sbt clean package

# SUBMIT APPLICATION
cd $CWD_FBID1
SPARK_LIB=${CWD_FBID1}/lib/spark-${SPARK_VERSION}-bin-hadoop3-scala${SCALA_VERSION}
cd ${SPARK_LIB}/bin/
./spark-submit \
    --class "es.upm.dit.ging.predictor.MakePredictionCassandra" \
    --packages org.mongodb.spark:mongo-spark-connector_${SCALA_VERSION}:10.1.1,org.apache.spark:spark-sql-kafka-0-10_${SCALA_VERSION}:${KAFKA_VERSION},com.datastax.spark:spark-cassandra-connector_${SCALA_VERSION}:3.4.1 \
    --supervise \
    ${CWD_FBID1}/flight_prediction/target/scala-2.13/flight_prediction_2.13-0.1.jar
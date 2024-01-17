#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid/01_practica_fbid_standalone
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi


# ========================================
# STARTING SERVICES
# ========================================


# ZOOKEEPER
ZOOKEEPER_LIB=${CWD_FBID1}/lib/apache-zookeeper-3.8.3-bin
cd ${ZOOKEEPER_LIB}/bin/
./zkServer.sh start

# KAFKA
KAFKA_LIB=${CWD_FBID1}/lib/kafka_2.13-3.4.0
cd ${KAFKA_LIB}/bin/
./kafka-server-start.sh -daemon ./../config/server.properties
./kafka-topics.sh \
    --create \
    --bootstrap-server localhost:9092 \
    --replication-factor 1 \
    --partitions 1 \
    --topic flight_delay_classification_request
./kafka-topics.sh \
    --create \
    --bootstrap-server localhost:9092 \
    --replication-factor 1 \
    --partitions 1 \
    --topic flight_delay_classification_response


# MONGO
MONGO_LIB=${CWD_FBID1}/lib/mongodb-macos-x86_64-7.0.4
cd ${MONGO_LIB}/bin/
MONGO_DATA=./../../data
MONGO_LOGS=./../../mongo_logs

./mongod --dbpath $MONGO_DATA --fork --logpath $MONGO_LOGS


# CASSANDRA
CASSANDRA_LIB=${CWD_FBID1}/lib/apache-cassandra-4.0.11
cd ${CASSANDRA_LIB}/bin/
./cassandra
./cqlsh -e "create keyspace if not exists agile_data_science with replication = {'class': 'SimpleStrategy', 'replication_factor': 1}"
./cqlsh -e "\
    create table if not exists agile_data_science.flight_delay_classification_response ( \
        uuid uuid PRIMARY KEY, \
        \"Origin\" text, \
        \"DayOfWeek\" int, \
        \"DayOfYear\" int, \
        \"DayOfMonth\" int, \
        \"Dest\" text, \
        \"DepDelay\" int, \
        \"Timestamp\" timestamp, \
        \"FlightDate\" timestamp, \
        \"Carrier\" text, \
        \"Distance\" int, \
        \"Route\" text, \
        \"Prediction\" int \
    )"


# UPDATE DISTANCES IN MONGO
cd $CWD_FBID1
./resources/import_distances.sh
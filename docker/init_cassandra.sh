#!/usr/bin/env bash

cqlsh cassandra -e "create keyspace if not exists agile_data_science with replication = {'class': 'SimpleStrategy', 'replication_factor': 1}"
cqlsh cassandra -e "\
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

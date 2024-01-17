#!/usr/bin/env bash

KAFKA_BIN=/opt/bitnami/kafka/bin

${KAFKA_BIN}/kafka-topics.sh \
    --create \
    --bootstrap-server kafka:9092 \
    --replication-factor 1 \
    --partitions 1 \
    --topic flight_delay_classification_request

${KAFKA_BIN}/kafka-topics.sh \
    --create \
    --bootstrap-server kafka:9092 \
    --replication-factor 1 \
    --partitions 1 \
    --topic flight_delay_classification_response
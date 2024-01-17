#!/usr/bin/env bash

SCALA_VERSION=2.12
KAFKA_VERSION=3.4.0
SPARK_BIN=/opt/bitnami/spark/bin
chmod +x /jars/*

${SPARK_BIN}/spark-submit \
    --class "es.upm.dit.ging.predictor.MakePredictionCassandra" \
    --packages org.mongodb.spark:mongo-spark-connector_${SCALA_VERSION}:10.1.1,org.apache.spark:spark-sql-kafka-0-10_${SCALA_VERSION}:${KAFKA_VERSION},com.datastax.spark:spark-cassandra-connector_${SCALA_VERSION}:3.4.1 \
    --supervise \
    --master spark://spark-master:7077 \
    /jars/flight_prediction_2.12-0.1.jar
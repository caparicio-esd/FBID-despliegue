#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi


# VERSIONS
SCALA_VERSION=2.13
SPARK_VERSION=3.3.4
ZOOKEEPER_VERSION=3.8.3
KAFKA_VERSION=3.4.0
MONGO_VERSION=7.0.4
MONGOSH_VERSION=2.1.1
MONGO_DBT=100.9.4
CASSANDRA_VERSION=4.0.11


# DOWLOAD LIB
# Change if needed based on the system. 
# All downloads below are prepared for Mac OSX
ZOOKEEPER_MIRROR=https://dlcdn.apache.org/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz
KAFKA_MIRROR=https://archive.apache.org/dist/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz
MONGO_MIRROR=https://fastdl.mongodb.org/osx/mongodb-macos-x86_64-${MONGO_VERSION}.tgz
MONGO_DBT_MIRROR=https://fastdl.mongodb.org/tools/db/mongodb-database-tools-macos-x86_64-${MONGO_DBT}.zip
MONGO_SHELL_MIRROR=https://downloads.mongodb.com/compass/mongosh-${MONGOSH_VERSION}-darwin-x64.zip
SPARK_MIRROR=https://dlcdn.apache.org/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3-scala${SCALA_VERSION}.tgz
CASSANDRA_MIRROR=https://dlcdn.apache.org/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz

# ZOOKEEPER
curl -o ./lib/zookeeper $ZOOKEEPER_MIRROR
tar -xzvf ./lib/zookeeper ./lib/
rm ./lib/zookeeper

# KAFKA
curl -o ./lib/kafka $KAFKA_MIRROR
tar -xzvf ./lib/kafka ./lib/
rm ./lib/kafka

# MONGO
curl -o ./lib/mongo $MONGO_MIRROR
tar -xzvf ./lib/mongo ./lib/
rm ./lib/mongo

# MONGO_DBT
curl -o ./lib/mongodbt $MONGO_DBT_MIRROR
tar -xzvf ./lib/mongodbt ./lib/
rm ./lib/mongodbt

# MONGO_SHELL
curl -o ./lib/mongosh $MONGO_SHELL_MIRROR
tar -xzvf ./lib/mongosh ./lib/
rm ./lib/mongosh

# SPARK
curl -o ./lib/spark $SPARK_MIRROR
tar -xzvf ./lib/spark -C ./lib/
rm ./lib/spark


# CASSANDRA
curl -o ./lib/cassandra $CASSANDRA_MIRROR
tar -xzvf ./lib/cassandra -C ./lib/
rm ./lib/cassandra

# INSTALLING STUFF AND VENV
deactivate
rm -rf env
python3 -m venv env
sleep 5
source ./env/bin/activate
sleep 5
which python
which pip
pip install --upgrade pip
pip install -r ./requirements.txt

#!/usr/bin/env bash


mongoimport \
    -d $MONGO_DB \
    -c $MONGO_COLLECTION_DISTANCES \
    --file /data/origin_dest_distances.jsonl \
    --uri mongodb://$MONGO_HOST:$MONGO_PORT

mongosh \
    mongodb://$MONGO_HOST:$MONGO_PORT/$MONGO_DB \
    --eval 'db.origin_dest_distances.ensureIndex({Origin: 1, Dest: 1})'
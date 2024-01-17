#!/bin/bash



# Import our enriched airline data as the 'airlines' collection
MONGOIMPORT="lib/mongodb-database-tools-macos-x86_64-100.9.4/bin/mongoimport"
MONGO="lib/mongosh-2.1.1-darwin-x64/bin/mongosh"

$MONGO agile_data_science --eval 'db.origin_dest_distances.deleteMany({})'
$MONGOIMPORT -d agile_data_science -c origin_dest_distances --file data/origin_dest_distances.jsonl
$MONGO agile_data_science --eval 'db.origin_dest_distances.ensureIndex({Origin: 1, Dest: 1})'


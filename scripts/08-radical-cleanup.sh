#!/bin/bash

# Ensure launching cwd
CWD_FBID1=/Users/apabook/Desktop/fbid
if [ "$CWD_FBID1" != "$PWD" ]; then
    echo "Script must be runned in a specified directory"
    exit 1
fi

$CWD_FBID1/scripts/07-cleanup.sh
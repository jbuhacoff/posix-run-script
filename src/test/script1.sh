#!/bin/bash

export RS_PATH=./lib

SCRIPT_PATH=$(rs --locate verbose)

if [ "$SCRIPT_PATH" == "./lib/verbose.sh" ]; then
    exit 0
else
    exit 1
fi

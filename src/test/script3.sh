#!/bin/bash

export RS_PATH=./lib2:./lib
export VERBOSE=yes

rs verbose hello script3

# expected output: verbose in lib2: hello script3

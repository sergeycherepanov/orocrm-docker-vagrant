#!/bin/bash
bash -c "$2" 2>&1 | awk '{print "['$1'] " $0}'

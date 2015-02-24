#!/usr/bin/env bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

if [ -f "$bin/tpc-h.tsql" ]; then
   "$bin/tsql" -f $bin/tpc-h.tsql
else
   echo "command configure.sh before run."
fi


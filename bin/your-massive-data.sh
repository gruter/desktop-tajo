#!/usr/bin/env bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`


if [ -f "$bin/tpc-h.tsql" ]; then
   RESULT=`"$bin/tsql" -f $bin/tpc-h.tsql`
   if [[ $RESULT == *"ERROR:"* ]]; then
      echo "Failure in creating test databases and tables."
   else
      echo "Databases and tables for test were successfully created."
   fi
else
   echo "command configure.sh before run."
fi

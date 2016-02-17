#!/usr/bin/env bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
source $bin/config.sh

if [ -f "${tajo_home}/bin/tpc-h.tsql" ]; then
   RESULT=`"${tajo_home}/bin/tsql" -f "${tajo_home}/bin/tpc-h.tsql"`
   if [[ $RESULT == *"ERROR:"* ]]; then
      echo "Failure in creating test databases and tables."
   else
      echo "Databases and tables for test were successfully created."
   fi
else
   echo "command desktop-configure.sh before run."
fi

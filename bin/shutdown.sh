#!/usr/bin/env bash

function stop_master {
  "$tajo_home"/bin/tajo-daemon.sh stop master
  echo "Tajo master stopped"
}
function stop_worker {
  "$tajo_home"/bin/tajo-daemon.sh stop worker
  echo "Tajo worker stopped"
}

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
source $bin/config.sh

stop_master
stop_worker

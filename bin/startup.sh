#!/usr/bin/env bash

function start_master {
  "$tajo_home"/bin/tajo-daemon.sh start master
  echo "Tajo master started"
}
function start_worker {
  "$tajo_home"/bin/tajo-daemon.sh start worker
  echo "Tajo worker started"
}
function print_info {
  HTTP_ADDRESS=$("$tajo_home"/bin/tajo getconf tajo.master.info-http.address)
  RPC_ADDRESS=$("$tajo_home"/bin/tajo getconf tajo.master.client-rpc.address)
  HTTP_ADDRESS=(${HTTP_ADDRESS//:/ })
  RPC_ADDRESS=(${RPC_ADDRESS//:/ })

  if [ ${HTTP_ADDRESS[0]} = "0.0.0.0" ] ||
  [ ${HTTP_ADDRESS[0]} = "127.0.0.1" ] ||
  [ ${HTTP_ADDRESS[0]} = "localhost" ]; then
    HTTP_ADDRESS[0]=`hostname`
  fi

  if [ ${RPC_ADDRESS[0]} = "0.0.0.0" ] ||
  [ ${RPC_ADDRESS[0]} = "127.0.0.1" ] ||
  [ ${RPC_ADDRESS[0]} = "localhost" ]; then
    RPC_ADDRESS[0]=`hostname`
  fi

  echo "Tajo master web UI: http://${HTTP_ADDRESS[0]}:${HTTP_ADDRESS[1]}"
  echo "Tajo Client Service: ${RPC_ADDRESS[0]}:${RPC_ADDRESS[1]}"
}

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
source $bin/config.sh

start_master
start_worker
print_info

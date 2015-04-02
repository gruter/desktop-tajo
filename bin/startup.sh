#!/usr/bin/env bash

function start_master {
    "$bin"/tajo-daemon.sh start master
    echo -n "Tajo master starting."
    # check master running
    nc -z localhost 26003
    while [ $? -eq 1 ]; do
        echo -n "."
            sleep 1
            nc -z localhost 26003
    done
    echo "Tajo master started."
}
function start_worker {
    echo ""
    "$bin"/tajo-daemon.sh start worker
    echo "Tajo worker started."
    echo ""
    echo "Tajo master web UI"
    echo "http://localhost:26080"
}
function print_usage {
    echo "Usage: $1 [master|worker]"
}

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/tajo-config.sh
if [ -f "${TAJO_CONF_DIR}/tajo-env.sh" ]; then
   . "${TAJO_CONF_DIR}/tajo-env.sh"
fi

if [ $# -le 0 ]; then
    start_master
    start_worker
else
    masterWorker=$1
    case $masterWorker in
    (master)
        start_master
        ;;
    (worker)
        start_worker
        ;;
    (*)
        print_usage $0
        exit 1
        ;;
    esac
fi
#!/usr/bin/env bash

function stop_master {
    "$bin"/tajo-daemon.sh stop master
    echo -n "Tajo master stopping."
    # check master running
    nc -z localhost 26003
    while [ $? -ne 1 ]; do
        echo -n "."
            sleep 1
            nc -z localhost 26003
    done
    echo "Tajo master stopped."
}
function stop_worker {
    echo ""
    "$bin"/tajo-daemon.sh stop worker
    echo "Tajo worker stopped."
    echo ""
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
   stop_master
   stop_worker
else
    masterWorker=$1
    case $masterWorker in
    (master)
        stop_master
        exit 1
        ;;
    (worker)
        stop_worker
        exit 1
        ;;
    (*)
        print_usage $0
        exit 1
        ;;
    esac
fi
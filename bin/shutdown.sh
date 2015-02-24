#!/usr/bin/env bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/tajo-config.sh
if [ -f "${TAJO_CONF_DIR}/tajo-env.sh" ]; then
   . "${TAJO_CONF_DIR}/tajo-env.sh"
fi
"$bin"/tajo-daemon.sh stop master
"$bin"/tajo-daemon.sh stop worker

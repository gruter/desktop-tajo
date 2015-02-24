#!/usr/bin/env bash

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`

. "$bin"/tajo-config.sh
if [ -f "${TAJO_CONF_DIR}/tajo-env.sh" ]; then
   . "${TAJO_CONF_DIR}/tajo-env.sh"
fi
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
echo ""
"$bin"/tajo-daemon.sh start worker
echo "Tajo worker started."
echo ""
echo "Tajo master web UI"
echo "http://localhost:26080"

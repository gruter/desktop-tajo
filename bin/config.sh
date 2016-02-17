bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
java_home=$JAVA_HOME
tajo_home=`cd "$bin/../"; pwd`
hadoop_home="$tajo_home"/hadoop

source "$tajo_home"/bin/tajo-config.sh
if [ -f "${TAJO_CONF_DIR}/tajo-env.sh" ]; then
   source "${TAJO_CONF_DIR}/tajo-env.sh"
fi

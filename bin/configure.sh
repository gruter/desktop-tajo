#!/usr/bin/env bash

function start_configuration {
echo "<?xml version=\"1.0\"?>"
echo "<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>"
echo "<configuration>"
}
function set_property {
echo "<property><name>$1</name><value>$2</value></property>"
}
function end_configuration {
echo "</configuration>"
}

bin=`dirname "$0"`
bin=`cd "$bin"; pwd`
java_home=$JAVA_HOME
tajo_home=`cd "$bin/../"; pwd`
tajo_root_dir="file://$tajo_home/data/tajo"
tajo_staging_dir="file://$tajo_home/data/staging"
tajo_temp_dir="$tajo_home/data/tempdir"
tajo_worker_heap=1024
#cpu_cores=$(grep -c processor /proc/cpuinfo)
disk_count=0
input_param=$1
if [ "$input_param" != "-f" ];then #----wrap param start
   if [ -z $java_home ]; then
      echo "Enter JAVA_HOME [required]"
      read java_home
   else
      echo "Enter JAVA_HOME [default: $java_home]"
      read set_java_home
      if [ ! -z $set_java_home ]; then
         java_home=$set_java_home
      fi
   fi
   while [ 1 ]
   do
      if [ -z $java_home ]; then
         echo "Enter JAVA_HOME [required]"
         read java_home
         continue
      else
         break
      fi
   done
   echo "Would you like advanced configure? [y/N]"
   read advanced
   if  [ ! -z $advanced ] && [ $advanced = "y" ]
   then
      echo "Enter tajo.rootdir [default: $tajo_root_dir]"
      read t_tajo_root_dir
      if [ ! -z $t_tajo_root_dir ]; then
         tajo_root_dir=$t_tajo_root_dir
      fi
      echo "Enter tajo.staging.directory [default: $tajo_staging_dir]"
      read t_tajo_staging_dir
      if [ ! -z $t_tajo_staging_dir ]; then
         tajo_staging_dir=$t_tajo_staging_dir
      fi
      echo "Enter tajo.worker.tmpdir.locations [default: $tajo_temp_dir]"
      read t_tajo_temp_dir
      if [ ! -z $t_tajo_temp_dir ]; then
         tajo_temp_dir=$t_tajo_temp_dir
      fi
      echo "Enter heap size(MB) for worker [default: $tajo_worker_heap]"
      read t_tajo_worker_heap
      if [ ! -z $t_tajo_worker_heap ]; then
         tajo_worker_heap=$t_tajo_worker_heap
      fi
   fi
fi #----wrap param end
tajo_worker_concurrency=$(( ${tajo_worker_heap} / 2400 ))
if [ $tajo_worker_concurrency -le 1 ]; then
   tajo_worker_concurrency=1
fi
tajo_worker_resource_memory=$(( (${tajo_worker_concurrency} * 512) + 512 ))
for d in `echo $tajo_temp_dir | sed -e s/\,/\ /g`
do
        disk_count=$(( ${disk_count} + 1 ))
done
if [ ! -d "${tajo_home}/conf" ]; then
   mkdir ${tajo_home}/conf
fi
if [ -f "${tajo_home}/conf/tajo-env.sh" ]; then
   rm ${tajo_home}/conf/tajo-env.sh
fi
echo "export TAJO_WORKER_STANDBY_MODE=true" >> ${tajo_home}/conf/tajo-env.sh
echo "export JAVA_HOME=$java_home" >> ${tajo_home}/conf/tajo-env.sh
echo "export HADOOP_HOME=$tajo_home/hadoop" >> ${tajo_home}/conf/tajo-env.sh
echo "export TAJO_PID_DIR=$tajo_home/pids" >> ${tajo_home}/conf/tajo-env.sh
echo "export TAJO_WORKER_HEAPSIZE=$tajo_worker_heap" >> ${tajo_home}/conf/tajo-env.sh
if [ ! -d $tajo_home/pids ]
then
   mkdir $tajo_home/pids
fi
chmod 755 ${tajo_home}/conf/tajo-env.sh

if [ -f "${tajo_home}/conf/tajo-site.xml" ]; then
   rm ${tajo_home}/conf/tajo-site.xml
fi
echo $(start_configuration) >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.rootdir" "${tajo_root_dir}") >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.staging.directory" "${tajo_staging_dir}") >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.worker.tmpdir.locations" ${tajo_temp_dir}) >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.worker.resource.memory-mb" ${tajo_worker_resource_memory}) >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.task.memory-slot-mb.default" "512") >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.worker.resource.disks" "${disk_count}.0") >> ${tajo_home}/conf/tajo-site.xml
#echo $(set_property "tajo.worker.resource.cpu-cores" ${cpu_cores}) >> ${tajo_home}/conf/tajo-site.xml
echo $(set_property "tajo.worker.start.cleanup" "true") >> ${tajo_home}/conf/tajo-site.xml
echo $(end_configuration) >> ${tajo_home}/conf/tajo-site.xml

if [ -f "${tajo_home}/conf/catalog-site.xml" ]; then
   rm ${tajo_home}/conf/catalog-site.xml
fi
echo $(start_configuration) >> ${tajo_home}/conf/catalog-site.xml
echo $(set_property "tajo.catalog.store.class" "org.apache.tajo.catalog.store.DerbyStore") >> ${tajo_home}/conf/catalog-site.xml
echo $(set_property "tajo.catalog.uri" "jdbc:derby:${tajo_home}/data/tajo-catalog;create=true") >> ${tajo_home}/conf/catalog-site.xml
echo $(end_configuration) >> ${tajo_home}/conf/catalog-site.xml

if [ -f "${tajo_home}/bin/tpc-h.tsql" ]; then
   rm ${tajo_home}/bin/tpc-h.tsql
fi
echo "CREATE DATABASE IF NOT EXISTS tpc_h10m;" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.supplier (S_SUPPKEY bigint, S_NAME text, S_ADDRESS text, S_NATIONKEY bigint, S_PHONE text, S_ACCTBAL double, S_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/supplier.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.lineitem (L_ORDERKEY bigint, L_PARTKEY bigint, L_SUPPKEY bigint, L_LINENUMBER bigint, L_QUANTITY double, L_EXTENDEDPRICE double, L_DISCOUNT double, L_TAX double, L_RETURNFLAG text, L_LINESTATUS text, L_SHIPDATE text, L_COMMITDATE text, L_RECEIPTDATE text, L_SHIPINSTRUCT text, L_SHIPMODE text, L_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/lineitem.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.part (P_PARTKEY bigint, P_NAME text, P_MFGR text, P_BRAND text, P_TYPE text, P_SIZE integer, P_CONTAINER text, P_RETAILPRICE double, P_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/part.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.partsupp (PS_PARTKEY bigint, PS_SUPPKEY bigint, PS_AVAILQTY int, PS_SUPPLYCOST double, PS_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/partsupp.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.customer (C_CUSTKEY bigint, C_NAME text, C_ADDRESS text, C_NATIONKEY bigint, C_PHONE text, C_ACCTBAL double, C_MKTSEGMENT text, C_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/customer.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.orders (O_ORDERKEY bigint, O_CUSTKEY bigint, O_ORDERSTATUS text, O_TOTALPRICE double, O_ORDERDATE text, O_ORDERPRIORITY text, O_CLERK text, O_SHIPPRIORITY int, O_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/orders.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.nation (N_NATIONKEY bigint, N_NAME text, N_REGIONKEY bigint, N_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/nation.txt';" >> ${tajo_home}/bin/tpc-h.tsql
echo "create external table IF NOT EXISTS tpc_h10m.region (R_REGIONKEY bigint, R_NAME text, R_COMMENT text) using csv with ('csvfile.delimiter'='|') location 'file://${tajo_home}/data/tpc-h10m/region.txt';" >> ${tajo_home}/bin/tpc-h.tsql

echo "Done. To start Tajo, run ${tajo_home}/bin/startup.sh"

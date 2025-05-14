#!/usr/bin/env bash
set -x

# Usage message
print_usage() {
  echo "To automatically load the Hadoop configuration, you must set the following variables:
          In case of AMBARI Manager:
          AMBARI_USER AMBARI_PASSWORD AMBARI_URL AMBARI_PORT CLUSTER_NAME
          If you see this message, then one or more variables are undefined and
          loading the Hadoop configuration will be skipped."
}
# List of variables to get hadoop conf from AMBARI
AMBARIVariablesArray=(
  AMBARI_USER \
  AMBARI_PASSWORD \
  AMBARI_URL \
  AMBARI_PORT \
  CLUSTER_NAME \
  )

# Check that all variables are defined
  for item in ${AMBARIVariablesArray[@]}; do
    if [ -z ${!item} ]; then
      print_usage
      exit 0
    fi
  done

echo "Start hadoop conf creation"
export TMP_HCC=~/tmp_hadoop_conf_creation
rm -rf $TMP_HCC
mkdir $TMP_HCC

AMBARI_HOST=$AMBARI_URL
  curlop=$(curl --insecure -s --write-out %{http_code} --user $AMBARI_USER:$AMBARI_PASSWORD https://$AMBARI_HOST:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/ -o /dev/null)
  if [ $curlop -eq "000" ]; then
    PROTOCOL="http"
  else
    PROTOCOL="https"
  fi

  curl --insecure --create-dirs --user $AMBARI_USER:$AMBARI_PASSWORD -H "X-Requested-By: AMBARI" -X GET $PROTOCOL://$AMBARI_HOST:$AMBARI_PORT/api/v1/clusters/$CLUSTER_NAME/services/HIVE/components/HIVE_CLIENT?format=client_config_tar -o $TMP_HCC/hadoop-conf.tar.gz
  mkdir $TMP_HCC/{unpacked,conf}
  tar -xvf $TMP_HCC/hadoop-conf.tar.gz -C $TMP_HCC/unpacked/  --warning=no-timestamp
  mkdir --parents /etc/hadoop/conf
  mv $TMP_HCC/unpacked/hive-site.xml /etc/hadoop/conf/hive-site.xml

rm -rf $TMP_HCC
echo "Hadoop configuration updated"

./build/env/bin/hue migrate
./build/env/bin/supervisor
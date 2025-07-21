#!/bin/bash

#
# Copyright 2019-2025 Ping Identity Corporation. All Rights Reserved
#

#. $FORGEROCK_HOME/debug.sh
#. $FORGEROCK_HOME/profiling.sh

#
# wait_for_datastore blocks until at least one of a set of DS instances is alive
#
wait_for_datastore() {
  local datastore=${1}
  echo "Waiting for ${datastore} to be available"
  local servers=$(echo ${2} | tr "," "\n") # split csv on comma
  while true; do
    for server in ${servers}; do
      local hostname=$(echo ${server} | cut -d ":" -f1)
      echo "Trying ${hostname}:8080/alive endpoint"
      local http_code=$(curl --silent --output /dev/null --write-out ''%{http_code}'' ${hostname}:8080/alive)
      if [[ ${http_code} == "200" ]]; then
        echo "${datastore} is responding"
        break 2 # break out of for loop _and_ while loop
      fi
    done
    sleep 5;
  done
}

wait_for_datastore "Data Store" "${AM_STORES_SERVERS}"

# If $TRUSTSTORE_PATH AND $TRUSTSTORE_PASSWORD are set, update $CATALINA_OPTS
if [ ! -z "$TRUSTSTORE_PATH" ] && [ ! -z "$TRUSTSTORE_PASSWORD" ]; then
    CATALINA_OPTS="$CATALINA_OPTS -Djavax.net.ssl.trustStore=$TRUSTSTORE_PATH \
                                  -Djavax.net.ssl.trustStorePassword=$TRUSTSTORE_PASSWORD \
                                  -Djavax.net.ssl.trustStoreType=jks"
fi

if [ ! -z "$JPDA_DEBUG" ]; then
  # For debugging purposes
  echo "****** Environment *************: "
  env | sort
fi

CATALINA_OPTS="$CATALINA_OPTS $AM_CONTAINER_JVM_ARGS $CATALINA_USER_OPTS"

echo "Starting tomcat with opts: ${CATALINA_OPTS}"
exec $CATALINA_HOME/bin/catalina.sh $JPDA_DEBUG run

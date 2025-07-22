#!/bin/bash

cat <<EOF > install-openam.generated.amster
install-openam \
 --serverUrl http://localhost:8080/am \
 --adminPwd $AM_ADMIN_PWD \
 --lbSiteName TestSite01 \
 --lbPrimaryUrl $AM_PROTOCOL://$FQDN:$AM_PORT/am \
 --cfgDir $AM_HOME \
 --acceptLicense \
 --cfgStoreDirMgr $AM_CFG_STORE_DIR_MGR \
 --cfgStoreDirMgrPwd $AM_STORES_PWD \
 --cfgStore dirServer \
 --cfgStoreHost $AM_STORES_HOST \
 --cfgStoreAdminPort $AM_CFG_STORE_ADMIN_PORT \
 --cfgStorePort $AM_STORES_PORT \
 --cfgStoreSsl SSL \
 --cfgStoreRootSuffix $AM_CFG_STORE_ROOT_SUFFIX \
 --userStoreDirMgr $AM_USR_STORE_DIR_MGR \
 --userStoreDirMgrPwd $AM_STORES_PWD \
 --userStoreHost $AM_STORES_HOST \
 --userStoreType LDAPv3ForOpenDS \
 --userStorePort $AM_STORES_PORT \
 --userStoreSsl SSL \
 --userStoreRootSuffix $AM_USR_STORE_ROOT_SUFFIX \
 --pwdEncKey $AM_ENCRYPTION_KEY

:exit
EOF

wait_for_am() {
  local am=${1}
  echo "Waiting for ${am} to be available"
  local servers=$(echo ${2} | tr "," "\n") # split csv on comma
  while true; do
    for server in ${servers}; do
      echo "Trying http://${server}:8080/am/isAlive.jsp endpoint"
      local http_code=$(curl --silent --output /dev/null --write-out ''%{http_code}'' ${server}:8080/am/isAlive.jsp)
      if [[ ${http_code} == "200" || ${http_code} == "302" ]]; then
        echo "${am} is responding"
		
        break 2 # break out of for loop _and_ while loop
      fi
    done
    sleep 5;
  done
}

wait_for_am "AM" "${FQDN}"

TRUSTSTORE_PASSWORD=$(cat $TRUSTSTORE_PIN_PATH)
if [ -d "$AM_HOME" ]; then
  if [ -z "$(ls -A "$AM_HOME")" ]; then
    echo "Directory '$AM_HOME' is empty. Performing installation process."
    # Add your commands here to be executed when the directory is empty
    $FORGEROCK_HOME/amster/amster -Djavax.net.ssl.trustStore=$TRUSTSTORE_PATH -Djavax.net.ssl.trustStoreType=jks -Djavax.net.ssl.trustStorePassword=$TRUSTSTORE_PASSWORD install-openam.generated.amster
	echo "Amster script done"
  else
    echo "Directory '$AM_HOME' is not empty. Means installation was done prior. Open a browser and load $AM_PROTOCOL://$FQDN:$AM_PORT/am to login using these credentials - "
	echo "Username: amadmin"
	echo "Password: $AM_ADMIN_PWD"
  fi
else
  echo "Directory '$AM_HOME' does not exist."
fi

rm -f install-openam.generated.amster
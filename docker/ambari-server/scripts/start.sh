#!/usr/bin/env bash

#
# This bash script will initialize/setup Ambari and the external postgres database on first run,
# and then start Amabari. After the first successful start, setup will not happen again.
#
# The following environment variables are recognized:
#    AMBARI_OS_USER     The OS user to use to setup Ambari on first run. Default 'root'
#    AMBARI_DB_HOST     The hostname of the external Postgres DB to use for Ambari. Default 'postgres'
#    AMBARI_DB_USER     The database user Ambari will create and use to access the DB. Default 'ambari'
#    AMBARI_DB_PASSWORD The password for the Ambari database user. Default 'bigdata'
#    AMBARI_DB_NAME     The name of the database that Ambari will create for itself. Default 'ambari'
#    AMBARI_DB_SCHEMA   The name of the database schema that Ambari will create for itself. Default 'ambari'
#    DEBUG              Set to any non-zero length value to enable debug output for this script. Unset to disable.
#

# Enable DEBUG output if enabled
[ -n "$DEBUG" ] && set -x

[[ -z $AMBARI_OS_USER ]] && AMBARI_OS_USER=root
[[ -z $AMBARI_DB_USER ]] && AMBARI_DB_USER=ambari
[[ -z $AMBARI_DB_NAME ]] && AMBARI_DB_NAME=ambari
[[ -z $AMBARI_DB_SCHEMA ]] && AMBARI_DB_SCHEMA=ambari
[[ -z $AMBARI_DB_PASSWORD ]] && AMBARI_DB_PASSWORD=bigdata
[[ -z $AMBARI_DB_HOST ]] && AMBARI_DB_HOST=postgres  # expected to be running in another container on the same docker network

startedFile="/root/container-was-started"
if [ ! -e "$startedFile" ] ; then
  # container hasn't been started yet, additional setup steps should run

  sleep 5  # wait for the database on an external host to startup in case these containers were launched together
  
  /root/database-setup.sh \
    --ambari-db-user $AMBARI_DB_USER \
    --ambari-db-name $AMBARI_DB_NAME \
    --ambari-db-schema $AMBARI_DB_SCHEMA \
    --ambari-db-password $AMBARI_DB_PASSWORD \
    --database-hostname $AMBARI_DB_HOST

  /root/ambari-setup.sh \
    --os-user $AMBARI_OS_USER \
    --ambari-db-user $AMBARI_DB_USER \
    --ambari-db-name $AMBARI_DB_NAME \
    --ambari-db-schema $AMBARI_DB_SCHEMA \
    --ambari-db-password $AMBARI_DB_PASSWORD \
    --database-hostname $AMBARI_DB_HOST
fi

ambari-server start

if [ ! -e "$startedFile" ] ; then
  # ambari successfully started, create startedFile to prevent ambari db setup steps above from running
  touch $startedFile
fi

tail -f /var/log/ambari-server/ambari-server.log

#!/usr/bin/env bash

[[ -z $AMBARI_SERVER_HOSTNAME ]] && sed -i "s/^hostname=.*/hostname=$AMBARI_SERVER_HOSTNAME/g" /etc/ambari-agent/conf/ambari-agent.ini

ambari-agent start

tail -f /var/log/ambari-agent/ambari-agent.log

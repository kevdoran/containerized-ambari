FROM ubuntu:16.04

ARG ambari_repo=http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.1.0/ambari.list
ARG default_ambari_server_hostname=ambari-server

# add ambari ubuntu repository
RUN apt-get update
RUN apt-get install -y wget sudo
RUN wget -O /etc/apt/sources.list.d/ambari.list $ambari_repo
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update

RUN apt-get install -y ambari-agent

ADD scripts/start.sh /root/start.sh
RUN chmod +x /root/start.sh

# this sets the default hostname. at runtime, it can be overwritten with the AMBARI_SERVER_HOSTNAME env var
RUN sed -i "s/^hostname=.*/hostname=$default_ambari_server_hostname/g" /etc/ambari-agent/conf/ambari-agent.ini

ENTRYPOINT  ["/root/start.sh"]

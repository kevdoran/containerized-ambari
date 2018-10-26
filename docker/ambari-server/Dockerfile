FROM ubuntu:16.04

ARG ambari_repo=http://public-repo-1.hortonworks.com/ambari/ubuntu16/2.x/updates/2.7.1.0/ambari.list
ARG hdp_utils_repo=http://public-repo-1.hortonworks.com/HDP-UTILS-1.1.0.22/repos/ubuntu16
ARG default_ambari_os_user=root
ARG default_ambari_db_name=ambari
ARG default_ambari_db_user=ambari
ARG default_ambari_db_schema=ambari
ARG default_ambari_db_password=bigdata
ARG default_database_hostname=postgres

VOLUME /resources

# add ambari ubuntu repository
RUN apt-get update
RUN apt-get install -y wget sudo
RUN wget -O /etc/apt/sources.list.d/ambari.list $ambari_repo
RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com B9733A7A07513CAD
RUN apt-get update

RUN apt-get install -y ambari-server

ADD scripts/ambari-setup.sh /root/ambari-setup.sh
RUN chmod +x /root/ambari-setup.sh

ADD scripts/init_postgres.sql /root/init_postgres.sql
ADD scripts/init_ambari_database.sql /root/init_ambari_database.sql
ADD scripts/database-setup.sh /root/database-setup.sh
RUN chmod +x /root/database-setup.sh

ADD scripts/start.sh /root/start.sh
RUN chmod +x /root/start.sh

# TODO, write default values somewhere where they can be read by the start script when running a container

EXPOSE 8080
ENTRYPOINT  ["/root/start.sh"]

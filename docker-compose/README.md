# Containerized Ambari: Docker Compose

An alternative to using the `build.sh` and `run.sh` scripts in the `docker/` directory is to launch and manage environments using `docker-compose`. The docker-compose tool will use the included [docker-compose.yml](./docker-compose.yml) configuration to build images, create (and scale) containers, etc.

# Quick Start with docker-compose

From the docker-compose directory in the repository, you can use the following commands:

    # create and start a new Ambari cluster with N agent nodes, detached 
    docker-compose up -d --scale ambari-agent=N
    
    # view the logs
    docker-compose logs -f
    
    # stop the cluster
    docker-compose stop
    
    # start the cluster (note, it is recommended to enable auto service start for all Ambari services)
    docker-compose start
    
    # add an agent node to the cluster (not sure if this is recommended after installing Ambari services)
    docker-compose up -d --scale ambari-agent=N+1
    
    # rebuild one of the locally-built images (should not need to do this outside of developement)
    docker-compose build <service-name>
    # e.g.
    docker-compose build ambari-server
    
    # destroy the cluster (actaully removes the containers, data, and configuration so be careful!)
    docker-compose down

If running docker-compose from another directory, you can use the `-f` option to sepcify the location of the docker-compose.yml file. For example:

    docker-compose -f /path/to/docker-compose.yml up -d --scale ambari-agent=N
   
To generate a dynmaic docker-compose, use the `-f` flag with `-` as the value to stpecify reading from STDIN. For example:

    my-command-that-writes-YAML-to-STDOUT | docker-compose -f - up -d --scale ambari-agent=N

Note that the -f argument must come before the docker-compose subcommand (`up` in the above example) and included every time you invoke `docker-compose` command to manage your containerized ambari environmnet.


# Configuring docker-compose.yml

The repositoriy includes an example [docker-compose.yml](./docker-compose.yml) that you can use directly (see quick start above). It includes the following containerized services:

## Reverse Proxy (Traefik)

A [Traefik](https://github.com/containous/traefik) proxy that exposes other services to the host machine, such as the Ambari UI.

When the service is running, you can access its dashboard web UI in Chrome at http://localhost:8080

## Ambari Server

Manages the Ambari cluster on the various Ambari Agent containers. When the service is running and the Traefik Reverse Proxy is running, the Ambari Server Web UI is accessible at http://ambari-server.docker.localhost

The docker image for the Ambari Server service is built from the local [Dockerfile](../docker/ambari-server) the first time that `docker-compose up` is run. This can take a long time and configures the local server as well as the database (postgres, see below). After the initial container is built, it is tagged and will not need to be re-built unless `docker-compose down` or `docker-compose build` is run.

If you have built the Ambari Server image already and want to use that image instead of building it from the Dockerfile, simply make the following change `ambari-server` service definition:

    ambari-server:
      build:
        context: ../docker/ambari-server
      ### Remove the build settings above, specify your pre-built image name below ###
      image: ambari-server-ubuntu
      ...

The following configuration options for the Ambari Server are controlled by the container's evironment:

| Environment Variable | Default | Description |
| --- | --- | --- |
| `AMBARI_OS_USER` | root | The OS user to use to setup Ambari on first run |
| `AMBARI_DB_HOST` | postgres | The hostname of the Postgres DB service | 
| `AMBARI_DB_USER` | ambari | The database user Ambari will create and use to access the DB |
| `AMBARI_DB_PASSWORD` | bigdata | The password for the Ambari database user |
| `AMBARI_DB_NAME` | ambari | The name of the database that Ambari will create for itself |
| `AMBARI_DB_SCHEMA` | ambari | The name of the database schema that Ambari will create for itself  |

Note that if you change the service name or alias of the Postgres database in the docker-compose.yml file, then the value of `AMBARI_DB_HOST` should be updated to reflect a hostname that will be accessible to the Ambari Server service.

## Ambari Agent

This service should be scaled to the number of Ambari cluster nodes you wish to have available. For example, if you wish to have three Ambari agents to target for your HDP or HDF cluster, you would first create the docker-compose environment using the scale option:

    docker-compose up -d --scale ambari-agent=3
    
This will create three ambari-agent containers, and each one will start an agent process that registers itself with the Ambari Server (note, this is done eagerly with retry, so if the agent containers start before the Ambari Server process is done loading, you can ignore any "connection failed" log messages from the Agent).

The following configuration options for the Ambari Agent are controlled by the container's evironment:

| Envrionment Variable | Default | Description |
| --- | --- | --- |
| `AMBARI_SERVER_HOSTNAME` | ambari-server | The hostname of the Ambari Server service |

Note that if you change the service name or alias of the Ambari Server in the docker-compose.yml file, then the value of `AMBARI_SERVER_HOSTNAME` should be updated to reflect a hostname that will be accessible to the Ambari Agent containers.

## Postgres

A database from on the official Postgres 9.6 dockerhub image. Ambari Server will initialize the user and schema on first startup.



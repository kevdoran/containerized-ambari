CREATE DATABASE :AMBARI_DB_NAME; -- check if db/user exists first, since if not exists isn't supported
CREATE ROLE :AMBARI_DB_USER WITH PASSWORD :'AMBARI_DB_PASSWORD' LOGIN;
GRANT ALL PRIVILEGES ON DATABASE :AMBARI_DB_NAME TO :AMBARI_DB_USER;
\connect :AMBARI_DB_NAME;
CREATE SCHEMA IF NOT EXISTS :AMBARI_DB_SCHEMA AUTHORIZATION :AMBARI_DB_USER;
ALTER SCHEMA :AMBARI_DB_SCHEMA OWNER TO :AMBARI_DB_USER;
ALTER ROLE :AMBARI_DB_USER SET search_path to :AMBARI_DB_SCHEMA, 'public';

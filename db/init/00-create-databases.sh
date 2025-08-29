#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
  DO
  $$
  BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'outline') THEN
      CREATE ROLE outline LOGIN PASSWORD '${OUTLINE_DB_PASSWORD}';
    END IF;
  END
  $$;
  CREATE DATABASE outline OWNER outline;
  GRANT ALL PRIVILEGES ON DATABASE outline TO outline;

  DO
  $$
  BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'keycloak') THEN
      CREATE ROLE keycloak LOGIN PASSWORD '${KEYCLOAK_DB_PASSWORD}';
    END IF;
  END
  $$;
  CREATE DATABASE keycloak OWNER keycloak;
  GRANT ALL PRIVILEGES ON DATABASE keycloak TO keycloak;

  DO
  $$
  BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'n8n') THEN
      CREATE ROLE n8n LOGIN PASSWORD '${N8N_DB_PASSWORD}';
    END IF;
  END
  $$;
  CREATE DATABASE n8n OWNER n8n;
  GRANT ALL PRIVILEGES ON DATABASE n8n TO n8n;
EOSQL

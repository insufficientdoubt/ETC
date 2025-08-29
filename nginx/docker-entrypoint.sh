#!/usr/bin/env bash
set -euo pipefail

: "${ENABLE_TLS:=true}"
: "${DOCS_DOMAIN:?DOCS_DOMAIN required}"
: "${AUTH_DOMAIN:?AUTH_DOMAIN required}"
: "${FLOW_DOMAIN:?FLOW_DOMAIN required}"

mkdir -p /etc/nginx/conf.d

if [ "${ENABLE_TLS}" = "true" ]; then
  envsubst '$DOCS_DOMAIN $AUTH_DOMAIN $FLOW_DOMAIN' < /templates/nginx.conf.ssl.template > /etc/nginx/nginx.conf
  envsubst '$DOCS_DOMAIN' < /templates/docs.ssl.conf.template > /etc/nginx/conf.d/docs.conf
  envsubst '$AUTH_DOMAIN' < /templates/auth.ssl.conf.template > /etc/nginx/conf.d/auth.conf
  envsubst '$FLOW_DOMAIN' < /templates/flow.ssl.conf.template > /etc/nginx/conf.d/flow.conf
else
  envsubst '$DOCS_DOMAIN $AUTH_DOMAIN $FLOW_DOMAIN' < /templates/nginx.conf.plain.template > /etc/nginx/nginx.conf
  envsubst '$DOCS_DOMAIN' < /templates/docs.plain.conf.template > /etc/nginx/conf.d/docs.conf
  envsubst '$AUTH_DOMAIN' < /templates/auth.plain.conf.template > /etc/nginx/conf.d/auth.conf
  envsubst '$FLOW_DOMAIN' < /templates/flow.plain.conf.template > /etc/nginx/conf.d/flow.conf
fi

exec "$@"


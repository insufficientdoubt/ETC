Self-Hosted Knowledge Base & Automation Stack

Overview
- Outline at `https://${DOCS_DOMAIN}` (OIDC via Keycloak)
- Keycloak at `https://${AUTH_DOMAIN}`
- n8n at `https://${FLOW_DOMAIN}` (DB = Postgres)
- Postgres, Redis, Nginx (TLS via Let’s Encrypt/Certbot), optional MinIO for dev

Quick Start (Prod)
1) Copy env template and set secrets
   cp .env.example .env
   ./scripts/gen-secrets.sh  # copy values into .env
   - Set DOCS/AUTH/FLOW domains
   - Set POSTGRES_SUPERPASS, OUTLINE_DB_PASSWORD, KEYCLOAK_DB_PASSWORD, N8N_DB_PASSWORD
   - Set AWS_* for COS (prod) or MinIO (dev)
   - Set OIDC_CLIENT_SECRET (will also be configured in Keycloak)

2) DNS + firewall
   - Point A/AAAA records for DOCS_DOMAIN, AUTH_DOMAIN, FLOW_DOMAIN to this host
   - Ensure ports 80 and 443 are open

3) Bring up base stack (will start Nginx without certs yet)
   docker compose up -d postgres redis keycloak outline n8n nginx

4) Obtain certificates (HTTP-01 via webroot)
   For each domain:
   docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d $DOCS_DOMAIN --email you@example.com --agree-tos --no-eff-email
   docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d $AUTH_DOMAIN --email you@example.com --agree-tos --no-eff-email
   docker compose run --rm certbot certonly --webroot -w /var/www/certbot -d $FLOW_DOMAIN --email you@example.com --agree-tos --no-eff-email
   Then reload Nginx:
   docker compose exec nginx nginx -s reload

5) Keycloak bootstrap
   - Access https://${AUTH_DOMAIN}
   - Log in with KEYCLOAK_ADMIN / KEYCLOAK_ADMIN_PASSWORD
   - Confirm realm "school" imported with client "outline"
   - Configure WeCom IdP (OIDC) endpoints and client credentials (placeholders are in realm file)
   - Ensure client redirect URI: https://${DOCS_DOMAIN}/auth/oidc.callback
   - Add users/groups (Staff, staff-tech, staff-hr, admin)

6) Outline OIDC
   - In Outline env (.env), ensure OIDC_* match Keycloak realm + client
   - Visit https://${DOCS_DOMAIN} and sign in via OIDC

7) n8n
   - Access https://${FLOW_DOMAIN}
   - Basic auth defaults from .env; change immediately
   - Set OUTLINE_API_TOKEN in .env (from Outline) and restart n8n to import the sample workflow

Object Storage
- Tencent COS (prod): set AWS_REGION, AWS_S3_UPLOAD_BUCKET_URL, AWS_S3_UPLOAD_BUCKET_NAME, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY.
- MinIO (dev): use endpoint http://minio:9000 and create a bucket; set credentials accordingly.

Email (optional)
- Set SMTP_* in .env and restart `outline` service to enable email features.

Notes
- Redis is ephemeral; Postgres/n8n/MinIO have persistent volumes.
- Certbot container auto-renews certificates; initial issuance is manual as shown above.
- Keycloak uses Postgres for persistence.

Local Testing (HTTP-only + MinIO)
- Goal: demo login via Keycloak with optional WeCom button, and a fallback username/password form.

1) Configure hosts (on your laptop/dev box)
   Add to /etc/hosts:
     127.0.0.1  docs.localhost auth.localhost flow.localhost

2) Copy env and set local values
   cp .env.example .env
   - Set DOCS_DOMAIN=docs.localhost, AUTH_DOMAIN=auth.localhost, FLOW_DOMAIN=flow.localhost
   - Set PUBLIC_URL_SCHEME=http and ENABLE_TLS=false
   - Set POSTGRES_SUPERPASS, OUTLINE_DB_PASSWORD, KEYCLOAK_DB_PASSWORD, N8N_DB_PASSWORD
   - For storage, dev uses MinIO automatically via docker-compose.dev.yml

3) Start dev stack (HTTP only)
   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

4) Create a Keycloak test user (fallback login)
   - Open http://auth.localhost
   - Log into admin console with KEYCLOAK_ADMIN/KEYCLOAK_ADMIN_PASSWORD (master realm)
   - Switch to realm "school" → Users → Add user (e.g., demo)
   - Set password (Credentials tab), toggle Temporary = OFF
   - Optionally assign groups (Staff, staff-tech, staff-hr, admin)

5) Configure WeCom IdP (optional now; add button on login screen)
   - In realm "school": Identity Providers → Add OpenID Connect v1 → set WeCom endpoints/keys
   - The login page will show both: WeCom button and the username/password form

6) Outline OIDC
   - Visit http://docs.localhost and click "Sign in with Keycloak"
   - Use your Keycloak test user to complete login

7) n8n local
   - Open http://flow.localhost
   - Default basic auth from .env (change immediately)
   - Set OUTLINE_API_TOKEN after creating it in Outline and restart n8n

Switch back to Prod mode
- Set PUBLIC_URL_SCHEME=https and ENABLE_TLS=true
- Use real domains (docs.school.edu, auth.school.edu, flow.school.edu)
- Issue TLS certs with certbot commands from the Prod section and reload Nginx

#!/usr/bin/env bash
set -e

BENCH=/home/frappe/frappe-bench
DB_HOST="${DB_HOST:-mariadb}"
REDIS_URL="${REDIS_URL:-redis://redis:6379}"
DB_PASSWORD="${MYSQL_ROOT_PASSWORD}"

if [ -z "$DB_PASSWORD" ]; then
  echo 'MYSQL_ROOT_PASSWORD is required'
  exit 1
fi

if [ ! -d "$BENCH/apps/frappe" ]; then
  bench init --skip-redis-config-generation --frappe-branch develop "$BENCH"

  cd "$BENCH"
  bench set-mariadb-host "$DB_HOST"
  bench set-redis-cache-host "$REDIS_URL"
  bench set-redis-queue-host "$REDIS_URL"
  bench set-redis-socketio-host "$REDIS_URL"

  bench get-app --branch develop crm https://github.com/burduk-dev/crm

  bench new-site crm.localhost \
    --force \
    --mariadb-root-password "$DB_PASSWORD" \
    --admin-password "$ADMIN_PASSWORD" \
    --db-host "$DB_HOST" \
    --no-mariadb-socket

  bench --site crm.localhost install-app crm
  bench --site crm.localhost set-config developer_mode 0
  bench --site crm.localhost set-config mute_emails 1
  bench --site crm.localhost set-config server_script_enabled 1
  bench set-config -g serve_default_site crm.localhost
  bench use crm.localhost
  bench --site crm.localhost clear-cache
fi

cd "$BENCH"
exec bench start

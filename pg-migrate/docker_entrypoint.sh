#!/bin/sh

set -ea

DB_HOST=localhost
DB_USER=postgres
DB_NAME=postgres
DB_PORT=5432

chmod 777 /root
chmod 777 /root/persistence
mkdir -p /root/persistence/pgdata
chown -R postgres:postgres /root/persistence/pgdata
test -f /root/persistence/pgdata/PG_VERSION || exit 1
sudo -u postgres postgres -D /root/persistence/pgdata &

until sudo -u postgres pg_dump > /root/persistence/db_dump.sql
do
  echo 'postgres not ready, retrying in 1 second...'
  sleep 1
done

if [ -s /root/persistence/db_dump.sql ]; then
  rm -rf /root/persistence/pgdata
fi

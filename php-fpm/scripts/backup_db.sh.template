#!/bin/bash

set -e
set -o pipefail

MARIADB_HOST="mariadb1"
REPLICA="3"

if [ "`host "$MARIADB_HOST" | wc -l`" != $REPLICA ]; then
    echo "Not all galera nodes ready; not backing up DB."
    exit 1
fi

keep=10

datadir=/srv/data
backupdir="$datadir/.db_backup"
lockfile="$backupdir/.lock"


if [ -z "$1" ]; then
    backup_file="backup-`date +%d-%m-%+4Y_%H:%M`.sql.gz"
else
    backup_file="$1"
fi

mkdir -p "$backupdir"
cd "$backupdir"

if [ -e "$lockfile" ]; then
    echo "Backup lock file exists; not backup up"
    exit 1
fi

trap "rm -f $lockfile" exit
touch "$lockfile"
sleep 2

echo "Backing up database from mariadb primary..."
if ! mysqldump \
    -h "$MARIADB_HOST" \
    -P "3306" \
    -u "$MARIADB_USER" \
    --password="$MARIADB_PASSWORD" \
    "$MARIADB_DATABASE" | gzip -3 > "$backup_file"; then
  rm -f $backup_file
  echo "error: mysqldump failed"
  exit 1
fi

echo "Pruning old backups"
ls -tr | head -n -$keep | xargs rm -f


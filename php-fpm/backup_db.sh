#!/bin/bash

set -e
set -o pipefail

if [ "`host {{.Release.Name}}-mariadb-galera-headless | wc -l`" != "{{ index .Values "mariadb-galera" "replicaCount" }}" ]; then
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
if ! mysqldump -h {{ .Release.Name }}-mariadb-galera-0.{{ .Release.Name }}-mariadb-galera-headless -u {{ index .Values "mariadb-galera" "db" "user" }} --password="$DBPASS" {{ index .Values "mariadb-galera" "db" "name" }} | gzip -3 > $backup_file ; then
    rm -f $backup_file
    echo "Backup failed!"
    exit 1
fi
echo "Pruning old backups"
ls -tr | head -n -$keep | xargs rm -f


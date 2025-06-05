#!/bin/bash

set -e

if [ "`host {{.Release.Name}}-mariadb-galera-headless | wc -l`" != "{{ index .Values "mariadb-galera" "replicaCount" }}" ]; then
  echo "Not all galera nodes ready; not restoring DB."
  exit 1
fi

datadir=/srv/data
backupdir="$datadir/.db_backup"
lockfile="$backupdir/.lock"

cd "$backupdir"

if [ -z "$1" ]; then
  backup_file="`ls -t | head -n 1`"
else
  backup_file="$1"
fi

if [ -e "$lockfile" ]; then
  echo "Backup lock file exists; not restoring"
  exit 1
fi

trap "rm -f $lockfile" exit
touch "$lockfile"
sleep 2

echo "Restoring $backup_file to mariadb primary..."
mysql -e'drop database {{ index .Values "mariadb-galera" "db" "name" }}' -h {{ .Release.Name }}-mariadb-galera-0.{{ .Release.Name }}-mariadb-galera-headless -u {{ index .Values "mariadb-galera" "db" "user" }} --password="$DBPASS" {{ index .Values "mariadb-galera" "db" "name" }}
sleep 5
mysql -e'create database {{ index .Values "mariadb-galera" "db" "name" }}' -h {{ .Release.Name }}-mariadb-galera-0.{{ .Release.Name }}-mariadb-galera-headless -u {{ index .Values "mariadb-galera" "db" "user" }} --password="$DBPASS" 
zcat "$backup_file" | mysql -h {{ .Release.Name }}-mariadb-galera-0.{{ .Release.Name }}-mariadb-galera-headless -u {{ index .Values "mariadb-galera" "db" "user" }} --password="$DBPASS" {{ index .Values "mariadb-galera" "db" "name" }}

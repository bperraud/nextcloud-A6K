#!/bin/sh
set -eu
# https://github.com/nextcloud/docker/issues/1740#issuecomment-1308141561
adduser --uid "$UID" --gecos "" --disabled-password --shell /usr/sbin/nologin --no-create-home --home /var/www cron && mv /var/spool/cron/crontabs/www-data /var/spool/cron/crontabs/cron
exec busybox crond -f -L /dev/stdout

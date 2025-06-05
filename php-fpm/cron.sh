#!/bin/bash

set -e

datadir=/srv/data
wwwdir=/var/www/html

cd $wwwdir

if [ ! -e "$datadir/.installed" ]; then
  echo "error: nextcloud not installed"
  exit 1
fi

if ! wget --timeout=5 --quiet -O/tmp/status.json --no-check-certificate https://nextcloud:8443/status.php; then
  echo "error: can't get nextcloud status.php"
  exit 1
fi

if [ "`jq .needsDbUpgrade < /tmp/status.json`" != "false" ]; then
  echo "error: nextcloud needs DB upgrade"
  exit 1
fi

echo "Running nextcloud cron.php..."
php /var/www/html/cron.php

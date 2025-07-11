#!/bin/bash

# set -e
# set -o pipefail

datadir=/srv/data
backupdir="$datadir/.db_backup"
wwwdir=/var/www/html

cd $wwwdir

# galera needs to be stable during nextcloud installation, or it may fail and leave itself broken
# if [ "`host {{.Release.Name}}-mariadb-galera-headless | wc -l`" != "{{ index .Values "mariadb-galera" "replicaCount" }}" ]; then
#     echo "Not all galera nodes ready; not installing or upgrading."
#     exit 1
# fi
#
# GALERA_NODES_ARRAY=("mariadb1" "mariadb2" "mariadb3")

GALERA_NODES_ARRAY=("mariadb1")
EXPECTED_COUNT=${#GALERA_NODES_ARRAY[@]}
RESOLVED_COUNT=0

for NODE in "${GALERA_NODES_ARRAY[@]}"; do
  if getent hosts "$NODE" > /dev/null; then
    ((RESOLVED_COUNT++))
  fi
done

if [ "$RESOLVED_COUNT" -ne "$EXPECTED_COUNT" ]; then
  echo "Not all galera nodes ready; not installing or upgrading."
  exit 1
fi

echo "all galera nodes ready;"

if [ ! -L config/config.php ]; then

    echo "Can't find config.php. It should be a symlink to a non-existing file in the data directory."
    exit 1

elif [ -e "$datadir/.installed" ]; then

    if [ -n "`./occ status 2>&1 | grep 'upgrade'`" ]; then
        if [ -e "$backupdir/.pre_upgrade.sql.gz" ]; then
            echo "Pre-upgrade DB backup exists; upgrade must have failed; not retrying."
            echo "Verify that DB restore was successful in /srv/data/nextcloud_upgrade.log, then fix the issues."
            echo "If restore WAS NOT successful, scale down nextcloud to 0, then restore manually."
            echo "If restore WAS successful, the previous version will eventually start itself again."
            exit 1
        fi
        echo '<?php $CONFIG = [ "config_is_read_only" => false ] ;' > config/zupgrade.config.php    
        /srv/scripts/backup_db.sh .pre_upgrade.sql.gz
        if ! ./occ upgrade -vvv 2>&1 | tee "$datadir/nextcloud_upgrade.log" ; then
            echo "Upgrade failed; attempting to restore database" | tee -a "$datadir/nextcloud_upgrade.log"
            /scripts/restore_db.sh .pre_upgrade.sql.gz
            echo "Restore succeeded" | tee -a "$datadir/nextcloud_upgrade.log"
            exit 1
        fi
        mv -f "$backupdir/.pre_upgrade.sql.gz" "$backupdir/.pre_upgrade.success.sql.gz"
    fi

else # not installed

echo '<?php $CONFIG = [ "config_is_read_only" => false ] ;' > config/zupgrade.config.php
cat > config/config.php <<"EOF"
<?php

$CONFIG = [
'installed' => false,
'appstoreenabled' => false,
'upgrade.disable-web' => true,
'maintenance' => false,
'config_is_read_only' => true,
];

?>
EOF
mkdir -p $datadir/_nctmp
./occ maintenance:install --data-dir "$datadir" --database mysql --database-name  "$MARIADB_DATABASE" --database-user "$MARIADB_USER" --database-pass "$MARIADB_PASSWORD" --database-host proxysql --database-port 6033 --admin-user $NCADMINUSER --admin-pass $NCADMINPASS
touch "$datadir/.installed"

fi


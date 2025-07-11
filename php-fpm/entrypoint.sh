#!/bin/bash
set -e

# Start php-fpm in the background
/usr/sbin/php-fpm8.2 -c /etc/php/cur/fpm/php-fpm.conf &

# Optional: wait for it to start up
sleep 5  # Or add health probe here

# Run setup script
echo "[INFO] Running setup script..."
/srv/scripts/setup.sh

# # Run post-install script
echo "[INFO] Running post script..."
/srv/scripts/post_install.sh

# Run cron job manually
echo "[INFO] Running cronjob..."
php /var/www/html/cron.php

# Wait for php-fpm to keep container alive
wait %1


#!/bin/bash
set -e

# Start php-fpm in the background
/usr/bin/php-fpm -c /etc/php/cur/fpm/php-fpm.conf &
# CMD ["/usr/bin/php-fpm", "-c", "/etc/php/cur/fpm/php-fpm.conf"]

# Optional: wait for it to start up
sleep 5  # Or add health probe here

# Run setup script
# echo "[INFO] Running setup script..."
# ./var/www/html/scripts/setup.sh

# # Run post-install script
# echo "[INFO] Running post script..."
# ./var/www/html/scripts/post_install.sh

# Run cron job manually
echo "[INFO] Running cronjob..."
php /var/www/html/cron.php

# Wait for php-fpm to keep container alive
wait %1


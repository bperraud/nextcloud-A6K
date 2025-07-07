FROM debian:bullseye-slim

ARG nc_url="https://download.nextcloud.com/.customers/server/31.0.4-a59bd0a7/nextcloud-31.0.4-enterprise.zip"
ARG push_bin_url="https://github.com/nextcloud/notify_push/releases/download/v1.1.0/notify_push-x86_64-unknown-linux-musl"
ARG push_app_url="https://github.com/nextcloud-releases/notify_push/releases/download/v1.1.0/notify_push-v1.0.0.tar.gz"
ARG apps="" 
ARG debug_build=0

USER root

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install --no-install-recommends gnupg wget ca-certificates && \
    wget -O- https://packages.sury.org/php/apt.gpg | apt-key add - && \
    echo "deb https://packages.sury.org/php/ bullseye main" > /etc/apt/sources.list.d/sury-php.list

# Install dependencies
RUN apt-get -y update && \
    apt-get -y install --no-install-recommends \
    libfuse2 fontconfig procps dnsutils wget mariadb-client jq unzip \
    php8.2-sqlite3 php8.2-fpm php8.2-redis php8.2-apcu php8.2-opcache \
    php8.2-mysql php8.2-zip php8.2-dom php8.2-xml php8.2-intl php8.2-mbstring \
    php8.2-gd php8.2-curl php8.2-ldap php8.2-bcmath php8.2-gmp php8.2-imagick \
    libmagickcore-6.q16-6-extra && \
    ([ $debug_build = 1 ] && apt-get -y install --no-install-recommends php8.2-xdebug) || true && \
    apt-get clean && rm -rf /var/lib/apt/lists/*


# Download and install Nextcloud
ADD $nc_url /tmp/nc.zip 
RUN unzip /tmp/nc.zip -d /var/www && \
    mv /var/www/nextcloud /var/www/html && \
    mkdir -p /var/www/html/custom_apps && \
    rm -f /tmp/nc.zip

# Install notify_push binary
ADD $push_bin_url /usr/local/bin/notify_push
RUN chmod +x /usr/local/bin/notify_push

# Download and install custom apps
# RUN for app in $apps; do \
#     echo installing $app ; \
#     wget --quiet -O- "$app" | tar xz -C /var/www/html/custom_apps ; \
# done

RUN wget --quiet -O- $push_app_url | tar xz -C /var/www/html/apps

# Permissions
RUN chown -R www-data:root /var/www/html && \
    chmod -R u=rX,g=rX,o= /var/www/html && \
    ([ "$debug_build" = "1" ] && chmod -R g+w /var/www/html) || true && \
    chmod u+w,g+w /var/www/html/config && \
    chmod +x /var/www/html/occ

# Persistent data volume
RUN mkdir -p /srv/data && \
    chown -R www-data:root /srv/data && \
    chmod u=rwx,g=rwx,o= /srv/data


# Setup PHP symlinks and config
RUN ln -sf /etc/php/* /etc/php/cur && rm -f /etc/php/cur/fpm/pool.d/*

COPY files/php-fpm.conf /etc/php/cur/fpm/pool.d/00-base.conf
COPY files/90-apcu.ini /etc/php/cur/fpm/conf.d/90-apcu.ini
COPY files/90-apcu.ini /etc/php/cur/cli/conf.d/90-apcu.ini
COPY files/99-xdebug.ini /99-xdebug.ini
RUN ([ $debug_build = 1 ] && mv /99-xdebug.ini /etc/php/cur/fpm/conf.d/99-xdebug.ini) || true
RUN ([ $debug_build = 0 ] && rm -f /99-xdebug.ini) || true

RUN ln -s /srv/data/.config-base.php /var/www/html/config/config.php

# Custom CA
COPY files/ca.crt /usr/local/share/ca-certificates/nc-ca.crt
RUN update-ca-certificates --fresh

# USER default

USER www-data

CMD /usr/sbin/php-fpm* -c /etc/php/cur/fpm/php-fpm.conf

# CMD ["tail", "-f", "/dev/null"]

FROM httpd:2.4-bullseye

ARG nc_url="https://download.nextcloud.com/.customers/server/31.0.4-a59bd0a7/nextcloud-31.0.4-enterprise.zip"

ARG apps=""

USER root

RUN apt-get -y update 
RUN apt-get -y upgrade
RUN apt-get -y install procps unzip bzip2 wget

COPY files/httpd.conf /usr/local/apache2/conf/httpd.conf
RUN chmod a+w /usr/local/apache2/logs

ADD $nc_url /tmp/nc.zip
RUN unzip /tmp/nc.zip -d /var/www
RUN mv /var/www/nextcloud /var/www/html
RUN mkdir -p /var/www/html/custom_apps
RUN rm -f /tmp/nc.zip

RUN for app in $apps; do \
    echo installing $app ; \
    wget --quiet -O- "$app" | tar xz -C /var/www/html/custom_apps ; \
done

RUN chown -R www-data:root /var/www/html
RUN chmod -R u=rX,g=rX,o= /var/www/html

# USER default
# USER www-data

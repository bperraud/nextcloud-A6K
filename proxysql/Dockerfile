FROM proxysql/proxysql:3.0.1

# Add envsubst (from gettext)
RUN apt-get update && apt-get install -y gettext && apt-get clean

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

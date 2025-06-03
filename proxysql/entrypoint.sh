#!/bin/bash
set -e

envsubst < /etc/proxysql.cnf.template > /var/lib/proxysql/proxysql.cnf

exec proxysql --initial -f -c /var/lib/proxysql/proxysql.cnf


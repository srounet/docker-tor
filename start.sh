#!/bin/sh

# launch 10 tors
/usr/local/bin/tor --SocksPort 9051 --PidFile /var/run/tor/1.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/1
/usr/local/bin/tor --SocksPort 9052 --PidFile /var/run/tor/2.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/2
/usr/local/bin/tor --SocksPort 9053 --PidFile /var/run/tor/3.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/3
/usr/local/bin/tor --SocksPort 9054 --PidFile /var/run/tor/4.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/4
/usr/local/bin/tor --SocksPort 9055 --PidFile /var/run/tor/5.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/5
/usr/local/bin/tor --SocksPort 9056 --PidFile /var/run/tor/6.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/6
/usr/local/bin/tor --SocksPort 9057 --PidFile /var/run/tor/7.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/7
/usr/local/bin/tor --SocksPort 9058 --PidFile /var/run/tor/8.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/8
/usr/local/bin/tor --SocksPort 9059 --PidFile /var/run/tor/9.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/9
/usr/local/bin/tor --SocksPort 9060 --PidFile /var/run/tor/10.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/10

# launch 10 delegated
DELEGATE_VERSION=9.9.7
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9151 SERVER=http SOCKS=localhost:9051 PIDFILE=/var/run/delegated/1.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9152 SERVER=http SOCKS=localhost:9052 PIDFILE=/var/run/delegated/2.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9153 SERVER=http SOCKS=localhost:9053 PIDFILE=/var/run/delegated/3.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9154 SERVER=http SOCKS=localhost:9054 PIDFILE=/var/run/delegated/4.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9155 SERVER=http SOCKS=localhost:9055 PIDFILE=/var/run/delegated/5.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9156 SERVER=http SOCKS=localhost:9056 PIDFILE=/var/run/delegated/6.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9157 SERVER=http SOCKS=localhost:9057 PIDFILE=/var/run/delegated/7.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9158 SERVER=http SOCKS=localhost:9058 PIDFILE=/var/run/delegated/8.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9159 SERVER=http SOCKS=localhost:9059 PIDFILE=/var/run/delegated/9.pid OWNER=root/root
/tmp/delegate${DELEGATE_VERSION}/src/delegated -P9160 SERVER=http SOCKS=localhost:9060 PIDFILE=/var/run/delegated/10.pid OWNER=root/root

# launch haproxy
haproxy -f /etc/default/haproxy.conf -q -db

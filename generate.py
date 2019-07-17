count = 100
tor_port_start = 7050
delegateport_start = 8050

delegate_version = '9.9.13'

start_sh_body = '''
#!/bin/sh

rm /etc/resolv.conf
echo "nameserver 127.0.0.1" > /etc/resolv.conf
resolvconf -u
ifdown -a
ifup -a

# launch 10 tors
%s

# launch 10 delegated
DELEGATE_VERSION=9.9.13
%s

# launch haproxy
haproxy -f /etc/default/haproxy.conf -q -db'''

tor_command = '/usr/local/bin/tor --SocksPort %d --PidFile /var/run/tor/%d.pid --RunAsDaemon 1 --DataDirectory /var/db/tor/%d'
delegate_command = '/tmp/delegate%s/src/delegated -P%d SERVER=http SOCKS=localhost:%d PIDFILE=/var/run/delegated/%d.pid OWNER=root/root'

tor_commands = []
delegate_commands = []

haproxy_conf_body = '''
global
  daemon
  user root
  group root
 
defaults
    mode http
    maxconn 50000
    timeout client 3600s
    timeout connect 1s
    timeout queue 5s
    timeout server 3600s

listen stats
  bind 0.0.0.0:2090
  mode http
  stats enable
  stats uri /
 
listen TOR-in
  bind 0.0.0.0:9100
  default_backend TOR
  balance roundrobin
 
listen Socks-in
  mode tcp
  bind 0.0.0.0:9101
  default_backend Socks 
  balance roundrobin

backend TOR
%s

backend Socks 
%s
'''

backend_tor_command = '  server 127.0.0.1:%d 127.0.0.1:%d check'
backend_socks_command = '  server 127.0.0.1:%d 127.0.0.1:%d check'

backend_tors = []
backend_socks = []

Dockerfile_body = '''
# use the ubuntu latest image
FROM ubuntu:16.04

# Update and upgrade system
RUN apt-get -qq update && apt-get -qq --yes upgrade

# install sys utils
RUN apt-get -qq install --yes build-essential libevent-dev libssl-dev curl g++

RUN mkdir /usr/local/etc/tor
RUN echo 'MaxCircuitDirtiness 1' >> /usr/local/etc/tor/torrc

# install tor
ENV TOR_VERSION 0.2.9.13
RUN curl -0 -L https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz | tar xz -C /tmp
RUN cd /tmp/tor-${TOR_VERSION} && ./configure
RUN cd /tmp/tor-${TOR_VERSION} && make -j 4
RUN cd /tmp/tor-${TOR_VERSION} && make install

# install delegate
ENV DELEGATE_VERSION 9.9.13
RUN curl ftp://anonymous@ftp.delegate.org/pub/DeleGate/delegate${DELEGATE_VERSION}.tar.gz | tar xz -C /tmp
RUN echo "ADMIN=root@root.com" > /tmp/delegate${DELEGATE_VERSION}/src/DELEGATE_CONF
RUN sed -i -e '1i#include <util.h>\\' /tmp/delegate${DELEGATE_VERSION}/maker/_-forkpty.c
RUN cd /tmp/delegate${DELEGATE_VERSION} && make

# install haproxy
ENV HAPROXY_VERSION 1.6.8
RUN curl -0 -L http://haproxy.1wt.eu/download/1.6/src/haproxy-${HAPROXY_VERSION}.tar.gz | tar xz -C /tmp
RUN cd /tmp/haproxy-${HAPROXY_VERSION}/ && make TARGET=linux2628 USE_OPENSSL=1 USE_ZLIB=1
RUN cd /tmp/haproxy-${HAPROXY_VERSION}/ && make install
ADD ./haproxy.conf /etc/default/haproxy.conf

# prepare tor folders
RUN mkdir -p %s
RUN chmod -R 700 /var/db/tor
ADD start.sh /
RUN chmod +x /start.sh

EXPOSE 9100 9101 2090 53

CMD ["./start.sh"]
'''

pid_dir = '/var/db/tor/%d'
pid_dirs = []

for i in range(1, count + 1):
    tor_commands.append( tor_command % (tor_port_start + i, i, i) )
    delegate_commands.append( delegate_command % (delegate_version, delegateport_start + i, tor_port_start + i, i) )

    backend_tors.append( backend_tor_command % (delegateport_start + i, delegateport_start + i) )
    backend_socks.append( backend_socks_command % (tor_port_start + i, tor_port_start + i) )
    pid_dirs.append( pid_dir % i )

with open('start.sh', 'w') as fh:
  fh.write(start_sh_body % ('\n'.join(tor_commands), '\n'.join(delegate_commands)) )

with open('haproxy.conf', 'w') as fh:
  fh.write(haproxy_conf_body % ('\n'.join(backend_tors), '\n'.join(backend_socks)))    

with open('Dockerfile', 'w') as fh:           
  fh.write(Dockerfile_body % ' '.join(pid_dirs))


# use the ubuntu latest image
FROM ubuntu:16.04

# Update and upgrade system
RUN apt-get -qq update && apt-get -qq --yes upgrade

# install sys utils
RUN apt-get -qq install --yes build-essential libevent-dev libssl-dev curl g++

# install tor
ENV TOR_VERSION 0.2.8.7
RUN curl -0 -L https://www.torproject.org/dist/tor-${TOR_VERSION}.tar.gz | tar xz -C /tmp
RUN cd /tmp/tor-${TOR_VERSION} && ./configure
RUN cd /tmp/tor-${TOR_VERSION} && make -j 4
RUN cd /tmp/tor-${TOR_VERSION} && make install

# install delegate
ENV DELEGATE_VERSION 9.9.13
RUN curl ftp://anonymous@ftp.delegate.org/pub/DeleGate/delegate${DELEGATE_VERSION}.tar.gz | tar xz -C /tmp
RUN echo "ADMIN=root@root.com" > /tmp/delegate${DELEGATE_VERSION}/src/DELEGATE_CONF
RUN sed -i -e '1i#include <util.h>\' /tmp/delegate${DELEGATE_VERSION}/maker/_-forkpty.c
RUN cd /tmp/delegate${DELEGATE_VERSION} && make

# install haproxy
ENV HAPROXY_VERSION 1.6.8
RUN curl -0 -L http://haproxy.1wt.eu/download/1.6/src/haproxy-${HAPROXY_VERSION}.tar.gz | tar xz -C /tmp
RUN cd /tmp/haproxy-${HAPROXY_VERSION}/ && make TARGET=linux2628 USE_OPENSSL=1 USE_ZLIB=1
RUN cd /tmp/haproxy-${HAPROXY_VERSION}/ && make install
ADD ./haproxy.conf /etc/default/haproxy.conf

# prepare tor folders
RUN mkdir -p /var/db/tor/1 /var/db/tor/2 /var/db/tor/3 /var/db/tor/4 /var/db/tor/5 /var/db/tor/6 /var/db/tor/7 /var/db/tor/8 /var/db/tor/9 /var/db/tor/10
RUN chmod -R 700 /var/db/tor
ADD start.sh /
RUN chmod +x /start.sh

EXPOSE 9100 9101 2090 53

CMD ["./start.sh"]

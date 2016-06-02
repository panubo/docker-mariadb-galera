FROM mariadb:10.1

RUN apt-get update && apt-get install -y percona-xtrabackup socat rsync netcat galera-arbitrator-3 && \
    rm -rf /var/lib/apt/lists/* && \
    cp /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-original.sh

COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 3306 4444 4567 4567/udp 4568

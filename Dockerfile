FROM mariadb:10.1

RUN apt-get update && apt-get install -y galera-arbitrator-3 && \
    rm -rf /var/lib/apt/lists/* && \
    # Backup the original entrypoint
    cp /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-entrypoint-original.sh

COPY docker-entrypoint.sh /usr/local/bin/

EXPOSE 3306 4444 4567 4567/udp 4568

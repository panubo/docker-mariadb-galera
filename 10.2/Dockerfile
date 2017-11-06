FROM mariadb:10.2

RUN apt-get update && apt-get install -y galera-arbitrator-3 && \
    rm -rf /var/lib/apt/lists/*

COPY galera-entrypoint.sh /

EXPOSE 3306 4444 4567 4567/udp 4568

ENTRYPOINT ["/galera-entrypoint.sh"]
CMD ["mysqld"]

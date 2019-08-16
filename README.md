# Deprecation Notice!

NB: This project is no longer maintained and the repository is archived.

---

# Docker Image for MariaDB Galera Cluster

We hope that this image will not be required in the future pending the integration of better Galera support in the official image.
eg [PR 24](https://github.com/docker-library/mariadb/pull/24/files).

This image uses entrypoint modifications similar to the ones by [Kristian Klausen](https://github.com/klausenbusk/mariadb/blob/78df6f06732897bee0a69ee6332884f9cb1f5fbd/10.1/docker-entrypoint.sh) to provide (better) Galera support for the offcial `mariadb:10.1` image.

Also included is [Galera Arbitrator](http://galeracluster.com/documentation-webpages/arbitrator.html) (aka `garbd`) which allows you to maintain quorum with a two node cluster. (Not required when running 3 or more nodes).

## Usage

### Environment Arguments

- `WSREP_NODE_ADDRESS` - IP or domain of host interface eg `WSREP_NODE_ADDRESS=10.0.0.1`
- `WSREP_CLUSTER_ADDRESS` - List of cluster nodes and ports eg `WSREP_CLUSTER_ADDRESS=gcomm://10.0.0.1:4567,10.0.0.2:4567,10.0.0.3:4567`
- `WSREP_CLUSTER_NAME` - Default `my_wsrep_cluster`
- `WSREP_NODE_NAME` - Defaults to the container hostname. You'll want to set this
to something that doesn't change.

### Running Garbd

Garbd is available. Just specify `garbd` as the command.

```
docker run -d --net host --name galera-garbd \
  -e WSREP_CLUSTER_ADDRESS=$WSREP_CLUSTER_ADDRESS \
  panubo/mariadb-galera \
    garbd
```

### Bootstrapping the cluster

Node 1:

```
docker run -d --net host --name galera \
  -e WSREP_NODE_ADDRESS=$WSREP_NODE_ADDRESS \
  -e WSREP_CLUSTER_ADDRESS=$WSREP_CLUSTER_ADDRESS \
  -e MYSQL_ROOT_PASSWORD={{ mysql_root_password }} \
  -p 3306:3306 \
  -p 4567:4567/udp \
  -p 4567-4568:4567-4568 \
  -p 4444:4444 \
  -v /mnt/data/galera.service/mysql:/var/lib/mysql:Z \
  panubo/mariadb-galera \
    mysqld \
    --wsrep-new-cluster
```

Node 2-N:

Create empty mysql dir to [skip database initialisation](https://github.com/docker-library/mariadb/pull/57). (Kludge!)

```
mkdir -p /mnt/data/galera.service/mysql/mysql
```

Start the container normally (without `--wsrep-new-cluster`).

```
docker run -d --net host --name galera \
  -e WSREP_NODE_ADDRESS=$WSREP_NODE_ADDRESS \
  -e WSREP_CLUSTER_ADDRESS=$WSREP_CLUSTER_ADDRESS \
  -p 3306:3306 \
  -p 4567:4567/udp \
  -p 4567-4568:4567-4568 \
  -p 4444:4444 \
  -v /mnt/data/galera.service/mysql:/var/lib/mysql:Z \
  panubo/mariadb-galera \
    mysqld
```

## Recovery

Recovery when quorum is lost is fairly simple:

First, stop on all nodes. Eg (if using a Systemd unit to run Galera):

```
systemctl stop galera.service
```

Secondly, start node with most complete / recent data set with `--wsrep-new-cluster` argument. EG:

```
docker run -d --net host --name galera-init \
  -e WSREP_NODE_ADDRESS=$WSREP_NODE_ADDRESS \
  -e WSREP_CLUSTER_ADDRESS=$WSREP_CLUSTER_ADDRESS \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -p 3307:3306 \
  -p 4567:4567/udp \
  -p 4567-4568:4567-4568 \
  -p 4444:4444 \
  -v /mnt/data/galera.service/mysql:/var/lib/mysql:Z \
  panubo/mariadb-galera \
    mysqld \
    --wsrep-new-cluster
```

Finally, bring up other nodes normally. Eg. (Systemd example)

```
systemctl start galera.service
```

# Gotchas

1. Whilst it isn't strictly necessary to use the host network (`--net host`), there seems to be an issue (bug?) whereby Galera gets both the host and the (duplicated) Docker network IP assigned to the node. This causes issues when multiple nodes fail and attempt to rejoin the cluster.

2. Garbd requires an explicit port if it blows up with `"Exception in creating receive loop."` See [issue 312](https://github.com/codership/galera/issues/312).

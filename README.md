# Docker Container for MariaDB Galera Cluster

We hope that this container will not be required in the future pending the integration of
this [pull request](https://github.com/docker-library/mariadb/pull/24/files).

This container uses the entrypoint modifications by [Kristian Klausen](https://github.com/klausenbusk/mariadb/blob/78df6f06732897bee0a69ee6332884f9cb1f5fbd/10.1/docker-entrypoint.sh) to provide (better) Galera support for the offcial `mariadb:10.1` container.

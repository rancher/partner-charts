# MySQL Galera from Codership

This is a Helm chart for MySQL Galera from Codership.

Galera Cluster for MySQL is a true Multi-Master Cluster based on synchronous replication. It’s an easy-to-use, high-availability solution, which provides high system up-time, no data loss and scalability for future growth.

For documentation, Knowledge Base and Support please visit https://galeracluster.com/

* Galera Cluster for MySQL Helm Chart: https://galeracluster.com/2024/10/galera-cluster-for-mysql-helm-chart-for-kubernetes/
* MySQL Galera Cluster documentation: https://galeracluster.com/library/documentation/index.html

## Installation
* Plan your cluster capacity. Default is 3 nodes, each with 1 vCPU and 4GB of RAM, the storage is 2GB. It is minimal requirement for Galera to work.
* Consider separate namespace for the MySQL Galera cluster, like `mysql-galera`.
* Install the MySQL Galera chart with desired capacity.

## Configuration
Sometimes you may want to configure the MySQL Galera cluster with custom values. You can do this by setting the customConfig multiline in values.yaml.

See the values.yaml file for the full list of configurable parameters.

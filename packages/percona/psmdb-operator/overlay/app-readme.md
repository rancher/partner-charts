# Percona Operator for MongoDB

The Percona Operator for MongoDB automates the deployment and management of
Percona Server for MongoDB replica sets and sharded clusters on Kubernetes,
including scaling, upgrades, backups and point-in-time recovery to S3, GCS or
Azure Blob Storage. Use the Percona Distribution for MongoDB chart to create a
cluster once the operator is running.

This chart installs the operator and its Custom Resource Definitions (CRDs).
Helm does not upgrade CRDs on chart upgrades, so to keep them up to date
install the Percona Operator for MongoDB CRDs chart before this one. Full
documentation: https://docs.percona.com/percona-operator-for-mongodb/

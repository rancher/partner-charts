## CRDs for LP Backend

The chart deploys set of operators and CRDs, which necessary to configure postgresql, rabbitmq, redis.


## Prerequisites

- Kubernetes 1.19+
- Helm 3.2.0+
- PV provisioner support in the underlying infrastructure

## CRDs
This Chart create following crds, and do not remove them after operator remove by defult

- `backups.postgresql.cnpg.io`
- `clusters.postgresql.cnpg.io`
- `poolers.postgresql.cnpg.io`
- `rabbitmqclusters.rabbitmq.com`
- `scheduledbackups.postgresql.cnpg.io`

For more information on how to configure the Helm chart, refer to the Helm README.


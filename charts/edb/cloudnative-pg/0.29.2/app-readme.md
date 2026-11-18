# CloudNativePG

[CloudNativePG](https://cloudnative-pg.io/) is a CNCF Kubernetes operator that manages the full lifecycle of PostgreSQL clusters — from deployment through high availability, backups, rolling upgrades, and scaling. Originally created and maintained by EnterpriseDB, it integrates directly with the Kubernetes API to automate PostgreSQL operations.

This chart installs the CloudNativePG operator along with its CustomResourceDefinitions. Once the operator is running, you can declare PostgreSQL deployments through the `Cluster` custom resource, and manage backups, replicas, and connection pooling using the operator's other CRDs.

## Prerequisites

* A Rancher-supported Kubernetes distribution
* A default `StorageClass` capable of provisioning persistent volumes for PostgreSQL data
* Cluster-admin privileges to install the operator's CRDs

## Installation

* Install this chart following readme.
* Once the operator pod is `Ready`, create a `Cluster` resource to deploy your first PostgreSQL cluster. See the [Quickstart](https://cloudnative-pg.io/docs/1.29/quickstart/#part-3-deploy-a-postgresql-cluster) for a sample manifest.

## Documentation

Full documentation, including configuration reference, backup strategies, and upgrade procedures, is available at [https://cloudnative-pg.io/documentation/](https://cloudnative-pg.io/documentation/).

CloudNativePG is open source under the Apache License 2.0. Commercial support is available from [EnterpriseDB](https://www.enterprisedb.com/).

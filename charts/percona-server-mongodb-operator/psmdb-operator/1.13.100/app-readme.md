# Percona Operator for MongoDB

Percona Operator for MongoDB allows users to deploy and manage Percona Server for MongoDB Clusters on Kubernetes.
Useful links:
- [Operator Github repository](https://github.com/percona/percona-server-mongodb-operator)
- [Operator Documentation](https://www.percona.com/doc/kubernetes-operator-for-psmongodb/index.html)

## Pre-requisites
* Kubernetes 1.19+
* Helm v3

# Installation

This chart will deploy the Operator Pod for the further Percona Server for MongoDB creation in Kubernetes.

## Installing the chart

To install the chart with the `psmdb` release name using a dedicated namespace (recommended):

```sh
helm repo add percona https://percona.github.io/percona-helm-charts/
helm install my-operator percona/psmdb-operator --version 1.13.0 --namespace my-namespace
```

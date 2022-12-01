# Ondat Operator

StorageOS is a cloud native, software-defined storage platform that transforms
commodity server or cloud based disk capacity into enterprise-class persistent
storage for containers. StorageOS volumes offer high throughput, low latency
and consistent performance, and are therefore ideal for deploying databases,
message queues, and other mission-critical stateful solutions. StorageOS
Project edition also offers ReadWriteMany volumes that are concurrently
accessible by multiple applications.

The Ondat Operator installs and manages StorageOS within a cluster. Cluster
nodes may contribute local or attached disk-based storage into a distributed
pool, which is then available to all cluster members via a global namespace.

Volumes are available across the cluster so if an application container gets
moved to another node it has immediate access to re-attach its data.

StorageOS is extremely lightweight - minimum requirements are a reserved CPU
core and 2GB of free memory. There are minimal external dependencies, and no
custom kernel modules.


After StorageOS is installed, please register for a free personal license to
enable 1TiB of capacity and HA with synchronous replication by following the
instructions [here](https://docs.ondat.io/docs/operations/licensing). For
additional capacity, features and support plans contact sales@ondat.io.

## Highlighted Features

* High Availability - synchronous replication insulates you from node failure.
* Delta Sync - replicas out of sync due to transient failures only transfer
    changed blocks.
* Multiple AccessModes - dynamically provision ReadWriteOnce or ReadWriteMany
    volumes.
* Rapid Failover - quickly detects node failure and automates recovery actions
    without administrator intervention.
* Data Encryption - both in transit and at rest.
* Scalability - disaggregated consensus means no single scheduling point of
    failure.
* Thin provisioning - only consume the space you need in a storage pool.
* Data reduction - transparent inline data compression to reduce the amount of
    storage used in a backing store as well as reducing the network bandwidth
    requirements for replication.
* Flexible configuration - all features can be enabled per volume, using PVC
    and StorageClass labels.
* Multi-tenancy - fully supports standard Namespace and RBAC methods.
* Observability & instrumentation - Log streams for observability and
    Prometheus support for instrumentation.
* Deployment flexibility - scale up or scale out storage based on application
    requirements. Works with any infrastructure – on-premises, VM, bare metal
    or cloud.

## About StorageOS

StorageOS is a software-defined cloud native storage platform delivering
persistent storage for Kubernetes. StorageOS is built from the ground-up with
no legacy restrictions to give enterprises working with cloud native workloads
a scalable storage platform with no compromise on performance, availability or
security. For additional information, visit www.ondat.io.

## Installation

StorageOS requires an etcd cluster in order to function. Find out more about
setting up an etcd cluster in our [etcd
docs](https://docs.ondat.io/docs/prerequisites/etcd/).

By default, a minimal configuration of StorageOS is installed. To set advanced
configurations, disable the default installation of the StorageOS cluster
and create a custom StorageOSCluster resource, documentation
[here](https://github.com/ondat/charts/blob/main/charts/ondat-operator/README.md#creating-a-storageos-cluster-manually)

Newly installed StorageOS clusters require a license to function. For
instructions on applying our free developer license, or obtaining a commercial
license, please see our documentation at
https://docs.ondat.io/docs/reference/licence/.

## Read First

To set up a SQL Server Availability Group within a Kubernetes cluster, you need to:

1. Set up DxOperator
2. Implement DxEnterpriseSqlAg

This DxOperator Helm chart represents the first step of this process.

For additional details, please read our [DxOperator Helm Guide](https://support.dh2i.com/dxoperator/v1.0.67.0/guides/dxesqlag-helm).

## Deploy Highly Available SQL Server Containers 

SQL Server availability groups ensure high uptime and minimize data loss 
by providing data replication and automatic failover between multiple 
instances of SQL Server. This feature provides:

- High availability and failover when a pod/node/instance fails
- Data replication for off-site disaster recovery

## DxOperator by DH2i 

DxOperator by DH2i automates the deployment of SQL Server Availability 
Groups in Kubernetes and effortlessly integrates your workloads into the 
DxEnterprise HA clustering framework. This gives you the flexibility to 
deploy SQL Server workloads on any operating system, server 
configuration, or cloud to maximize performance without fear of downtime 
or data loss.

Features: 

- ***Cloud Native:*** Built on cloud native concepts like microservice 
  architecture, immutable infrastructure, and declarative configuration

- ***Advanced Architecture:*** Patented technology gives you unmatched 
  flexibility and control over how you architect your SQL Server 
  Availability Group in K8s

- ***High Availability:*** Our enterprise-grade SQL Server clustering 
  technology enables fully automated failover in seconds for SQL Server 
  Availability Groups

Instructions for installing and using this Helm chart can be found in
the [DxOperator Helm Guide](https://support.dh2i.com/dxoperator/v1.0.67.0/guides/dxesqlag-helm).

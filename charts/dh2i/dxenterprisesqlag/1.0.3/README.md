# DxOperator – DxEnterprise SQL AG 

## Read First

To set up a SQL Server Availability Group within a Kubernetes cluster, you need to:

1. Set up DxOperator
2. Implement DxEnterpriseSqlAg

This DxEnterpriseSqlAg Helm chart represents the second step of this process.
 
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

## Prerequisites

To create a DxEnterpriseSqlAg deployment, the following are required: 

- DxOperator must be installed on your Kubernetes cluster – see the 
  [DxOperator Helm Quick Start Guide](https://support.dh2i.com/dxoperator/v1.0.67.0/guides/dxesqlag-helm).
- A DxEnterprise license key with Availability Group management features 
  and tunnels enabled -- [Request a free developer license](https://dh2i.com/dxoperator-sql-server-operator-for-kubernetes/)
- Persistent volumes, for storing the SQL Server data
- A secret on your Kubernetes cluster that contains SQL Server
  credentials (`MSSQL_SA_PASSWORD`), your DxEnterprise cluster password
  (`DX_PASSKEY`), your DxEnterprise license key (`DX_LICENSE`), and
  optionally your one-time passkey (`DX_OTPK`)
- Optional: A ConfigMap containing the SQL Server configuration file, 
  for advanced options
- Optional: DxAdmin installed on a Windows machine. Installation 
  instructions for DxAdmin can be found in DH2i documentation

## Additional Information 

- Instructions for installing and using this Helm chart can be found in the 
  [DxOperator Helm Quick Start Guide](https://support.dh2i.com/dxoperator/v1.0.67.0/guides/dxesqlag-helm).
- Before creating an Availability Group, reference SQL Server's
  [quorum considerations](https://support.dh2i.com/docs/v23.0/kbs/sql_server/availability_groups/quorum-considerations-for-sql-server-availability-groups)
  when determining the quantity of replicas to deploy
